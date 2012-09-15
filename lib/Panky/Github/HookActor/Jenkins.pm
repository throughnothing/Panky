package Panky::Github::HookActor::Jenkins;
use Mojo::Base 'Panky::Github::HookActor';

# ABSTRACT: Github Hook Actor to initiate Jenkins Builds from Pull Requests

# Called when a 'pull_request' hook is received
sub pull_request {
    my ($self, $payload) = @_;

    # Do nothing on 'closed' action (or no action defined)
    return if ($payload->action || 'closed') eq 'closed';

    my $nwo = $payload->repository->full_name;
    my $repo = $self->config->{ lc( $nwo ) };
    return "No related Jenkins Job found" unless $repo;

    # Get the sha1 hash of HEAD for the branch being PR'ed
    my $sha = $payload->pull_request->head->sha;

    # Tell Jenkins to start building this commit
    my $url = $self->panky->ci->build( $repo->{job}, $sha );

    # Let github know that a build is pending
    $self->panky->github->set_status( $nwo, $sha, 'pending', $url );
}

1
