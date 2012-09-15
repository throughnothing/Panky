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

        $self->say( $msg );
    }
}

sub directed_message {
    my ($self, $msg, $from) = @_;
    my $gh = $self->panky->github;

    given( $msg ) {
        when( /gh setup (\S+)/ ) {
            # Setup a hook for a repo
            $gh->create_hook( $1 );
            $self->say( "$from: Setup $1!" );
        }
        when( /gh test-hooks (\S+)/ ) {
            # Test the specified hook
            $gh->test_hook( $1 );
        }
        when( /pulls (\S+)/ ){
            # List pull requests for a repo
            my $prs = $self->panky->github->get_pulls( $1 );

            return $self->say( "No open PRs for $1!" ) unless @$prs;

            for ( @$prs ) {
                my $url = makeashorterlink( $_->{html_url} );
                my $title = $_->{title};
                $self->say( "$title - $url" );
            }
        }
    }
}

1;
