package Panky::Chat::Jabber;
use AnyEvent::XMPP::IM::Connection;
use AnyEvent::XMPP::Ext::Disco;
use AnyEvent::XMPP::Ext::MUC;
use Module::Pluggable search_path => [ 'Panky::Chat::Jabber' ], require => 1;
use Mojo::Base 'Panky::Chat';

# ABSTRACT: Manage Jabber connection for Panky

has [ qw( host jid password panky room nick muc jc ) ];

has required_env => sub{[qw(
    PANKY_CHAT_JABBER_JID PANKY_CHAT_JABBER_PWD PANKY_CHAT_JABBER_ROOM
)]};

sub setup {
    my ($self) = @_;

    # Set up everything that isn't already setup (i.e was not passed in)
    $self->jid( $self->jid // $ENV{PANKY_CHAT_JABBER_JID} );
    $self->password( $self->password // $ENV{PANKY_CHAT_JABBER_PWD} );
    $self->room( $self->room // $ENV{PANKY_CHAT_JABBER_ROOM} );
    $self->host( $self->host // $ENV{PANKY_CHAT_JABBER_HOST} );
}

sub connect {
    my ($self) = @_;

    # Parse user/domain from jid
    my ($username, $domain) = split /@/, $self->jid;

    # Set the nick to the first fart of the JID
    $self->nick( $username );

    # Create the connection object
    my $jc = AnyEvent::XMPP::IM::Connection->new(
        username => $username,
        domain => $domain,
        password => $self->password,
        host => $self->host,
        resource => 'panky-local',
    );

    # Save the jabber connection to oursef
    $self->jc( $jc );

    # Add MUC Extension
    $jc->add_extension (my $d = AnyEvent::XMPP::Ext::Disco->new);
    $jc->add_extension(my $muc = AnyEvent::XMPP::Ext::MUC->new( disco => $d ));

    # Save the muc object to ourself
    $self->muc( $muc );

    # Join the room once we're connected
    $jc->reg_cb (stream_ready => sub {
        $muc->join_room($jc, $self->room, $self->nick)
    });

    # Handle messages
    $muc->reg_cb( message => sub { $self->_dispatch( @_ ) });

    # Reconnect on disconnect
    $jc->reg_cb (disconnect => sub { $jc->connect });

    # Connect to jabber
    $jc->connect;

    # Store objects that we'll want to self
    $self->attr('_jc' => sub { $jc });
    $self->attr('_muc' => sub { $muc });

    # Return $self so we are chainable
    return $self;
}

# Tells the chat agent to say something in the chat room
# msg - the body of the message to send to the room
# to_nick - (optional) the user to say the msg to ("$to_nick: $msg")
sub say {
    my ($self, $msg, $to_nick) = @_;

    # Prepend $to_nick to message if given
    $msg = "$to_nick: $msg" if $to_nick;

    # Send the msg
    my $m = $self->muc->get_room( $self->jc, $self->room )->make_message(
        body => $msg
    )->send;
}

# Dispatches messages received in the chatroom to their appropriate
# listeners based on the type of the message.
sub _dispatch {
    my ($self, $muc, $room, $msg, $is_echo) = @_;

    # We don't care about echo's or delayed messages
    return if $is_echo || $msg->is_delayed;

    my $nick = $self->nick;
    # private_message if it's private, otherwise, if it's directed TO us
    # (starts with our name) make it a directed_message, otherwise its
    # just regular chatter in the chatroom.
    my $method = $msg->is_private ? 'private_message' :
                 $msg->body ~~ /^$nick\W/ ? 'directed_message' : 'message';
    # Plugins come from Module::Pluggable
    for ( $self->plugins ) {
        # Make sure it can handle this method
        next unless $_->can($method);
        $_->$method( $self->panky, $room, $msg );
    }
}

1;
