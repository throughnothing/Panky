package Panky::Chat::Module::DDG;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use WWW::DuckDuckGo;

# ABSTRACT: Uses the DuckDuckGo Instant Answers API

has ddg => sub { WWW::DuckDuckGo->new };

sub directed_message {
    my ($self, $msg, $from) = @_;

    # Detect twitter links
    if( $msg =~ qr{(define|abstract|(what\s(does|is(\s+a)?|are)))\s+(.+)$}i ) {
        my $term = $5;
        my $res = $self->ddg->zeroclickinfo( $term );
        my $def = $res->{definition} || $res->{abstract};
        if( $def ) {
            $self->say( $def );
        } else {
            $self->say( "$from: I have no fucking clue what $term means :(" );
        }
    }

}

1;
