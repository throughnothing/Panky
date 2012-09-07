package Panky::Github;
use Mojo::Base 'Mojolicious::Controller';
use Panky::Github::HookPayload qw( parse );

# ABSTRACT: Controller that accepts Github Receive-Hooks.

sub hook {
    my ($self) = @_;

    # If it doesn't parse as JSON, we don't care
    $self->render_exception('Bad Data!') unless $self->req->json;

    my $payload = parse( { %{ $self->req->json } } );

    # TODO: Do stuff with payload LOL

    $self->render( json => { response => "In theory!" });
}

1;

=head1 SYNOPSIS

This module simply receives
L<Repo Hook|http://developer.github.com/v3/repos/hooks/> post backs from
github, and decides what to do with the info received.
