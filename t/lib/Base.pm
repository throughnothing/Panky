package t::lib::Base;
use Exporter 'import';
use Mojo::Base -strict;

use Panky::Chat;


BEGIN {
    # Set necessary env vars
    $ENV{PANKY_BASE_URL} = 'http://localhost:3000';
    $ENV{PANKY_GITHUB_USER} = 'throughnothing';
    $ENV{PANKY_GITHUB_PWD} = 'password';
}

our @EXPORT_OK = qw( sayings );

no warnings 'redefine';
# Save things that are said so we can look at them in tests
my @sayings;
*Panky::Chat::say = sub { push @sayings, \@_ };

sub sayings { \@sayings }

1;
