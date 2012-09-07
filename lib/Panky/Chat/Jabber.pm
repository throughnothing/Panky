package Panky::Chat::Jabber;
use AnyEvent::XMPP::IM::Connection;
use AnyEvent::XMPP::Ext::Disco;
use AnyEvent::XMPP::Ext::MUC;
use Module::Pluggable search_path => [ 'Panky::Chat::Jabber' ], require => 1;
use Mojo::Base -base;

# ABSTRACT: Manage Jabber connection for Panky

has [ qw( host jid password panky room ) ];

sub connect {
    my ($self) = @_;

    # Parse user/domain from jid
    my ($username, $domain) = split /@/, $self->jid;

    # Create the connection object
    my $jc = AnyEvent::XMPP::IM::Connection->new(
        username => $username,
        domain => $domain,
        password => $self->password,
        host => $self->host,
        resource => 'panky',
    );

    # Add MUC Extension
    $jc->add_extension (my $d = AnyEvent::XMPP::Ext::Disco->new);
    $jc->add_extension(my $muc = AnyEvent::XMPP::Ext::MUC->new( disco => $d ));

    # Join the room once we're connected
    $jc->reg_cb (stream_ready => sub {
        $muc->join_room($jc, $self->room, 'tiltbot')
    });

    # Handle messages
    $muc->reg_cb( message => sub { $self->dispatch( @_ ) });

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

sub dispatch {
    my ($self, $muc, $room, $msg, $is_echo) = @_;

    # We don't care about echo's or delayed messages
    return if $is_echo || $msg->is_delayed;

    my $method = 'message';
    # Plugins come from Module::Pluggable
    for ( $self->plugins ) {
        # Make sure it can handle this method
        next unless $_->can($method);
        # As soon as something returns a value, we're done
        last if $_->$method( $room, $msg );
    }
}

1;
