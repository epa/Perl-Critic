#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Policy/ControlStructures/ProhibitCStyleForLoops.pm $
#     $Date: 2006-04-28 23:36:18 -0700 (Fri, 28 Apr 2006) $
#   $Author: thaljef $
# $Revision: 396 $
########################################################################

package Perl::Critic::Policy::ControlStructures::ProhibitCStyleForLoops;

use strict;
use warnings;
use Perl::Critic::Violation;
use Perl::Critic::Utils;
use base 'Perl::Critic::Policy';

our $VERSION = '0.15_03';
$VERSION = eval $VERSION;    ## no critic

#----------------------------------------------------------------------------

my $desc = q{C-style 'for' loop used};
my $expl = [ 97 ];

#----------------------------------------------------------------------------

sub default_severity { return $SEVERITY_LOW }
sub applies_to { return 'PPI::Structure::ForLoop' }

#----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, $doc ) = @_;
    if ( _is_cstyle($elem) ) {
        my $sev = $self->get_severity();
        return Perl::Critic::Violation->new( $desc, $expl, $elem, $sev );
    }
    return;    #ok!
}

sub _is_cstyle {
    my $elem      = shift;
    my $nodes_ref = $elem->find('PPI::Token::Structure') || return;
    my @semis     = grep { $_ eq $SCOLON } @{$nodes_ref};
    return scalar @semis == 2;
}

1;

__END__

#----------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::ControlStructures::ProhibitCStyleForLoops

=head1 DESCRIPTION

The 3-part C<for> loop that Perl inherits from C is butt-ugly, and only
really necessary if you need irregular counting.  The very Perlish
C<..> operator is much more elegant and readable.

  for($i=0; $i<=$max; $i++){      #ick!
      do_something($i);
  }

  for(0..$max){                   #very nice
    do_something($_);
  }

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2006 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
