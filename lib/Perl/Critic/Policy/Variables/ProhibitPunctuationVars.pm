package Perl::Critic::Policy::Variables::ProhibitPunctuationVars;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.10';
$VERSION = eval $VERSION;    ## no critic

#---------------------------------------------------------------------------

sub violations {
    my ( $self, $doc ) = @_;
    my $expl      = [79];
    my $desc      = q{Magic punctuation variable used};
    my $nodes_ref = $doc->find('PPI::Token::Magic') || return;

    ## no critic
    my %exempt = ( '$_' => 1, '@_' => 1 );    #Can't live without these
    for ( 1 .. 9 ) { $exempt{"\$$_"} = 1 }    #These are used with regex
    $exempt{'_'} = 1;                         #This is used with 'stat'
    ## use critic

    my @matches = grep { !exists $exempt{$_} } @{$nodes_ref};
    return
      map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) }
      @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::Variables::ProhibitPunctuationVars

=head1 DESCRIPTION

Perl's vocabulary of punctuation variables such as C<$!>, C<$.>, and
C<$^> are perhaps the leading cause of its repuation as inscrutable
line noise.  The simple alternative is to use the L<English> module to
give them clear names.

  $| = undef;                      #not ok

  use English qw(-no_match_vars);
  local $OUTPUT_AUTOFLUSH = undef;        #ok

=head1 NOTES

The scratch variables C<$_> and C<@_> are very common and have no
equivalent name in L<English>, so they are exempt from this policy.
All the $n variables associated with regex captures are exempt too.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
