package Panky::Chat::Module::Spotify;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use Net::Spotify;
use XML::TreePP;

# ABSTRACT: Give info on Spotify urls

has spotify => sub { Net::Spotify->new };
has tpp     => sub { XML::TreePP->new };

sub message {
    my ($self, $msg, $from) = @_;

    my @data = $self->_parse_spotify_uris( $msg );
    return unless @data;
    $self->say( $_ ) for @data;
}

# This sub taken from Bot::Basic::Pluggable::Module::Spotify
# https://metacpan.org/source/EDOARDO/Bot-BasicBot-Pluggable-Module-Spotify-0.01/lib/Bot/BasicBot/Pluggable/Module/Spotify.pm
sub _parse_spotify_uris {
   my ($self, $text) = @_;

   my @data = ();

   while ($text =~ m{ \b (spotify:(artist|album|track):\w+) \b }gmx) {
       my ($uri, $type) = ($1, $2);

       my $xml = $self->spotify->lookup(uri => $uri);

       if (my $tree = $self->tpp->parse($xml)) {
           if ($type eq 'artist') {
               push @data, sprintf(
                   '%s -> Artist: %s',
                   $uri,
                   $tree->{artist}->{name},
               );
           }
           elsif ($type eq 'album') {
               push @data, sprintf(
                   '%s -> Album: %s, Artist: %s, Year: %s',
                   $uri,
                   $tree->{album}->{name}, $tree->{album}->{artist}->{name},
                   $tree->{album}->{released}
               );
           }
           elsif ($type eq 'track') {
               push @data, sprintf(
                   '%s -> Track: %s, Album: %s, Artist: %s',
                   $uri,
                   $tree->{track}->{name},
                   $tree->{track}->{album}->{name},
                   $tree->{track}->{artist}->{name},
               );
           }
       }
   }

   return @data;
}

1;
