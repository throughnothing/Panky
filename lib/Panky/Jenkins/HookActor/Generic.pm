package Panky::Jenkins::HookActor::Generic;
use Mojo::Base 'Panky::Jenkins::HookActor';

# ABSTRACT: Generic actor to act upon Github Hook postbacks

has default_config => sub {{
    comment_on_prs => 0,
    comment_in_chat => {
        success => 0,
        failure => 1,
    }
}};

sub notification {
    my ($self, $payload) = @_;
    my $gh = $self->panky->github;
    my $chat = $self->panky->chat;

    my $name = $payload->{job_name};
    my $branch = $payload->{branch};
    my $sha = $payload->{sha};
    my $status = $self->_get_status( $payload->{status} );
    my $build_url = $self->_get_build_url( $payload );

    # If branch looks like a sha hash, do a substr of it
    $branch = substr($branch, 0, 6) if length($branch) == 40;

    # Comment on the PR if we can
    $self->_update_status( $payload );

    # Check if comment_in_chat config option is set to 1, or
    # if the specific status is set to 1
    my $c_in_chat = $self->config->{comment_in_chat};
    if ( $c_in_chat == 1 || ( $c_in_chat || {} )->{$status} ) {
        $chat->say( "[Jenkins: $name ($branch)] $status $build_url" );
    }
}


sub _update_status {
    my ($self, $payload ) = @_;

    # If we don't have a repo, we don't want to do anything
    return unless $payload->{repo};

    my $gh = $self->panky->github;
    my $build_url = $self->_get_build_url( $payload );
    my $status = lc($payload->{status} || 'failure');

    # Update the sha status with github
    $gh->set_status(
        $payload->{repo}, $payload->{sha}, $status, $build_url,
    );

    if ( $self->config->{comment_on_prs} ) {
        # Get pull requests for this job
        my $prs = $gh->get_pulls( $payload->{repo} );
        # Something bad happened
        return unless ref($prs) eq 'ARRAY';
        # Find if any PR's are using this sha
        for ( @$prs ) {
            # Set PR if we found a match based on sha
            if ( $_->{head}{sha} eq $payload->{sha} ){
                # Comment on the PR
                $gh->create_pull_comment(
                    $payload->{repo}, $_->{number},
                    $self->_comment( $payload->{sha}, uc($status), $build_url )
                );
            }
        }
    }
}

sub _comment {
    my ($self, $sha, $status, $build_url) = @_;
    "**BUILD STATUS:** `$status` ($sha, $build_url)";
}

sub _get_build_url {
    my ($self, $payload) = @_;
    my ($name, $build) = ($payload->{job_name}, $payload->{job_number});
    return $self->panky->ci->base_url . "job/$name/$build/?";
}

sub _get_status { lc( $_[1] ? $_[1] : 'failure' ) }

1;
