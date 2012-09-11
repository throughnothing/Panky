package Panky::Chat::Module::Github;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use WWW::Shorten 'GitHub';

# ABSTRACT: Handles github action requests from users in chatroom

sub directed_message {
    my ($self, $msg, $from) = @_;
    my $gh = $self->panky->github;

    given( $msg ) {
        when( qr{(https?://github.com/\S+)} ) {
            # Shorten found github links
            my $link = makeashorterlink( $1 );
            $self->say( $link );
        }
        when( /gh setup (\S+)/ ) {
            $gh->create_hook( $1 );
            $self->say( "$from: Setup $1!" );
        }
        when( /gh test-hooks (\S+)/ ) {
            $gh->test_hook( $1 );
        }
    }
}

1;

=head1 SYNOPSIS

This is a dummy module that simply echoes what anyone says in the chatroom.
