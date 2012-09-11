package Panky::Github::HookActor;
use Hash::Merge::Simple qw( merge );
use Memoize;
use Mojo::Base -base;
use WWW::Shorten 'GitHub';

# ABSTRACT: Panky::Github::HookActor Base class with helper functions

has [qw( panky )];
has default_config => sub{ {} };

memoize 'config';

# Returns configuration hash for this plugin
sub config {
    my ($self) = @_;

    my $name = (split /::/, ref( $self ), 4)[3];
    # merge uses the rightmost argument to take precedence
    return merge(
        $self->default_config,
        $self->panky->config->{Github}{HookActor}{$name},
    );
}

# Returns a branch name from a refspec (refs/heads/master => master)
sub branch_from_ref { ( split qr{refs/heads/}, $_[1] )[-1] }

# Shorten the given URL with http:://git.io
sub shorten { makeashorterlink( $_[1] ) }


1;

=head1 SYNOPSIS

L<Panky::Github::HookActor> is the base class for  all of your
L<Panky::Github::HookActor>'s that you may want to create.  Any C<HookActor>
should use this as the base class.

=head1 Helper Methods

This base class provides the following helper functions:

=head2 branch_from_ref

This function accepts a ref in the form C<refs/heads/master> and returns
the branch name C<master>.

    package Panky::Github::HookActor::Mine;
    use Mojo::Base 'Panky::Github::HookActor';

    sub random_function {
        my ($self, %args) = @_;

        # Returns 'test'
        $self->branch_from_ref( 'refs/heads/test' );
    }

=head2 shorten

This function accepts a Github url and returns a shortened version from
L<http://git.io/|http://git.io/>.

    package Panky::Github::HookActor::Mine;
    use Mojo::Base 'Panky::Github::HookActor';

    sub random_function {
        my ($self, %args) = @_;

        # Returns http://git.io/XXXX
        $self->shorten( 'http://github.com/project/repo' );
    }
