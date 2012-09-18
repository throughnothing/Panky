package t::lib::Mock::GithubAPI;
use Mojo::Base 'Panky::Github::API';

has requests => sub{ [] };
has responses => sub{ [] };

# Push request params to 'requests' for inspection
# Also pop off of responses to return if we need
sub _req {
    my $self = shift;
    push @{ $self->requests }, [ @_ ];
    pop @{ $self->responses };
}

1;
