package Panky;
use Mojo::Base 'Mojolicious';
use Mojo::JSON;
use Mojo::Log;
use Mojo::URL;
use JIRA::Client::REST 0.06;
use Panky::CI::Jenkins;
use Panky::Github::API;
use Panky::Schema;

# ABSTRACT: Panky is a chatty, github, issue, and-ci helper bot for your team

has [qw( chat ci github base_url jira schema )];
has json => sub { Mojo::JSON->new };
has log => sub { Mojo::Log->new };

my @required_env = qw( PANKY_BASE_URL PANKY_GITHUB_USER PANKY_GITHUB_PWD );

sub startup {
    my ($self) = @_;

    # Make sure we have all required $ENV vars
    !$ENV{$_} ? die "$_ Required!" : 0 for @required_env;

    # Load config
    $self->plugin('Config');

    # Setup storage
    $self->_setup_storage;

    # Setup github
    $self->_setup_github unless $self->github;

    # Setup our Chat Bot
    $self->_setup_chat unless $self->chat;

    # Setup Jenkins
    $self->_setup_ci unless $self->ci;

    # Setup JIRA
    $self->_setup_jira unless $self->jira;

    # Set up our routes
    my $r = $self->routes;

    # Home Page Route
    $r->get('/')->to('app#home');

    # Github Hooks point here
    $r->post('/_github')->to('github#hook');

    # Jenkins postbacks go here.
    # They should be set up with curl in a post-build task script
    # https://wiki.jenkins-ci.org/display/JENKINS/Post+build+task
    # and they need the following parameters:
    #   - repo = github_user/repo
    #   - sha = the sha hash of the commit that was tested by Jenkins
    #   - status = success/failure
    #   - job_name = jenkins job name (from $JOB_NAME)
    #   - job_number = jenkins job number (from $JOB_NUMBer)
    #   - branch = git branch name
    $r->post('/_jenkins')->to('jenkins#hook');
}

sub storage_get {
    my ($self, $key) = @_;
    my $res = $self->schema->resultset('Obj')->find( $key );
    return $res ? $self->json->decode( $res->value ) : undef;
}

sub storage_put {
    my ($self, $key, $val) = @_;
    $self->schema->resultset('Obj')->update_or_create({
        key => $key, value => $self->json->encode( $val ),
    });
}

sub _setup_storage {
    my ($self) = @_;

    my( $dsn, $user, $pass );
    if( $ENV{DATABASE_URL} ) {
        $self->log->info( "Using Postgres database... $ENV{DATABASE_URL}" );
        # If postgres database_url is setup
        my $url = Mojo::URL->new( $ENV{DATABASE_URL} );
        my $dbname = $url->path =~ s{/}{}gr;
        my ($host, $port) = ($url->host, $url->port);
        $dsn = "dbi:Pg:dbname=$dbname;host=$host;port=$port";
        ($user, $pass) = split /:/, $url->userinfo, 2
    } else {
        $self->log->info( "Using SQLite database..." );
        # Otherwise we fall back to sqlite (which will be temporary in Heroku)
        my $file = $ENV{SQLITE_FILE} || ":memory:";
        $dsn = "dbi:SQLite:$file";
    }

    # Connect to the DB
    $self->schema( Panky::Schema->connect( $dsn, $user, $pass ) );
    eval { $self->schema->deploy };
    $self->log->warn( $@ ) if $@;
}

sub _setup_chat {
    my ($self) = @_;

    my $module = 'Panky::Chat::' . ($ENV{PANKY_CHAT} || 'Jabber');
    # If PANKY_CHAT is set, or we've set a Jabber JID
    if( $ENV{PANKY_CHAT} || $ENV{PANKY_CHAT_JABBER_JID} ) {
        eval "require $module";
        # Create Jabber Chat object
        $self->chat( $module->new( panky => $self )->connect );
    } else {
        $module = 'Panky::Chat';
        eval "require $module";
        # Just use a Base chat object (which does nothing) otherwise
        $self->chat( Panky::Chat->new );
    }
}

sub _setup_github {
    my ($self) = @_;

    # Initialize GitHub API
    my $github_hook_url =
    $self->github( Panky::Github::API->new(
        ua       => $self->ua,
        user     => $ENV{PANKY_GITHUB_USER},
        pwd      => $ENV{PANKY_GITHUB_PWD},
        hook_url => join( '/', $ENV{PANKY_BASE_URL}, '_github' ),
    ) );
}

sub _setup_ci {
    my ($self) = @_;

    $self->ci(
        Panky::CI::Jenkins->new(
            panky => $self,
            base_url => $ENV{PANKY_JENKINS_URL},
            user => $ENV{PANKY_JENKINS_USER},
            token => $ENV{PANKY_JENKINS_TOKEN},
        )
    );
}

sub _setup_jira {
    my ($self) = @_;
    # Return unless we have the needed variables
    unless( $ENV{PANKY_JIRA_URL} &&
            $ENV{PANKY_JIRA_USER} && $ENV{PANKY_JIRA_PWD} ){
        $self->log->info( "Not loading jira b/c env vars were not set..." );
        return;
    }

    $self->jira(
        JIRA::Client::REST->new(
            username => $ENV{PANKY_JIRA_USER},
            password => $ENV{PANKY_JIRA_PWD},
            url => $ENV{PANKY_JIRA_URL},
        )
    );
}

1;

=head1 SYNOPSIS

