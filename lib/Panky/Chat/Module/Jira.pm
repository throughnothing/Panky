package Panky::Chat::Module::Jira;
use v5.10;
use Mojo::Base 'Panky::Chat::Module';

# ABSTRACT: Handles github action requests from users in chatroom

sub message {
    my ($self, $msg, $from) = @_;
    # If we don't have Jira, don't do anything
    my $jira = $self->panky->jira or return;

    given( $msg ) {
        when ( /$ENV{PANKY_JIRA_URL}browse\/((\w+)-(\d+))/ ) {
            $self->_say_ticket_info( $1 );
        } when ( /([A-Z]{2,10}-\d+)/ ) {
            $self->_say_ticket_info( $1 );
        }
    }
}

sub _say_ticket_info {
    my ($self, $ticket) = @_;
    # If we don't have Jira, don't do anything
    my $jira = $self->panky->jira or return;

    my $res = $jira->get_issue( $ticket );

    return unless ref $res && $res->{body};

    my $summary = $res->{body}{fields}{summary};
    my $status = $res->{body}{fields}{status}{name};
    my $priority = $res->{body}{fields}{priority}{name};
    my $assignee = $res->{body}{fields}{assignee}{name};
    $self->say("[$ticket]($priority) $status: $assignee => $summary");
}

1;

=head1 SYNOPSIS

This module provides the ability to get information from your teams
L<Jira|https://www.atlassian.com/software/jira/overview> account in your
chatroom.

    > https://company.atlassian.net/browse/PROJECT-NUMBER
    > <panky> [PROJECT-NUMBER]: ISSUE TITLE
