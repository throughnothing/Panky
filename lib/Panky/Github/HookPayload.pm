package Panky::Github::HookPayload;
use Mojo::Base -base;
use Exporter 'import';

# ABSTRACT: Payload object for Github Repository Hooks

# Modeling off of:
# https://github.com/github/janky/blob/master/lib/janky/github/payload_parser.rb

our @EXPORT_OK = qw( parse );

has [qw( pusher head compare commits uri branch )];

# Parse out a Github Receive-Hook Payload
sub parse {
    my ($json) = @_;
    return Panky::Github::HookPayload->new(
        pusher => $json->{pusher}{name},
        head   => $json->{after},
        compare => $json->{compare},
        commits => _parse_commits( $json->{commits} ),
        branch => (split qr{refs/heads/}, $json->{ref})[-1],
    );
}

# Show "Author <email>" If email is set
sub _normalize_author {
    $_[0]->{email} ? "$_[0]->{name} <$_[0]->{email}>" : $_[0]->{name};
}

sub _parse_commits {
    my ($commits) = @_;
    for( @$commits ) {
        # We don't care about these fields
        delete @{$_}{qw( added removed modified )};
        $_->{author} = _normalize_author( $_->{author} );
    }
    return $commits;
}

1;

=head1 SYNOPSIS

This module represents a parsed payload from a Github
L<Repo Hook|http://developer.github.com/v3/repos/hooks/> post request received
by the server.
