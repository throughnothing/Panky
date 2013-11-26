use Test::Most;

use t::lib::Base qw( panky );

my $p = panky;
my $s = $p->app->chat->sayings;
my $user = 'test-user';

$p->app->chat->tell( 'bitcoin getdifficulty', from => $user );
like pop(@$s)->[0] => qr/$user: getdifficulty\s*.\s*\d+/;

$p->app->chat->tell(
    'bitcoin addressbalance 1VgGq1dWsCz1mSpZXhHHko2XuXZWnfwyp',
    from => $user
);
like pop(@$s)->[0] => qr/$user: addressbalance\s*.\s*\d+/;

$p->app->chat->tell('2.5 in btc', from => $user, type => 'message');
like pop(@$s)->[0] => qr/$2.5 is \d+\.\d+BTC/;

done_testing;
