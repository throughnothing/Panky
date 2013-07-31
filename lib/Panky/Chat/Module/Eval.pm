package Panky::Chat::Module::Eval;

use v5.10;
use JE;
use Mojo::Base 'Panky::Chat::Module';

# ABSTRACT: Let's you evaluate code

has je => sub { JE->new };

sub directed_message { shift->message( @_ ) }

sub message {
    my ($self, $msg, $from) = @_;

    if( $msg =~ qr/^(\w+):?\s*(.+)$/i ) {
        my ($lang, $code, $reval ) = ($1, $2);
        given( $lang ) {
            when( qr/perl|pl/i ) {
                $reval = $self->_run_perl( $code );
            }
            when( qr/javascript|js/i ) {
                $reval = $self->_run_js( $code );
            }
        }
        $self->say( '>> ' . $reval ) if $reval;
    }
}

sub _run_js { $_[0]->je->eval( $_[1] ) }

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
