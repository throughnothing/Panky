package Panky::Chat::Module::Tell;

use v5.10;
use Mojo::Base 'Panky::Chat::Module';

# ABSTRACT: Let's you tell other people stuff


sub directed_message {
    my ($self, $msg, $from) = @_;

    if( $msg =~ qr/tell\s+([^:\s]+)\s+(?:to|that)?\s*(.+)$/i ) {
        my ($user, $phrase) = ($1, $2);
        for( $phrase ) {
            s/his/your/g;
            s/her/your/g;
            s/she'?s/you're/g;
            s/he'?s/you're/g;
        }
        $self->say("$user: $phrase");
    }
}

1;
