use t::lib::Base qw( panky );
use Test::More;

my $panky = panky;
my $sayings = $panky->app->chat->sayings;

$panky->app->chat->tell( 'tell will to shut up' );
is @$sayings => 1, 'got 1 things back';
like pop(@$sayings)->[0] => qr/will: shut up/;

$panky->app->chat->tell( 'tell will hes silly' );
is @$sayings => 1, 'got 1 things back';
like pop(@$sayings)->[0] => qr/will: you're silly/;

$panky->app->chat->tell( 'tell jen that she\'s silly' );
is @$sayings => 1, 'got 1 things back';
like pop(@$sayings)->[0] => qr/jen: you're silly/;


done_testing;
