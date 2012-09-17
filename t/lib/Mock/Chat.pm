package t::lib::Mock::Chat;
use Mojo::Base 'Panky::Chat';
use Panky::Chat::Module;

has 'module';
has sayings => sub { [ ] };

sub plugins {
    my $self = shift;

    # Store the module in here so we can look at it
    $self->module( Panky::Chat::Module->new( @_ ) );
    return ( $self->module );
}

# Push calls to 'sayings' for inspection
sub say { push @{ shift->sayings }, [ @_ ] }

1;
