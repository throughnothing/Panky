package Panky::Chat::Module::Github;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use WWW::Shorten 'GitHub';

# ABSTRACT: Handles github action requests from users in chatroom

sub message {
    my ($self, $msg, $from) = @_;

    # Detect links to github
    if( $msg =~ qr{(https?://github.com/(\S+))} ) {
        my @parts = split qr{/}, $2, 5;

        my $type;
        given( \@parts ) {
            # When its a commit
            when ( @$_ > 2 and $_->[2] eq 'commit' ){
                $type = substr( $parts[3], 0, 6)
            }
            # When its a pull request
            when ( @$_ > 2 and $_->[2] eq 'pull' ) {
                $type = "PR-$_->[3]";
            }
            # When its a blob or a tree
            when ( @$_ > 2 and ( $_->[2] eq 'blob' || $_->[2] eq 'tree' ) ) {
                $type = "($_->[3])/$_->[4]";
            }
        }

        # Shorten found github links
        my $link = makeashorterlink( $1 );

        # Format message
        $type = $type ? " $type" : '';
        my $msg = "[$parts[0]/$parts[1]$type] $link";

        $self->say( $msg );
    }
}

sub directed_message {
    my ($self, $msg, $from) = @_;
    my $gh = $self->panky->github;

    given( $msg ) {
        # Setup a hook for a repo
        when( /gh setup (\S+)/ ) {
            $gh->create_hook( $1 );
            $self->say( "$from: Setup $1!" );
        }
        # Test the specified hook
        when( /gh test-hooks (\S+)/ ) {
            $gh->test_hook( $1 );
        }
    }
}

1;
