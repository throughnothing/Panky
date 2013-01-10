package t::lib::Mock::Jenkins;
use Mojo::Base 'Panky::CI::Jenkins';
use Mojo::Message::Response;

has requests => sub{ [] };
has responses => sub{ [] };

# Push the request data to 'requests' for inspection
# And pop off the next response that we want to return
sub _req {
    my $self = shift;
    push @{ $self->requests }, [ @_ ];
    pop ( @{ $self->responses } ) || $self->_default_res;
}

sub _default_res {
    my ($self) = @_;
    my $res = Mojo::Message::Response->new;
    $res->headers->location('http://localhost:2000');
    $res->code( 302 );
    $res;
}

1;
