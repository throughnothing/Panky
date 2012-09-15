package Panky::CI::Jenkins;
use Mojo::Base -base;
use Mojo::JSON;
use Mojo::UserAgent;
use Mojo::Util qw( url_escape );

# ABSTRACT: Panky::CI Object for interacting with Jenkins

has [qw( base_url user token )];
has json => sub { Mojo::JSON->new };
has ua => sub { Mojo::UserAgent->new };

# Build job_name on jenkins
sub build {
    my ($self, $job_name, $sha) = @_;
    my $data = { parameter => { name => 'HEAD', value => $sha } };
    my $res = $self->_req( POST_FORM => "job/$job_name/build", $data );
    return $res->headers->location;
}

sub _req {
    my ($self, $method, $path, $data) = @_;
    $method = lc($method);

    # Build the new url with the user/pass in them for BasicAuth
    my ($user, $token) = ($self->user, $self->token);
    my $base = ( $self->base_url =~ s{://}{://$user:$token\@}r );

    # url_escape the data as json inside the json parameter
    # ...this is what jenkins wants :-X
    $data = { json => url_escape( $self->json->encode( $data ) ) };

    $self->ua->$method( $base . $path, $data )->res;
}


1;

=head1 SYNOPSIS

This provides L<Jenkins|http://jenkins-ci.org/> support for L<Panky>
