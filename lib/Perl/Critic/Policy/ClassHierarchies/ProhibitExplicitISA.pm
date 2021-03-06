##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/branches/Perl-Critic-backlog/lib/Perl/Critic/Policy/ClassHierarchies/ProhibitExplicitISA.pm $
#     $Date: 2009-09-07 16:19:21 -0500 (Mon, 07 Sep 2009) $
#   $Author: clonezone $
# $Revision: 3629 $
##############################################################################

package Perl::Critic::Policy::ClassHierarchies::ProhibitExplicitISA;

use 5.006001;
use strict;
use warnings;
use Readonly;

use Perl::Critic::Utils qw{ :severities };
use base 'Perl::Critic::Policy';

our $VERSION = '1.105';

#-----------------------------------------------------------------------------

Readonly::Scalar my $DESC => q{@ISA used instead of "use base"}; ## no critic (RequireInterpolation)
Readonly::Scalar my $EXPL => [ 360 ];

#-----------------------------------------------------------------------------

sub supported_parameters { return ()                         }
sub default_severity     { return $SEVERITY_MEDIUM           }
sub default_themes       { return qw( core maintenance pbp ) }
sub applies_to           { return 'PPI::Token::Symbol'       }

#-----------------------------------------------------------------------------

sub violates {
    my ($self, $elem, undef) = @_;

    if( $elem eq q{@ISA} ) {  ## no critic (RequireInterpolation)
        return $self->violation( $DESC, $EXPL, $elem );
    }
    return; #ok!
}

1;

#-----------------------------------------------------------------------------

__END__

=pod

=head1 NAME

Perl::Critic::Policy::ClassHierarchies::ProhibitExplicitISA - Employ C<use base> instead of C<@ISA>.


=head1 AFFILIATION

This Policy is part of the core L<Perl::Critic|Perl::Critic>
distribution.


=head1 DESCRIPTION

Conway recommends employing C<use base qw(Foo)> instead of the usual
C<our @ISA = qw(Foo)> because the former happens at compile time and
the latter at runtime.  The L<base> pragma also automatically loads
C<Foo> for you so you save a line of easily-forgotten code.


=head1 CONFIGURATION

This Policy is not configurable except for the standard options.


=head1 NOTE

Some people prefer L<parent> over L<base>.


=head1 AUTHOR

Chris Dolan <cdolan@cpan.org>


=head1 COPYRIGHT

Copyright (c) 2006-2009 Chris Dolan.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
