use Mojo::Base 't::lib::Base';
use Test::Most tests => 7;

use Panky::Chat::Jabber;

my $jm = "Panky::Chat::Jabber";

my @required = qw(
    PANKY_CHAT_JABBER_JID
    PANKY_CHAT_JABBER_PWD
    PANKY_CHAT_JABBER_ROOM
);

sub empty_env { $ENV{$_} = undef for @required }

# Make sure Jabber dies if it doesn't have all the env vars it needs
empty_env();
dies_ok { $jm->new } qr/Required/;

$ENV{PANKY_CHAT_JABBER_JID} = 'user@domain.com';
dies_ok { $jm->new } qr/Required/;

$ENV{PANKY_CHAT_JABBER_PWD} = '123';
dies_ok { $jm->new } qr/Required/;

$ENV{PANKY_CHAT_JABBER_ROOM} = 'room';
# Make sure Jabber sets up correctly now
my $jo;
lives_ok { $jo = $jm->new };

# Test setup gets called and sets all attrs
is $jo->jid => $ENV{PANKY_CHAT_JABBER_JID};
is $jo->password => $ENV{PANKY_CHAT_JABBER_PWD};
is $jo->room => $ENV{PANKY_CHAT_JABBER_ROOM};
