use t::lib::Base qw( panky );
use Test::Most;

$ENV{TINYSONG_API_KEY} = "d59de0925d72e26442b85383769f4654";
$ENV{PANKY_HAILO_BRAINFILE} = 'panky.trn';

my $panky = panky;
my $sayings = $panky->app->chat->sayings;
$panky->app->chat->tell( 'song: dream on aerosmith' );
is @$sayings => 1, 'got 1 things back';
like pop(@$sayings)->[0] => qr/Dream On/, 'Got Dream On';

my @panky_words = qw(hello hi welcome work weather space science war peace);
for (@panky_words) {
    $panky->app->chat->tell($_, type => 'message');
    is @$sayings => 0, 'got 0 things back from message';
    $panky->app->chat->tell($_, type => 'directed_message');
    is @$sayings => 1, 'got 1 things back';
    my $reply = pop(@$sayings)->[0];
    is $reply =~ /$_/i => 1, "Sent $_, Received $reply";
}

done_testing;
