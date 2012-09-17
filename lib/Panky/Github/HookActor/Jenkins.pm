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

=head1 SYNOPSIS

This C<HookActor> performs tasks on L<Jenkins|http://jenkins-ci.org> when
certain github hooks are received.

Currently, it can perform jenkins builds on Github Pull Request actions.  In
order for this to work, you must setup a mapping of github repositories to
their respective jenkins jobs.  This can be done in your panky conf like this:

    {
       Github => {
            HookActor => {
                Jenkins => {
                    'user/repo1' => {
                        job => 'Jenkins-Job-Name',
                    },
                    'user/repo2' => {
                        job => 'Other-Jenkins-Job',
                    },
                }
            },
        },
    }

Additionally, your Jenkins jobs need to be set up as a 'parameterized' build,
accepting one parameter called C<HEAD> which accepts the sha1 hash of the commit
that should be tested.  Then, the "Branch Specifier" under the "Git" option
needs to be set to C<${HEAD}> for it to use the parameter we pass in.

That's it!

