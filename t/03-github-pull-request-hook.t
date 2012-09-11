use File::Slurp qw( read_file );
use Mojo::JSON;
use Test::Mojo;
use Test::Most tests => 5;

use t::lib::Base qw( sayings );

BEGIN {
    # Make sure we use the default (empty) CHAT
    $ENV{PANKY_CHAT} = undef;
    $ENV{PANKY_CHAT_JABBER_JID} = undef;
}

my $t = Test::Mojo->new('Panky');
my $json = Mojo::JSON->new;
my $pr = $json->decode(
    scalar read_file('t/sample_hooks/pull_request_reopened.json')
);

# Check that we can post to _github and get a Thanks! response
$t->post_json_ok('/_github' => $pr )->content_like(qr/Thanks!/);

# Now test that Chat->say() was called properly by HookActor::Generic
my $sayings = sayings();
is @$sayings => 1, 'Said one thing on pull request' or diag explain $sayings;
like $sayings->[0]->[1] => qr/\[dotfiles\]/;
like $sayings->[0]->[1] => qr/git\.io/;


