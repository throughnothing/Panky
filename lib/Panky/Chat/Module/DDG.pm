package Panky::Chat::Module::DDG;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use WWW::DuckDuckGo;

# ABSTRACT: Uses the DuckDuckGo Instant Answers API

has ddg => sub { WWW::DuckDuckGo->new };

sub directed_message {
    my ($self, $msg, $from) = @_;

    my $term = $self->_parse_msg( $msg );
    return unless $term;

    my $res = $self->ddg->zeroclickinfo( $term );
    my $def = $res->{definition} || $res->{abstract} || $res->{abstract_text};
    if( $def ) {
        $self->say( $def );
    } else {
        $self->say( "$from: I have no fucking clue what $term means :(" );
    }
}

sub _parse_msg {
    my ($self, $msg) = @_;

    if( $msg =~ qr{(define|abstract|((what|who)\s(does|is(\s+a)?|are)))\s+([^?!]+)([?!\s]+)?$}i ) {
        return $6;
    }
}

1;
