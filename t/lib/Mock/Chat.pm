package t::lib::Mock::Chat;
use Mojo::Base 'Panky::Chat';
use Panky::Chat::Module;

has 'module';
has sayings => sub { [ ] };

# Used to send fake messages to the chat
sub tell {
    my ($self, $msg, %args) = @_;
    $args{type} //= 'directed_message';
    $args{from} //= 'test-user';

    $self->dispatch( $args{type}, $msg, $args{from});
}

# Push calls to 'sayings' for inspection
sub say { push @{ shift->sayings }, [ @_ ] }

1;
