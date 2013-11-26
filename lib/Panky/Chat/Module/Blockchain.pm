package Panky::Chat::Module::Blockchain;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use Blockchain;

# ABSTRACT: Handles github action requests from users in chatroom

has blockchain => sub { Blockchain->new };

sub message {
    my ($self, $msg, $from) = @_;
    given ( $msg ) {
        when (/bitcoin price/) {
            $self->say( "BTC 24hr price: " . $self->blockchain->tfhprice );
        }
        when (/(\d+.?(\d+)?) in (btc|bitcoin)/i) {
            $self->say(
                "\$$1 is " .
                $self->blockchain->tobtc( $1 ) .
                "BTC"
            );
        }
    }
}

sub directed_message {
    my ($self, $msg, $from) = @_;
    given( $msg ) {
        when( /bitcoin help/ ) { $self->help( $from ) }
        when( /bitcoin (\S+)\s?(\S+)?/ ) {
            my $cmd = $1 =~ s/^24/tf/r;
            my $arg1 = $2;
            if( $self->blockchain->can( $cmd ) ) {
                my $res = $self->blockchain->$cmd( $2 );
                $self->say("$from: $cmd - $res") if $res;
            }
        }
    }
}

sub help {
    my ($self, $from) = @_;
    for( @{ $self->blockchain->methods } ) {
        $self->say( "$from: bitcoin $_ ...");
    }
};

1;
