#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Policy/TestingAndDebugging/RequireUseWarnings.pm $
#     $Date: 2006-02-02 18:38:30 -0800 (Thu, 02 Feb 2006) $
#   $Author: chrisdolan $
# $Revision: 291 $
########################################################################

package Perl::Critic::Policy::TestingAndDebugging::RequireUseWarnings;

use strict;
use warnings;
use Perl::Critic::Utils;
use List::Util qw(first);
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.14_01';
$VERSION = eval $VERSION;    ## no critic

#---------------------------------------------------------------------------

my $desc = q{Code before warnings are enabled};
my $expl = [431];

#---------------------------------------------------------------------------

sub default_severity { return $SEVERITY_HIGH }
sub applies_to { return 'PPI::Document' }

#---------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, $doc ) = @_;

    #Find first statement that isn't 'use', 'require', or 'package'
    my $nodes_ref = $doc->find('PPI::Statement') || return;
    my $other_stmnt = first {
        !$_->isa('PPI::Statement::Package')
          && !$_->isa('PPI::Statement::Include');
      }
      @{$nodes_ref};

    #Find the first 'use warnings' statement
    my $strict_stmnt = first {
        $_->isa('PPI::Statement::Include')
          && $_->type()   eq 'use'
          && $_->pragma() eq 'warnings';
      }
      @{$nodes_ref};

    $other_stmnt || return;        #Both of these...
    $strict_stmnt ||= $other_stmnt;  #need to be defined
    my $other_at  = $other_stmnt->location->[0];
    my $strict_at = $strict_stmnt->location->[0];

    if ( $other_at <= $strict_at ) {
        my $sev = $self->get_severity();
        return Perl::Critic::Violation->new($desc, $expl, $other_stmnt, $sev);
    }
    return; #ok!
}

1;

__END__

#---------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::TestingAndDebugging::RequireUseWarnings

=head1 DESCRIPTION

Using warnings is probably the single most effective way to improve
the quality of your code.  This policy requires that the C<'use
warnings'> statement must come before any other statements except
C<package>, C<require>, and other C<use> statements.  Thus, all the
code in the entire package will be affected.

=head1 SEE ALSO

L<Perl::Critic::Policy::TestingAndDebugging::RequirePackageStricture>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2006 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module

=cut
