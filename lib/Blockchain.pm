package Blockchain;
use Mojo::Base -base;
use Mojo::UserAgent;
use URI;

has ua => sub { Mojo::UserAgent->new };
has base_url => 'https://blockchain.info/';
has methods => sub {[qw/
    getdifficulty
    getblockcount
    latesthash
    bcperblock
    totalbc
    probability
    hashestowin
    nextretarget
    avgtxsize
    avgtxvalue
    interval
    eta
    avgtxnumber
    tfhrprice
    tfhrtransactioncount
    tfhrbtcsent
    marketcap
    hashrate
    unconfirmedcount
/]};

sub getdifficulty { shift->_q_req( '/getdifficulty' ) }
sub getblockcount { shift->_q_req( '/getblockcount' ) }
sub latesthash { shift->_q_req( '/latesthash' ) }
sub bcperblock { shift->_q_req( '/bcperblock' ) / 100000000 }
sub totalbc { shift->_q_req( '/totalbc' ) / 100000000 }
sub probability { shift->_q_req( '/probability' ) }
sub hashestowin { shift->_q_req( '/hashestowin' ) }
sub nextretarget { shift->_q_req( '/nextretarget' ) }
sub avgtxsize { shift->_q_req( '/avgtxsize' ) }
sub avgtxvalue { shift->_q_req( '/avgtxvalue' ) / 100000000 }
sub interval { shift->_q_req( '/interval' ) }
sub eta { shift->_q_req( '/eta' ) }
sub avgtxnumber { shift->_q_req( '/avgtxnumber' ) }
sub tfhrprice { shift->_q_req( '/24hrprice' ) }
sub tfhrtransactioncount { shift->_q_req( '/24hrtransactioncount' ) }
sub tfhrbtcsent { shift->_q_req( '/24hrbtcsent' ) }
sub marketcap { shift->_q_req( '/marketcap' ) }
sub hashrate { shift->_q_req( '/hashrate' ) }
sub unconfirmedcount { shift->_q_req( '/unconfirmedcount' ) }

sub getreceivedbyaddress { $_[0]->_q_req('/getreceivedbyaddress/', $_[1]) / 100000 }
sub getsentbyaddress { $_[0]->_q_req('/getsentbyaddress/', $_[1]) / 100000 }
sub addressbalance { $_[0]->_q_req('/addressbalance/', $_[1]) / 100000000 }
sub addressfirstseen { $_[0]->_q_req('/addressfirstseen/', $_[1]) / 100000000 }

sub cur_rate {
    my ($self, $cur) = @_;
    $cur = $cur ? uc($cur) : 'USD';
    my $res = $self->ua->get( $self->base_url . '/ticker' )->res->json;
    return $res->{$cur} || $res->{USD};
}

sub tobtc {
    my ($self, $val, $currency) = @_;
    $currency ||= 'USD';

    $self->ua->get($self->base_url . "tobtc?currency=$currency&value=$val")
        ->res->body;
}

sub _q_req {
    my($self, $path, @params) = @_;
    $self->ua->get($self->base_url . join('/','q',$path,@params))->res->body;
}

sub _json_req {
    my($self, $path) = @_;
    $self->ua->get($self->base_url . join('/','api',$path ))->res->json;
}

1;
