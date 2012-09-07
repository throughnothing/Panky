package Panky::Chat::Jabber::Github;
use v5.10;

# ABSTRACT: Handles github action requests from users in chatroom

sub directed_message {
    my ($self, $panky, $room, $msg) = @_;
    my $gh = $panky->github;

    given( $msg->body ) {
        when( /gh setup (\S+)/ ) {
            $gh->create_hook( $1 );
            my $from = $msg->from_nick;
            $room->make_message( body => "$from: Setup $1!" )->send;
        }
        when( /gh test-hooks (\S+)/ ) {
            $gh->test_hook( $1 );
        }
    }
}

1;

=head1 SYNOPSIS

This is a dummy module that simply echoes what anyone says in the chatroom.
