package Panky::Chat::Module::Music;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';
use Mojo::UserAgent;
use Mojo::Util qw( url_escape );

# ABSTRACT: Let's you search music

has ua => sub { Mojo::UserAgent->new };
has tinysong_api_key => sub { $ENV{TINYSONG_API_KEY} };
has tinysong_base => sub { 'http://tinysong.com/s/%s?format=json&key=%s' };

sub directed_message { shift->message( @_ ) }

sub message {
    my ($self, $msg, $from) = @_;

    return unless $self->tinysong_api_key;

    if( $msg =~ qr/(\d+)?\s*songs?(?:\s*about)?:?\s*(.+)$/i ) {
        my ( $num, $song, $i ) = ($1 || 1, $2, 0);
        my $reses = $self->_search( $song );
        for ( @$reses ) {
            last if ++$i > $num;
            my $str = sprintf("%s", $_->{SongName});
            $str .= sprintf(" by %s", $_->{ArtistName});
            $str .= sprintf(" on %s", $_->{AlbumName}) if $_->{AlbumName};
            $str .= sprintf(" <%s>\n", $_->{Url});
            $self->say( "$from: $str" );
        }
    }
}

sub _search {
    my ($self, $text) = @_;

    $self->ua->get(
        sprintf(
            $self->tinysong_base,
            url_escape( $text ),
            $self->tinysong_api_key
        ),
    )->res->json;
}

1;
