package Panky::Jenkins::HookActor;
use Hash::Merge::Simple qw( merge );
use Memoize;
use Mojo::Base 'Panky::HookActor';
use WWW::Shorten 'GitHub';

# ABSTRACT: Panky::Github::HookActor Base class with helper functions

has type => 'Jenkins';

1;

=head1 SYNOPSIS

L<Panky::Jenkins::HookActor> is the base class for  all of your
L<Panky::Jenkins::HookActor>'s that you may want to create.  Any C<HookActor>
for Jenkins hooks should use this as the base class.
