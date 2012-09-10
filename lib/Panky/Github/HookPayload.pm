package Panky::Github::HookPayload;
use Exporter 'import';
use Hash::AsObject;

our @EXPORT_OK = qw( parse branch_from_ref );

# ABSTRACT: Payload object for Github Repository Hooks

# %types stores the fields that are needed to
# identify each payload type from Github:
# http://developer.github.com/v3/events/types/
my %types = (
    pull_request => [ qw( action number pull_request ) ],
    push  => [ qw( after ref commits ) ],
    commit_comment  => [ qw( comment ) ],
    # TODO: figure out if pull_request_review_comment
    # is any different/distinguishable from commit_comment
    # pull_request_review_comment  => [ qw( comment ) ],
);

sub parse {
    my ( $payload ) = @_;

    my $data = Hash::AsObject->new( $payload );

    # Set the payload type
    $data->type( _determine_type( $payload ) );

    return $data
}

# Determines the 'type' of the payload
sub _determine_type {
    my ($payload) = @_;

    for my $k ( keys %types ) {
        # Check if *all* keys exist on the payload
        return $k if $types{$k} ~~ sub{ $payload->{$_[0]} };
    }
}

1;

=head1 SYNOPSIS

This module represents a parsed payload from a Github
L<Repo Hook|http://developer.github.com/v3/repos/hooks/> post request received
by the server.
