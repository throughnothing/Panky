package Panky::Chat::Module;
use DBM::Deep 2.0008;
use Mojo::Base -base;

# ABSTRACT: Base class for L<Panky::Chat::Module>s

has [qw( panky )];
has storage => sub {
    my ($self) = @_;
    my $name = (split /::/, ref $self)[-1];
    DBM::Deep->new("panky_chat_madule_$name.db")
};


sub say { $_[0]->panky->chat->say( $_[1] ) }

1;

=head1 SYNOPSIS

This is a dummy module that simply echoes what anyone says in the chatroom.
