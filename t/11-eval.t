use t::lib::Base qw( panky );
use Test::More;

my $panky = panky;
my $sayings = $panky->app->chat->sayings;

subtest 'Perl' => sub {
    $panky->app->chat->tell( 'perl: int(2**32)' );
    is @$sayings => 1, 'got 1 things back';
    like pop(@$sayings)->[0] => qr/>> @{[ 2**32 ]}/, 'Got 2^32';

    $panky->app->chat->tell( 'perl: $a = 14; ++$a;', type => 'message' );
    is @$sayings => 1, 'got 1 things back';
    like pop(@$sayings)->[0] => qr/>> 15/, 'Got 15';

    $panky->app->chat->tell( 'perl: sub foo { ++$_[0] }; $a = 5; foo($a);' );
    is @$sayings => 1, 'got 1 things back';
    like pop(@$sayings)->[0] => qr/>> 6/, 'Got 6';
};


subtest 'Javascript' => sub {
    $panky->app->chat->tell( 'js: 5 + 2', type => 'message' );
    is @$sayings => 1, 'got 1 things back';
    like pop(@$sayings)->[0] => qr/>> 7/, 'Got 7';

    $panky->app->chat->tell(
        'javascript: var a = function(b){ return b+1; }; a(2) + 7;' );
    is @$sayings => 1, 'got 1 things back';
    like pop(@$sayings)->[0] => qr/>> 10/, 'Got 10';
};

done_testing;
