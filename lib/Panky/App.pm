package Panky::App;
use Mojo::Base 'Mojolicious::Controller';

# ABSTRACT: Basic App Routes for Panky

sub home {
    my ($self) = @_;
    $self->render( message => "This is Panky." );
}

1;

=head1 SYNOPSIS

This module is just a place to store HTTP routes for the L<Panky> app.
