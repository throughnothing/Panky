use Panky::Chat::Module::DDG;
use Test::Most;

use t::lib::Base qw( panky );


my $p = panky;
my $s = $p->app->chat->sayings;
my $user = 'test-user';

$p->app->chat->tell( 'who is albert einstein', from => $user );
like pop($s)->[0] => qr/Albert Einstein/i;

# Test our regex

my $ddg = Panky::Chat::Module::DDG->new;

my %msgs = (
    'what is feces two' => 'feces two',
    'what are feces' => 'feces',
    'define feces two' => 'feces two',
    'abstract feces two' => 'feces two',
    'who is feces two three?!' => 'feces two three',
);

for my $key ( keys %msgs ) {
    my $term = $ddg->_parse_msg( $key );
    is $term => $msgs{$key}, "Found '$term' in '$key'";
}

done_testing;
