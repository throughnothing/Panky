package Panky::Github::HookActor::Generic;
use Mojo::Base 'Panky::Github::HookActor';

# ABSTRACT: Generic actor to act upon Github Hook postbacks

# Called when a 'push' hook is received
sub push {
    my ($self, $panky, $payload) = @_;

    my $name = $payload->repository->name;
    my $head = substr( $payload->after, 0, 6 );
    my $branch = $self->branch_from_ref( $payload->ref );
    my $msg  = ( split /\n/, $payload->commits->[0]->{message} )[0];
    my $user = $payload->commits->[0]->{author}{username};
    my $url = $self->shorten( $payload->commits->[0]->{url} );

    $panky->chat->say( "[$name/$branch]($user) $head: $msg $url" );
}

# Called when a 'commit_comment' hook is received
sub commit_comment {
    my ($self, $panky, $payload) = @_;

    my $name = $payload->repository->name;
    my $msg  = ( split /\n/, $payload->comment->body )[0];
    my $file = $payload->comment->path;
    my $user = $payload->comment->user->login;

    $panky->chat->say( "$user commented on $file in $name: $msg" );
}

# Called when a 'pull_request' hook is received
sub pull_request {
    my ($self, $panky, $payload) = @_;

    my $name = $payload->repository->name;
    my $action = $payload->action;
    my $title  = $payload->pull_request->title;
    my $user = $payload->sender->login;
    my $url = $self->shorten( $payload->pull_request->html_url );
    my $head = $payload->pull_request->head->ref;
    my $base = $payload->pull_request->base->ref;

    $panky->chat->say(
        "[$name] PR '$title' $action by $user $url"
    );
}

1;
