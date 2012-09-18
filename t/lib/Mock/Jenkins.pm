package t::lib::Mock::Jenkins;
use Mojo::Base 'Panky::CI::Jenkins';

has requests => sub{ [] };
has responses => sub{ [] };

# Push the request data to 'requests' for inspection
# And pop off the next response that we want to return
sub _req {
    my $self = shift;
    push @{ $self->requests }, [ @_ ];
    pop @{ $self->responses };
}

1;
