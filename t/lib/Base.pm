package t::lib::Base;
use Exporter 'import';
use Mojo::Base -strict;
use Mojo::JSON;
use Panky;
use Test::Mojo;

use t::lib::Mock::Chat;
use t::lib::Mock::GithubAPI;
use t::lib::Mock::Jenkins;

BEGIN {
    # For some reason this is needed with Mojolicious::Plugin::Config
    $ENV{MOJO_APP} = 'Panky';

    # Set necessary env vars
    $ENV{PANKY_BASE_URL} = 'http://localhost:3000/';
    $ENV{PANKY_GITHUB_USER} = 'throughnothing';
    $ENV{PANKY_GITHUB_PWD} = 'password';
    $ENV{PANKY_JENKINS_BASE_URL} = 'http://localhost:4000/';
    $ENV{PANKY_JENKINS_USER} = 'throughnothing';
    $ENV{PANKY_JENKINS_TOKEN} = 'jenkins_token';
}

our @EXPORT_OK = qw( panky json mock_chat mock_github );

sub panky {
    my $panky = Panky->new(
        chat   => mock_chat(),
        github => mock_github(
            user => $ENV{PANKY_GITHUB_USER},
            pwd => $ENV{PANKY_GITHUB_PWD},
        ),
        ci => mock_ci( base_url => $ENV{PANKY_JENKINS_BASE_URL} ),
    );
    $panky->ci->panky( $panky );
    $panky->chat->panky( $panky );

    Test::Mojo->new( $panky );
}

# Returns a mock chat object
sub mock_chat { t::lib::Mock::Chat->new( @_ ); }
# Returns a mock github object
sub mock_github { t::lib::Mock::GithubAPI->new( @_ ); }
# Returns a mock ci object
sub mock_ci { t::lib::Mock::Jenkins->new( @_ ); }

sub json { Mojo::JSON->new }



1;
