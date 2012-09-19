package Panky::Chat::Module;
use Mojo::Base -base;

# ABSTRACT: Base class for L<Panky::Chat::Module>s

has [qw( panky )];

sub say { $_[0]->panky->chat->say( $_[1] ) }

1;

=head1 SYNOPSIS

This is a dummy module that simply echoes what anyone says in the chatroom.
