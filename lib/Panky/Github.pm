package Panky::Github;
use Mojo::Base 'Mojolicious::Controller';
use Panky::Github::HookPayload qw( parse );
use Module::Pluggable
    search_path => ['Panky::Github::HookActor'], instantiate => 'new';

# ABSTRACT: Controller that accepts Github Receive-Hooks.

sub hook {
    my ($self) = @_;

    # If it doesn't parse as JSON, we don't care
    $self->render_exception('Bad Data!') unless $self->req->json;

    my $pl = parse( { %{ $self->req->json } } );

    # Iterate over all hook actors and run their actions
    # Plugins come from Module::Pluggable
    my $method = $pl->type;
    for ( $self->plugins( panky => $self->app ) ) {
        # Make sure it can handle this method
        next unless $_->can($method);
        $_->$method( $self->app, $pl );
    }

    # It seems like I have to render something for this route to work
    # We'll tell Github thanks :)
    $self->render( text => 'Thanks!' );
}

1;

=head1 SYNOPSIS

This module simply receives
L<Repo Hook|http://developer.github.com/v3/repos/hooks/> post backs from
github, and decides what to do with the info received.
