use Mojo::Util qw( url_escape );
use Test::Most tests => 4;

use t::lib::Base qw( panky json );

my $panky = panky;
my $conf = $panky->app->config->{Jenkins}{HookActor}{Generic};
my $data = {
    repo => 'repo/user',
    sha => 'abc123',
    status => 'success',
    job_name => 'Jenkins-Job',
    job_number => '8',
    branch => 'git_branch'
};

subtest 'Build Success Hook w/chat, no pr comment' => sub {
    # Turn comment_in_chat on and pr comments off
    $conf->{comment_in_chat} = { success => 1 };
    $conf->{comment_on_prs}  = 0;

    $panky->post_form_ok('/_jenkins' => $data )->content_like(qr/Thanks!/);

    my $saying = pop @{ $panky->app->chat->sayings };
    like $saying->[0] => qr/^\[Jenkins:/;
    like $saying->[0] => qr/success/;

    ok my $req = pop @{ $panky->app->github->requests };
    is $req->[0] => 'POST_JSON';
    is $req->[1] => '/repos/repo/user/statuses/abc123';
    is $req->[2]{state} => 'success';
    is $req->[2]{target_url} => 'http://localhost:4000/job/Jenkins-Job/8/';
};

subtest 'Build Success Hook w/o chat, no pr comment' => sub {
    # Turn comment_in_chat on and pr comments off
    $conf->{comment_in_chat} = 0;
    $conf->{comment_on_prs}  = 0;

    $panky->post_form_ok('/_jenkins' => $data )->content_like(qr/Thanks!/);

    # Make sure we got no messages
    ok !pop @{ $panky->app->chat->sayings };

    # Make sure we still got the statuses request
    ok my $req = pop @{ $panky->app->github->requests };
    is $req->[1] => '/repos/repo/user/statuses/abc123';
};

subtest 'Build Failure Hook w/chat, no pr comment' => sub {
    # Turn comment_in_chat on and pr comments off
    $conf->{comment_in_chat} = { failure => 1 };
    $conf->{comment_on_prs}  = 0;

    # Copy data
    my $data = { %$data };
    # Set no status
    $data->{status} = undef;
    # Check that we can post to _github and get a Thanks! response
    $panky->post_form_ok('/_jenkins' => $data )->content_like(qr/Thanks!/);

    my $saying = pop @{ $panky->app->chat->sayings };
    like $saying->[0] => qr/^\[Jenkins:/;
    like $saying->[0] => qr/failure/;

    ok my $req = pop @{ $panky->app->github->requests };
    is $req->[0] => 'POST_JSON';
    is $req->[1] => '/repos/repo/user/statuses/abc123';
    is $req->[2]{state} => 'failure';
    is $req->[2]{target_url} => 'http://localhost:4000/job/Jenkins-Job/8/';
};


subtest 'Build Hook w/chat = 1' => sub {
    $conf->{comment_in_chat} = 1;
    $conf->{comment_on_prs}  = 0;

    # Test success
    $panky->post_form_ok('/_jenkins' => $data )->content_like(qr/Thanks!/);
    my $saying = pop @{ $panky->app->chat->sayings };
    like $saying->[0] => qr/success/;

    # Test failure
    my $data = { %$data };
    $data->{status} = undef;
    $panky->post_form_ok('/_jenkins' => $data )->content_like(qr/Thanks!/);
    $saying = pop @{ $panky->app->chat->sayings };
    like $saying->[0] => qr/failure/;
};
