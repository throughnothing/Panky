package Panky::Chat::Module::Twitter;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use Mojo::UserAgent;

# ABSTRACT: Expands tweets posted in channel

my $t_base = 'https://api.twitter.com/1/statuses/show';

has ua => sub { Mojo::UserAgent->new };

sub message {
    my ($self, $msg, $from) = @_;

    # Detect twitter links
    if( $msg =~ qr{(https?://twitter.com/\S+/status/\S+)$} ) {
        my $res = $self->ua->get( $1 )->res;
        my $user = $res->dom('div.tweet div.content span.username b')->first->text;
        my $tweet = $res->dom('div.tweet p.tweet-text')->first->text;
        $self->say( "\@$user: $tweet" ) if $user && $tweet;
    }

}

1;
