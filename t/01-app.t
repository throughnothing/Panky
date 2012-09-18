use Test::More tests => 3;

use t::lib::Base qw( panky );

panky->get_ok('/')->status_is(200)->content_like(qr/Panky/i);
