package Panky;
use Mojo::Base 'Mojolicious';
use Panky::CI::Jenkins;
use Panky::Github::API;

# ABSTRACT: Panky is a chatty, github-and-ci helper bot for your team

has [qw( chat github ci base_url )];

my @required_env = qw( PANKY_BASE_URL PANKY_GITHUB_USER PANKY_GITHUB_PWD );

sub startup {
    my ($self) = @_;

    # Create the db if this is the first time the app is run
    #eval { $self->schema->deploy };

    # Make sure we have all required $ENV vars
    !$ENV{$_} ? die "$_ Required!" : 0 for @required_env;

    # Setup github
    $self->_setup_gh;

    # Setup our Chat Bot
    $self->_setup_chat;

    # Setup Jenkins
    $self->_setup_ci;

    # Set up our routes
    my $r = $self->routes;

    # Home Page Route
    $r->get('/')->to('app#home');

    # Github Hooks point here
    $r->post('/_github')->to('github#hook');
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

sub _setup_gh {
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

    # TODO: This does nothing so far
    $self->ci( Panky::CI::Jenkins->new );
}

1;

=head1 SYNOPSIS

Panky aims to be a chatting, github and jenkins loving
web-app/bot/do-it-all/chef(?) for your team.

B<Note: L<Panky> is still in active development and is not feature complete>

Currently, Panky will connect to your chat server, update you about what's
going on with your github repos (new pushes, pull request activity, comments,
etc.) and enable you to get info about them on demand.

In the future, Panky will be able to get Jenkins build statuses,
create builds, run builds, and report back to the chat with its findings.

Panky will not make you a sandwich (yet).

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

=back

Optionally, you can also provide chat parameters to have L<Panky> connect to
jabber:

=over

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

=head2 Heroku

To run L<Panky> in L<Heroku|http://heroku.com>, the easiest way is to use
the L<Perloku|https://github.com/judofyr/perloku> buildpack.

    $ git clone https://github.com/throughnothing/Panky
    $ cd Panky
    $ heroku create -s cedar --buildpack http://github.com/judofyr/perloku.git

Now your heroku app is setup and ready to receive the L<Panky> application.
Before you push L<Panky> to your app, you'll want to setup the environment
variables described above by using:

    $ heroku config:add ENVIRONMENT_VARIABLE="value"

For each config value that you wish to set.

Once all of that is set up, you can deploy the app using:

    $ git push heroku master

This will deploy your app code, install all dependencies, and run it.

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
