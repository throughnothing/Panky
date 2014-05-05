package Panky::Chat::Module::DDG;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use WWW::DuckDuckGo;
use Regexp::Assemble;

# ABSTRACT: Uses the DuckDuckGo Instant Answers API

has ddg => sub { WWW::DuckDuckGo->new };
has re => sub {
    Regexp::Assemble->new
        ->add( 'define\s+([^?!]+)[?!]*$' )
        ->add( 'abstract\s+([^?!]+)[?!]*$' )
        ->add( '(?:what\'?s?|who\'?s?)\s*(?:is|are|does)?\s+([^?!]+)[?!]*$' )
    ;
};

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
    return 1;
}

sub _parse_msg {
    my ($self, $msg) = @_;

    my $re = $self->re;
    if( $msg =~ /$re/ ) {
        return $1;
    }
}

1;
