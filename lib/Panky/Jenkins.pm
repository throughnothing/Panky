package Panky::Jenkins;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON;
use Module::Pluggable
    search_path => ['Panky::Jenkins::HookActor'], instantiate => 'new';

# ABSTRACT: Controller that accepts Jenkins Notification HTTP Hooks.

sub hook {
    my ($self) = @_;

    # Get params from the POST
    my $params = $self->req->body_params->to_hash;
    $self->render_exception('Bad Data!') unless $params;

    # Iterate over all jenkins hook actors and run their actions
    # Plugins come from Module::Pluggable
    for ( $self->plugins( panky => $self->app ) ) {
        # Make sure it can handle this method
        next unless $_->can('notification');
        $_->notification( $params );
    }

    # It seems like I have to render something for this route to work
    # We'll tell Jenkins thanks :)
    $self->render( text => 'Thanks!' );
}

1;

=head1 SYNOPSIS

This module requires a post-build task script which does a C<POST> via
C<curl> with proper parameters on build finish.  Here is a sample configuration
script under B<Post-build Actions->Post build task->script>:

    curl -X POST "http://myapp.com/_jenkins" -d\
    "repo=github_user/repo\
    &sha=$GIT_COMMIT\
    &status=$BUILD_STATUS\
    &job_name=$JOB_NAME\
    &job_number=$BUILD_NUMBER\
    &branch=$GIT_BRANCH"
