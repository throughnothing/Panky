package Panky::HookActor;
use Hash::Merge::Simple qw( merge );
use Memoize;
use Mojo::Base -base;

# ABSTRACT: Panky::HookActor Base class with helper functions

has [qw( panky type )];
has default_config => sub{ {} };

memoize 'config';

# Returns configuration hash for this plugin
sub config {
    my ($self) = @_;

    my $name = (split /::/, ref( $self ), 4)[3];
    # merge uses the rightmost argument to take precedence
    return merge(
        $self->default_config,
        $self->panky->config->{$self->type}{HookActor}{$name},
    );
}

1;
