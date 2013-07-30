use File::Slurp qw( read_file );
use Test::Most tests => 3;
use Mojo::Message::Response;

use t::lib::Base qw( panky json );

subtest 'Pull Request Reopened Hook, No Jenkins' => sub {
    my $panky = panky;
    my $pr = json->decode(
        scalar read_file('t/sample_hooks/pull_request_reopened.json')
    );

    # Check that we can post to _github and get a Thanks! response
    $panky->post_ok('/_github' => json => $pr )->content_like(qr/Thanks!/);

    # Now test that Chat->say() was called properly by HookActor::Generic
    my $sayings = $panky->app->chat->sayings;
    is @$sayings => 1, 'Said one thing on pull request' or explain $sayings;
    like $sayings->[0]->[0] => qr/\[dotfiles\]/, 'Had repo name';
    like $sayings->[0]->[0] => qr/git\.io/, 'Shortened url';

    # Make sure we didn't do any github requests, since no jenkins
    # builds are configured for any repos
    my $gh_reqs = $panky->app->github->requests;
    is @$gh_reqs => 0, 'No github requests sent' or explain $gh_reqs;
};

subtest 'Pull Request Reopened Hook, With Jenkins' => sub {
    my $panky = panky;
    my $pr = json->decode(
        scalar read_file('t/sample_hooks/pull_request_reopened.json')
    );

    # Setup Jenkins Job for repo
    my $sayings = $panky->app->chat->sayings;
    $panky->app->chat->tell( 'ci set repo throughnothing/dotfiles => job-1');
    like pop(@$sayings)->[0] => qr/got it/;

    # Check that we can post to _github and get a Thanks! response
    $panky->post_ok('/_github' => json => $pr )->content_like(qr/Thanks!/);

    # Now test that Chat->say() was called properly by HookActor::Generic
    is @$sayings => 1, 'Said one thing on pull request' or explain $sayings;
    like $sayings->[0]->[0] => qr/\[dotfiles\]/, 'Had repo name';
    like $sayings->[0]->[0] => qr/git\.io/, 'Shortened url';

    # Check the github request
    my $gh_reqs = $panky->app->github->requests;
    is @$gh_reqs => 1, 'Got 1 github request';
    like $gh_reqs->[0][1] => qr{repos/throughnothing/dotfiles/statuses/ea8};
    is $gh_reqs->[0][2]{state} => 'pending';

    # Check the jenkins request
    my $ci_reqs = $panky->app->ci->requests;
    is @$ci_reqs => 1, 'Got 1 CI request';
    is $ci_reqs->[0][1] => 'job/job-1/build';
    is_deeply $ci_reqs->[0][2]{parameter} => {
        name => 'HEAD',
        value => 'ea8596c287758cc292b8734c2cabf2f5e9b9ec23',
    };
};

subtest 'Pull Request Reopened Hook, With Bad Jenkins Res' => sub {
    my $panky = panky;
    my $pr = json->decode(
        scalar read_file('t/sample_hooks/pull_request_reopened.json')
    );

    # Setup Jenkins Job for repo
    my $sayings = $panky->app->chat->sayings;
    $panky->app->chat->tell( 'ci set repo throughnothing/dotfiles => job-1');
    like pop(@$sayings)->[0] => qr/got it/;


    my $bad_res = Mojo::Message::Response->new;
    $bad_res->code( 500 );
    push @{$panky->app->ci->responses}, $bad_res;
    # Check that we can post to _github and get a Thanks! response
    $panky->post_ok('/_github' => json => $pr )->status_is( 500 );

    # Now test that Chat->say() was called properly by Failed Jenkins Res
    is @$sayings => 1, 'Said one thing on pull request' or explain $sayings;
    like $sayings->[0]->[0] => qr/error starting/, 'Said about jenkins error';
};
