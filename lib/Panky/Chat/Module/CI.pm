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
            return 1;
        }
        when ( /ci unset repo (\S+)/ ) {
            # Remove a repo mapping
            $self->_unset_repo_job( $1 );
            $self->say( "$from: repo job removed!" );
            return 1;
        }
        when ( /ci show repo (\S+)/ ) {
            # Show a repo mapping
            my $repo = $self->_get_job( $1, $2 );
            $repo = ($repo eq $1) ? 'none' : $repo;
            $self->say( "$from: $1 => $repo" );
            return 1;
        }
        when ( /ci run (\S+)/ ) {
            # See if we have a Jenkins Build for this repo
            my $job_name = $1;
            my $res = $self->panky->ci->build( $job_name );
            $self->say( "$from: building $job_name..." );
            return 1;
        }
    }
}

# Get the job for a repo
sub _get_job {
    my ($self, $repo) = @_;
    return unless $repo;

    $repo = lc($repo);
    ($self->panky->storage_get( 'repo_jobs' ) || {})->{$repo} || $repo;
}

# Set a job name in storage for a repo
sub _set_repo_job {
    my ($self, $repo, $job) = @_;
    return unless $repo && $repo;
    $repo = lc($repo);

    my $repos = $self->panky->storage_get( 'repo_jobs' ) || {};
    $repos->{ $repo } = $job;
    $self->panky->storage_put( 'repo_jobs' => $repos )
}

# Remove a job name in storage for a repo
sub _unset_repo_job {
    my ($self, $repo) = @_;
    return unless $repo;
    $repo = lc($repo);

    my $repos = $self->panky->storage_get( 'repo_jobs' ) || {};
    delete $repos->{ $repo };
    $self->panky->storage_put( 'repo_jobs' => $repos )
}

1;

=head1 SYNOPSIS

This module allows you to manage mappings from github repos to CI jobs.

    > panky: ci set repo user1/repo1 => jenkins-job-name
    > panky: ci unset repo user1/repo1
    > panky: ci show repo user1/repo
