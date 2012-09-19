use Test::Most;

use t::lib::Base qw( panky );

my $p = panky;
my $s = $p->app->chat->sayings;
my $user = 'test-user';

$p->app->chat->tell( 'gh set repo test => user1/test', from => $user );
is pop(@$s)->[0] => "$user: got it!";

$p->app->chat->tell( 'gh show repo test', from => $user );
is pop($s)->[0] => "$user: test => user1/test";

$p->app->chat->tell( 'gh unset repo test', from => $user );
is pop($s)->[0] => "$user: repo alias removed!";

$p->app->chat->tell( 'gh show repo test', from => $user );
is pop($s)->[0] => "$user: test => none";

done_testing;
