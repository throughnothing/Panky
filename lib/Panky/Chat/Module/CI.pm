package Panky::Chat::Module::CI;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';

# ABSTRACT: Handles github action requests from users in chatroom

sub directed_message {
    my ($self, $msg, $from) = @_;
    my $gh = $self->panky->github;

    given( $msg ) {
        when ( /ci set repo (\S+) => (\S+)/ ) {
            # Add a repo mapping
            $self->_set_repo_job( $1, $2 );
            $self->say( "$from: got it!" );
        }
        when ( /ci unset repo (\S+)/ ) {
            # Remove a repo mapping
            $self->_unset_repo_job( $1 );
            $self->say( "$from: repo job removed!" );
        }
        when ( /ci show repo (\S+)/ ) {
            # Show a repo mapping
            my $repo = $self->_get_job( $1, $2 );
            $repo = ($repo eq $1) ? 'none' : $repo;
            $self->say( "$from: $1 => $repo" );
        }
    }
}

# Get the job for a repo
sub _get_job {
    my ($self, $repo) = @_;
    return unless $repo;

    $repo = lc($repo);
    ($self->panky->ci->storage->get( 'repo_jobs' ) || {})->{$repo} || $repo;
}

# Set a job name in storage for a repo
sub _set_repo_job {
    my ($self, $repo, $job) = @_;
    return unless $repo && $repo;
    $repo = lc($repo);

    my $repos = $self->panky->ci->storage->get( 'repo_jobs' ) || {};
    $repos->{ $repo } = $job;
    $self->panky->ci->storage->put( 'repo_jobs' => $repos )
}

# Remove a job name in storage for a repo
sub _unset_repo_job {
    my ($self, $repo) = @_;
    return unless $repo;
    $repo = lc($repo);

    my $repos = $self->panky->ci->storage->get( 'repo_jobs' ) || {};
    delete $repos->{ $repo };
    $self->panky->ci->storage->put( 'repo_jobs' => $repos )
}

1;

=head1 SYNOPSIS

This module allows you to manage mappings from github repos to CI jobs.

    > panky: ci set repo user1/repo1 => jenkins-job-name
    > panky: ci unset repo user1/repo1
    > panky: ci show repo user1/repo
