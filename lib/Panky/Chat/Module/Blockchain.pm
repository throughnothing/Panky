package Panky::Chat::Module::Blockchain;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use Blockchain;

# ABSTRACT: Handles github action requests from users in chatroom

has blockchain => sub { Blockchain->new };

sub message {
    my ($self, $msg, $from) = @_;
    given ( $msg ) {
        when( /(bitcoin|btc) (\S+)\s?(\S+)?/i ) {
            my $cmd = $2 =~ s/^24/tf/r;
            my $arg1 = $3;
            if( $self->blockchain->can( $cmd ) ) {
                my $res = $self->blockchain->$cmd( $3 );
                $self->say("$cmd: $res") if $res;
            }
        }
        when (/(\d+(\.\d+)?)\s?(btc|bitcoins?)( in (\S+))?/i) {
            my $exchange = $self->blockchain->cur_rate( $5 );
            return unless $exchange;
            my $btc_amt = $1;
            my $cur_amt = $exchange->{symbol} .
                sprintf( "%.2f", $exchange->{last} * $btc_amt );
            $self->say("$1BTC => $cur_amt");
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
        when( /(bitcoin|btc) help/i ) { $self->help( $from ) }
    }
}

sub help {
    my ($self, $from) = @_;
    for( @{ $self->blockchain->methods } ) {
        $self->say( "$from: bitcoin $_ ...");
    }
};

1;
