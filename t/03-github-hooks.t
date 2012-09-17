use File::Slurp qw( read_file );
use Test::Most tests => 1;

use t::lib::Base qw( panky json );

my $panky = panky;

subtest 'Pull Request Reopened Hook' => sub {
    my $pr = json->decode(
        scalar read_file('t/sample_hooks/pull_request_reopened.json')
    );

    # Check that we can post to _github and get a Thanks! response
    $panky->post_json_ok('/_github' => $pr )->content_like(qr/Thanks!/);

    # Now test that Chat->say() was called properly by HookActor::Generic
    my $sayings = $panky->app->chat->sayings;
    is @$sayings => 1, 'Said one thing on pull request' or diag explain $sayings;
    like $sayings->[0]->[0] => qr/\[dotfiles\]/, 'Had repo name';
    like $sayings->[0]->[0] => qr/git\.io/, 'Shortened url';

    # Make sure we didn't do any github requests, since no jenkins
    # builds are configured for any repos
    ok !pop @{ $panky->app->github->requests };
}
