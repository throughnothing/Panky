use t::lib::Base qw( panky );
use Test::More;

$ENV{TINYSONG_API_KEY} = "d59de0925d72e26442b85383769f4654";

my $panky = panky;
my $sayings = $panky->app->chat->sayings;
$panky->app->chat->tell( 'song: dream on aerosmith' );
is @$sayings => 1, 'got 1 things back';
like pop(@$sayings)->[0] => qr/Dream On/, 'Got Dream On';

$panky->app->chat->tell( '3song: dream on', type => 'message' );
is @$sayings => 3, 'got 3 things back';

$panky->app->chat->tell( '2songs about dream on', type => 'message' );
is @$sayings => 5, 'got 2 things back';

done_testing;
