package Panky::Message;
use Mojo::Base 'Mojolicious::Controller';

# ABSTRACT: Controller that accepts Generic Message Hooks

sub hook {
    my ($self) = @_;

    # If it doesn't parse as JSON, we don't care
    $self->render_exception('Bad Data!') unless $self->req->json;

    # If we want a token to be required
    my $json = $self->req->json;
    my $token = $self->config->{Message}{token};
    if( $token ){
        $self->render_exception('Bad Token!') unless $json->{token} eq $token;
        return;
    }

    $self->app->chat->say( $json->{msg} ) if $json->{msg};

    # Tell the sender thanks
    $self->render( text => 'Thanks!' );
}

1;

=head1 SYNOPSIS

This module simply receives JSON data that can tell panky to say things in chat
or be acted upon in some way
