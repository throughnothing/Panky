
use strict;
use warnings;

use 5.010000;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Panky is a chatty, github-and-ci helper bot for your team",
  "AUTHOR" => "William Wolf <throughnothing\@gmail.com>",
  "BUILD_REQUIRES" => {
    "File::Find" => 0,
    "File::Slurp" => 0,
    "File::Temp" => 0,
    "Mojo::JSON" => 0,
    "Test::Mojo" => 0,
    "Test::More" => 0,
    "Test::Most" => 0,
    "strict" => 0,
    "t::lib::Base" => 0,
    "warnings" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Panky",
  "EXE_FILES" => [],
  "LICENSE" => "unrestricted",
  "NAME" => "Panky",
  "PREREQ_PM" => {
    "AnyEvent::XMPP::Ext::Disco" => 0,
    "AnyEvent::XMPP::Ext::MUC" => 0,
    "AnyEvent::XMPP::IM::Connection" => 0,
    "EV" => "4.11",
    "Exporter" => 0,
    "Hash::AsObject" => 0,
    "Hash::Merge::Simple" => 0,
    "IO::Socket::SSL" => "1.76",
    "Memoize" => 0,
    "Module::Pluggable" => 0,
    "Mojo::Base" => 0,
    "Mojo::UserAgent" => 0,
    "URI" => 0,
    "WWW::Shorten" => 0,
    "WWW::Shorten::GitHub" => "v0.1.3"
  },
  "VERSION" => "0.001",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



