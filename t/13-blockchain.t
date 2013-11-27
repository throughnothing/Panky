use Test::Most;

use t::lib::Base qw( panky );

my $p = panky;
my $s = $p->app->chat->sayings;
my $user = 'test-user';

$p->app->chat->tell( 'bitcoin getdifficulty', from => $user );
like pop(@$s)->[0] => qr/getdifficulty\s*.\s*\d+/;

$p->app->chat->tell(
    'bitcoin addressbalance 1VgGq1dWsCz1mSpZXhHHko2XuXZWnfwyp',
    from => $user
);
like pop(@$s)->[0] => qr/addressbalance\s*.\s*\d+/;

$p->app->chat->tell('2.5 in btc', from => $user, type => 'message');
like pop(@$s)->[0] => qr/\$2.5 is \d+\.\d+BTC/;

$p->app->chat->tell('bitcoin price', from => $user, type => 'message');
like pop(@$s)->[0] => qr/\$\d+(\.\d+)?/;

$p->app->chat->tell('0.56 bitcoins', from => $user, type => 'message');
like pop(@$s)->[0] => qr/\d+(\.\d+)?BTC => \$\d+(\.\d+)?/;

$p->app->chat->tell('0.56 bitcoins in EUR', from => $user, type => 'message');
like pop(@$s)->[0] => qr/\d+(\.\d+)?BTC => \x{20ac}\d+(\.\d+)?/;

done_testing;
