package Panky::Github::API;
use Mojo::Base -base;
use Mojo::UserAgent;
use URI;

# ABSTRACT: Object for interacting with the Github API

has events => sub { [qw(
    pull_request pull_request_review_comment commit_comment push
)]};
has url => 'https://api.github.com';
has ua => sub { Mojo::UserAgent->new };
has secret => 'panky-secret';
has [qw( user pwd hook_url )];

sub new {
    my ($self, %args) = @_;
    $self = $self->SUPER::new( %args );

    # Build the new url with the user/pass in them for BasicAuth
    my ($user, $pwd) = ($self->user, $self->pwd);
    $self->url( $self->url =~ s{://}{://$user:$pwd\@}r );

    return $self;
}

sub get_repo {
    my ($self, $nwo) = @_;
    $self->_req( GET => "/repos/$nwo" );
}
sub get_branches {
    my ($self, $nwo) = @_;
    $self->_req( GET => "/repos/$nwo/branches" );
}

sub get_commit {
    my ($self, $nwo, $sha) = @_;
    $self->_req( GET => "/repos/$nwo/commits/$sha" );
}

sub get_pulls {
    my ($self, $nwo) = @_;
    $self->_req( GET => "/repos/$nwo/pulls" );
}

sub get_pull {
    my ($self, $nwo, $id) = @_;
    $self->_req( GET => "/repos/$nwo/pulls/$id" );
}

sub create_pull_comment {
    my ($self, $nwo, $id, $comment) = @_;
    $self->_req( POST_JSON => "/repos/$nwo/issues/$id/comments", {
        body => $comment,
    });
}

sub set_status {
    my ($self, $nwo, $sha, $state, $url, $desc) = @_;
    $self->_req( POST_JSON => "/repos/$nwo/statuses/$sha", {
        state => $state,
        target_url => $url,
        description => $desc,
    });
}

sub get_hook {
    my ($self, $hook_url) = @_;
    $self->_req( GET => URI->new( $hook_url )->path );
}

sub create_hook {
    my ($self, $nwo) = @_;
    my $res = $self->_req(
        POST_JSON => "/repos/$nwo/hooks", {
            name => 'web', active => 1,
            config => {
                url => $self->hook_url,
                secret => $self->secret,
                content_type => 'json'
            },
            events => $self->events,
        }
    );
    return $res;
}

sub test_hook {
    my ($self, $hook_url) = @_;
    $self->_req( POST => URI->new( $hook_url )->path . '/test' );
}

# Make a request to the Github API
# - method: GET/POST
# - path: /repos/:user/:repo
sub _req {
    my($self, $method, $path, $json) = @_;
    $method = lc($method);
    $self->ua->$method( $self->url . $path, $json )->res->json;
}

1;

=head1 SYNOPSIS

This module provides L<Panky> with an interface to the
L<Github API|http://developer.github.com/v3/>.  This module does not implement
all of the L<Github API|http://developer.github.com/v3/> functionality, but
merely the simple subset needed by L<Panky>.

=head1 METHODS

=over

=item get_repo

Given a "user/repo" this method will return the C<json> of the get repo
response from Github.

=item get_branches

Given a "user/repo" this method will return the C<json> of the get repo
branches response from Github.

=item get_commit

Given a "user/repo" and C<sha> hash for a commit, this method will return
the C<json> of the Github commit response.

=item get_hook

Given a C<hook_url>, this method will return the C<json> of the Github
response for a hook.

=item test_hook

Given a C<hook_url>, this method will prompt github to send a test postback
request to our app's endpoint for testing.

=back
