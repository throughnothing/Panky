package Panky::Chat::Module::DDG;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use WWW::DuckDuckGo;

# ABSTRACT: Uses the DuckDuckGo Instant Answers API

has ddg => sub { WWW::DuckDuckGo->new };

sub directed_message {
    my ($self, $msg, $from) = @_;

    # Detect twitter links
    if( $msg =~ qr{define\s+(\S+)} ) {
        my $res = $self->ddg->zeroclickinfo( $1 );
        my $def = $res->{definition} || $res->{abstract};
        if( $def ) {
            $self->say( $def );
        } else {
            $self->say( "$from: I have no fucking clue what $1 means :(" );
        }
    }

}

1;
