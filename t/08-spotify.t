use t::lib::Base qw( panky );
use Test::More;

my $panky = panky;
my $sayings = $panky->app->chat->sayings;
$panky->app->chat->tell( 'spotify:artist:5lsC3H1vh9YSRQckyGv0Up',
    type => 'message' );
is @$sayings => 1, 'got 1 thing back';
like pop(@$sayings)->[0] => qr/Ellen Allien/;


done_testing;
