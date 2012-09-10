package Panky::Chat;
use Mojo::Base -base;

has 'required_env';

sub new {
    my ($self, %args) = @_;

    # Make sure we have all required fields
    for ( @{ $self->required_env } ) {
        die "$_ Required for Chat!" if !$ENV{$_};
    }
    $self = $self->SUPER::new( %args );

    # Let your app setup your variables
    $self->setup;

    return $self;
}

# Dummy setup function in case a sub-class doesn't need one
sub setup { }

1;

=head1 SYNOPSIS

All C<Panky::Chat::*> modules should inherit from C<Panky::Chat>.

Additionally, any module that inherits from this, should define the
C<required_env> attribute to be an C<ARRAYREF> of all environment variables
that the chat module requires to work.  This module will ensure that we die
if we don't have them all.

Your C<Chat> module also needs to implement the C<setup> method, which will
set the attributes on your C<Chat> object appropriately from the environment
variables (with defaults if needed) for the rest of your module to use.
