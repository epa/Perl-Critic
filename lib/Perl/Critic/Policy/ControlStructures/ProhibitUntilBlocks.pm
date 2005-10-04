package Perl::Critic::Policy::ControlStructures::ProhibitUntilBlocks;

use strict;
use warnings;
use Perl::Critic::Violation;
use Perl::Critic::Utils;
use base 'Perl::Critic::Policy';

our $VERSION = '0.09';
$VERSION = eval $VERSION;    ## no critic

#----------------------------------------------------------------------------

sub violations {
    my ( $self, $doc ) = @_;
    my $expl      = [97];
    my $desc      = q{'until' block used};
    my $nodes_ref = $doc->find('PPI::Statement') || return;
    my @matches   = grep { $_->first_element() eq 'until' } @{$nodes_ref};
    return @matches;
}

1;

__END__

=pod 

=head1 NAME

Perl::Critic::Policy::ControlStructures::ProhibitUntilBlocks

=head1 DESCRIPTION

Conway discourages using C<until> becuase it leads to double-negatives
that are hard to understand.  Instead, reverse the logic and use C<while>.

  until($condition)     { do_something() } #not ok
  until(! $no_flag)     { do_something() } #really bad
  while( ! $condition)  { do_something() } #ok

This Policy only covers the block-form of C<until>.  For the postfix
variety, see 'ProhibitPostfixControls'.

=head1 SEE ALSO

L<Perl::Critic::Policy::ControlStructures::ProhibitPostfixControls>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
