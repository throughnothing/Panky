package Panky::Chat::Jabber::Echo;

# ABSTRACT: Simple Panky::Jabber dispatcher that just echo's messages

sub private_message {
    my ($self, $panky, $room, $msg) = @_;
    $room->make_message( body => 'echo: ' . $msg->body )->send;
}

1;

=head1 SYNOPSIS

This is a dummy module that simply echoes what anyone says in the chatroom.
