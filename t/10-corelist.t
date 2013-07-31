use t::lib::Base qw( panky );
use Test::More;

my $panky = panky;

my $sayings = $panky->app->chat->sayings;
$panky->app->chat->tell( 'corelist: lib' );
is @$sayings => 1, 'got 1 things back';
like pop(@$sayings)->[0] => qr/'lib' was first released with perl 5\.001/;

$panky->app->chat->tell( 'corelist: lib', type => 'message' );
is @$sayings => 1, 'got 1 things back';
like pop(@$sayings)->[0] => qr/'lib' was first released with perl 5\.001/;

$panky->app->chat->tell( 'corelist: JSON', type => 'message' );
is @$sayings => 1, 'got 1 things back';
like pop(@$sayings)->[0] => qr/'JSON' is not in core :\(/;

done_testing;
