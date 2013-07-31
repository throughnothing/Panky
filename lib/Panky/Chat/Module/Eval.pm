package Panky::Chat::Module::Eval;

use v5.10;
use Mojo::Base 'Panky::Chat::Module';

# ABSTRACT: Let's you evaluate code

sub directed_message { shift->message( @_ ) }

sub message {
    my ($self, $msg, $from) = @_;

    if( $msg =~ qr/^perl:?\s*(.+)$/i ) {
        my $reval = $self->_run_perl( $1 );
        $self->say( '>> ' . $reval ) if $reval;
    }
}

sub _run_perl {
    my ($self, $code) = @_;

    # Taken from App::EvalServer;
    local $@   = undef;
    local @INC = undef;
    local $_   = undef;
 
    $code = "no strict; no warnings; package main; $code";
    my $ret = eval $code;
 
    print STDERR $@ if length($@);
    return $ret;
}

1;
