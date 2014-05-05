package Panky::Chat::Module::Github;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use WWW::Shorten 'GitHub';

# ABSTRACT: Handles github action requests from users in chatroom

sub message {
    my ($self, $msg, $from) = @_;
    my $gh = $self->panky->github;

    # Detect links to github
    if( $msg =~ qr{(https?://github.com/(\S+))} ) {
        my @parts = split qr{/}, $2, 5;
        my $nwo = join '/', @parts[0,1];

        my ( $type, $user, $body ) = ('', '', '');
        given( \@parts ) {
            # When its a commit
            when ( @$_ > 2 and $_->[2] eq 'commit' ){
                my $sha = $type = substr( $parts[3], 0, 6);
                my $commit = $gh->get_commit( $nwo, $sha );
                # Get the first line only
                $body = ( split /\n/, $commit->{commit}{message} )[0];
                $user = $commit->{author}{login};
            }
            # When its a pull request
            when ( @$_ > 2 and $_->[2] eq 'pull' ) {
                $type = "PR-$_->[3]";
                my $pr = $gh->get_pull( $nwo, $_->[3] );
                $body = $pr->{title};
                $user = $pr->{user}{login};
            }
            # When its a blob or a tree
            when ( @$_ > 2 and ( $_->[2] eq 'blob' || $_->[2] eq 'tree' ) ) {
                $type = $_->[3];
                $body = "/$_->[4]";
            }
        }

        # Format message
        $user = "($user)" if $user;
        my $msg = "[$type]$user $body";

        $self->say( $msg ) if $type && $body;
    }
}

sub directed_message {
    my ($self, $msg, $from) = @_;
    my $gh = $self->panky->github;

    given( $msg ) {
        when( /gh help/ ) {
            $self->help( $from );
            return 1;
        }
        when( /gh setup (\S+)/ ) {
            # Setup a hook for a repo
            $gh->create_hook( $1 );
            $self->say( "$from: Setup $1!" );
            return 1;
        }
        when( /gh test-hooks (\S+)/ ) {
            # Test the specified hook
            $gh->test_hook( $1 );
            return 1;
        }
        when( /gh prs (\S+)( \+[sS])?/ ){
            my $repo = $self->_get_repo( $1 );
            # List pull requests for a repo
            my $prs = $self->panky->github->get_pulls( $repo );

            return $self->say( "No open PRs for $repo!" )
                unless ref $prs eq 'ARRAY';

            for ( @$prs ) {
                my $url = makeashorterlink( $_->{html_url} );
                my ($number, $title) = ($_->{number}, $_->{title});

                my $state = '';
                # If we asked for states (+s)
                if( $2 ) {
                    # Get status of HEAD commit
                    my $nwo = $_->{head}{repo}{full_name};
                    my $sha = $_->{head}{sha};
                    my $res = $gh->get_status( $nwo, $sha );
                    $state = ref($res) eq 'ARRAY' ?
                                $res->[0]{state} : 'unknown';
                    $state = " (state: $state) ";
                }
                $self->say( "$number: $title$state- $url" );
            }
            return 1;
        }
        when ( /gh set repo (\S+) => (\S+)/ ) {
            # Add a repo mapping
            $self->_set_repo_alias( $1, $2 );
            $self->say( "$from: got it!" );
            return 1;
        }
        when ( /gh unset repo (\S+)/ ) {
            # Remove a repo mapping
            $self->_unset_repo_alias( $1 );
            $self->say( "$from: repo alias removed!" );
            return 1;
        }
        when ( /gh show repo (\S+)/ ) {
            # Show a repo mapping
            my $repo = $self->_get_repo( $1, $2 );
            $repo = ($repo eq $1) ? 'none' : $repo;
            $self->say( "$from: $1 => $repo" );
            return 1;
        }
        when ( /test (\S+) (pr \d+|([0-9a-f]{5,40}))/ ) {
            # Match retesting a pr or a hash
            my $repo = $self->_get_repo( $1 );

            # See if we have a Jenkins Build for this repo
            my $job_name = $self->panky->ci->job_for_repo( $repo );
            unless ($job_name) {
                $self->say( "No jobs found for $repo!" );
                return 1;
            }

            my $sha = $2;
            # If we were given a PR, we must get the head sha1 of it
            if( $sha ~~ /^pr (\d+)/ ) {
                my $pr_num = $1;
                my $pr = $self->panky->github->get_pull( $repo, $pr_num );
                unless ( $pr && $pr->{head} && $pr->{head}{sha} ){
                    $self->say("$from: Error getting $repo PR $pr_num!");
                    return 1;
                }
                $sha = $pr->{head}{sha};
            }

            my $short_sha = substr $sha, 0, 6;
            # Start a build on CI
            $self->panky->ci->build( $job_name, $sha );
            # Update github status to pending
            $gh->set_status( $repo, $sha, 'pending' );

            $self->say( "$from: Testing $repo $short_sha ($job_name)...");
            return 1;
        }
    }
}

sub help {
    my ($self, $from) = @_;
    $self->say( "$from: gh setup repo # Setup webhooks for repo");
    $self->say( "$from: gh set repo org/repo => alias");
    $self->say( "$from: gh unset repo alias");
    $self->say( "$from: gh show repo alias");
    $self->say( "$from: gh prs repo|alias [+s]" );
    $self->say( "$from: gh test repo|alias SHA|pr ##");
};

# Get the full repo name.
# Will return the repo name from an alias if set, otherwise it will return
# whatever was passed in
sub _get_repo {
    my ($self, $name) = @_;
    return unless $name;
    ($self->panky->storage_get( 'repo_aliases' ) || {})->{$name} || $name;
}

# Set an alias in storage for a repo
sub _set_repo_alias {
    my ($self, $alias, $repo) = @_;
    return unless $alias && $repo;

    my $aliases = $self->panky->storage_get( 'repo_aliases' ) || {};
    $aliases->{ $alias } = $repo;
    $self->panky->storage_put( 'repo_aliases' => $aliases )
}

# Remove an alias in storage for a repo
sub _unset_repo_alias {
    my ($self, $alias) = @_;
    return unless $alias;

    my $aliases = $self->panky->storage_get( 'repo_aliases' ) || {};
    delete $aliases->{ $alias };
    $self->panky->storage_put( 'repo_aliases' => $aliases )
}

1;