[![Build Status](https://secure.travis-ci.org/throughnothing/Panky.png?branch=master)](http://travis-ci.org/throughnothing/Panky)

Panky is a chatting, github, Jira, jenkins loving
web-app/bot/do-it-all/chef(?) for your team.

Panky lurks in your teams chat room (Jabber is currently supported) and provides
useful information and functionality B<all day long>.

B<Note: L<Panky> is still in active development and is not feature complete>

Currently, Panky will connect to your chat server, update you about what's
going on with your github repos (new pushes, pull request activity, comments,
etc.) and enable you to get info about them on demand.  It can also parse
C<Jira> links, and provide information about (and start) C<Jenkins> builds.

Panky can also use the C<Github|http://github.com>
L<commit status API|https://github.com/blog/1227-commit-status-api> to show
the status of your Continuous Integration builds on Pull Requests.

Some sample usage:

    > panky: gh setup repo1/user1
    # Panky sets up github hooks for itself for that repo

    # Set an alias 'alias' for user/my-repo
    > panky: gh set repo myrepo => user/my-repo
    # Link the github repo 'user/my-repo' with the jenkins job 'ci-job-name'
    > panky: ci set repo user/my-repo => ci-job-name
    # Run the 'ci-job-name' job against pull-request #1 on user/my-repo
    > panky: test my-repo pr 1

    # When a build succeeds/fails
    > <panky> [Jenkins: ci-job-name] failed https://myjenkins/job/ci-job-name/1

    # When a teammate creates a pull request (with git.io shortened url)
    > <panky> [user/my-repo] PR 'Fix the broken things' opened by throughnothing http://git.io/XXXX

    # Panky can show info about your JIRA tickets
    > hey, check out https://company.atlassian.net/brows/PROJ-1
    > <panky> [PROJ-1](Priority) assignee => Issue summary


=head1 INSTALLING

L<Panky> requires a non-blocking server in order to run.  This means that
you probably want to use either L<Twiggy>, or the builtin L<Mojolicious>
server.

=head2 Environment Variables

L<Panky> is configured via environment variables to make it easy to install on
systems like L<Heroku|http://heroku.com>.

The following environment variables must be set for L<Panky> to run:

=over

=item PANKY_BASE_URL

This should be set to the base url that the L<Panky> server will be running on.

=item PANKY_GITHUB_USER

The username of a Github user that will have access to whatever is needed.

=item PANKY_GITHUB_PWD

The Github password for the user mentioned above.

=item PANKY_CHAT_JABBER_JID

The C<jid> of L<Panky>'s jabber account.

=item PANKY_CHAT_JABBER_PWD

The password for L<Panky>'s jabber account.

=item PANKY_CHAT_JABBER_HOST

If you need to set your jabber host to something different than the domain
part of the C<jid>, then you can use this variable to do so.

=item PANKY_CHAT_JABBER_ROOM

The jabber conference room that L<Panky> should join.  This should be the
full C<jid> of the room, such as C<room@conference.jabber.server.com>.

=back

=head2 Jenkins Support

You can also give it the C<URL> to your L<Jenkins|http://jenkins-ci.org> server
via the C<PANKY_JENKINS_URL> option.  L<Panky> will use this to generate
links to Jenkins builds, etc.  If you want L<Panky> to be able to start builds
on jenkins (from pull requests etc.) you should pass C<PANKY_JENKINS_USER> and
C<PANKY_JENKINS_TOKEN> for authentication.

=head2 JIRA Support

L<Panky> can also work with JIRA if you have that.  You can enable JIRA support
by setting the following environment variables:

=over

=item PANKY_JIRA_URL

The url of your jira server: C<https://company.atlassian.net/>

=item PANKY_JIRA_USER

The username to use to authenticate with your JIRA server.

=item PANKY_JIRA_PWD

The password of the user used to authenticate with your JIRA server.

=back

=head2 Heroku

To run L<Panky> in L<Heroku|http://heroku.com>, the easiest way is to use
the L<Perloku|https://github.com/judofyr/perloku> buildpack.

    $ git clone https://github.com/throughnothing/Panky
    $ cd Panky
    $ heroku create -s cedar --buildpack http://github.com/judofyr/perloku.git
    # Optionally, if you want persistent storage across app restarts
    $ heroku addons:add heroku-postgresql(:dev)

Now your heroku app is setup and ready to receive the L<Panky> application.
Before you push L<Panky> to your app, you'll want to setup the environment
variables described above by using:

    $ heroku config:add ENVIRONMENT_VARIABLE="value"

For each config value that you wish to set.

Once all of that is set up, you can deploy the app using:

    $ git push heroku master

This will deploy your app code, install all dependencies, and run it.

If you have the PostgreSQL addon enabled, L<Pany> will detect the
C<DATABASE_URL> environment variable present, and use the PostgreSQL server,
otherwise it falls back to sqlite storage, which will get lost whenever
you restart your app.

=head1 USAGE

Once configured and setup, L<Panky> is mostly interacted with via chat
(jabber by default).  Below are some commands that L<Panky> accepts.  In
general, these commands must be directed at the L<Panky> chat bot
(i.e you must mention the bot by name: "panky: COMMAND").

=over

=item gh setup I<FULL_REPO_NAME>

This will direct L<Panky> to setup L<Github|http://github.com> Hooks for the
repo in question. I<FULL_REPO_NAME> should look like C<user/repo> or
C<organization/repo>.  The C<GITHUB_USER> that is setup for L<Panky> must have
access to the repo if it is private for this to work.

=back
