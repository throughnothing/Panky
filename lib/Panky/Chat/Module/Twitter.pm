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
    if( $msg =~ qr{https?://twitter.com/\S+/status/(\S+)$} ) {
        my $json = $self->ua->get( "$t_base/$1.json" )->res->json;
        $self->say( "\@$json->{user}{screen_name}: $json->{text}" ) if $json;
    }

}

1;
