package Panky::Chat::Module::PerlCoreList;

use v5.10;
use Module::CoreList;
use Mojo::Base 'Panky::Chat::Module';

# ABSTRACT: Let's you see what's in perl corelist

sub directed_message { shift->message( @_ ) }

sub message {
    my ($self, $msg, $from) = @_;

    if( $msg =~ qr/corelist:?\s*(.+)$/i ) {
        my $mod = $1;
        my $ver = Module::CoreList->first_release( $mod );
        if( $ver ) {
            $self->say($from . ": '$mod' was first released with perl " . $ver);
        } else {
            $self->say($from . ": '$mod' is not in core :(");
        }
    }
}

1;
