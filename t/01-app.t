use Mojo::Base 't::lib::Base';

use Test::More tests => 3;
use Test::Mojo;

my $t = Test::Mojo->new('Panky');
$t->get_ok('/')->status_is(200)->content_like(qr/Panky/i);