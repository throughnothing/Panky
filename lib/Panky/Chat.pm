package Panky::Chat;
use Memoize;
use Mojo::Base -base;
use Module::Pluggable
    search_path => [ 'Panky::Chat::Module' ],
    sub_name => '_plugins',
    instantiate => 'new';

memoize 'plugins';

has 'required_env' => sub{ [] };
has [qw( panky nick )];

sub new {
    my ($self, %args) = @_;
    $self = $self->SUPER::new( %args );

    # Make sure we have all required fields
    for ( @{ $self->required_env } ) {
        die "$_ Required for Chat!" if !$ENV{$_};
    }

    # Let your app setup your variables
    $self->setup;

    return $self;
}

# Dispatches messages to the loaded plugins
# type - 'directed_message', 'message'
# msg - message body
# from - who the message was from
sub dispatch {
    my ($self, $type, $msg, $from) = @_;

    my $dispatched;

    # Plugins come from Module::Pluggable
    for ( $self->plugins( panky => $self->panky ) ) {
        # Make sure it can handle this method
        $dispatched ||= $_->$type( $msg , $from ) if $_->can($type);
    }

    if ('directed_message' eq $type and not $dispatched) {
        $self->panky->chat->say("$from: " . $self->panky->hailo->reply($msg));
    }
}

# Memoized function to return all plugins from Module::Pluggable
sub plugins { shift->_plugins( @_ ) }

# Dummy setup function in case a sub-class doesn't need one
sub setup { }

# Dummy connect function
sub connect { }

# Dummy say function
sub say { }

1;

=head1 SYNOPSIS

All C<Panky::Chat::*> modules should inherit from C<Panky::Chat>.

Additionally, any module that inherits from this, should define the
C<required_env> attribute to be an C<ARRAYREF> of all environment variables
that the chat module requires to work.  This module will ensure that we die
if we don't have them all.

Your C<Chat> module also needs to implement the C<setup> method, which will
set the attributes on your C<Chat> object appropriately from the environment
variables (with defaults if needed) for the rest of your module to use.
