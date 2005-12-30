#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Policy/Modules/RequireEndWithOne.pm $
#     $Date: 2005-12-30 12:27:26 -0800 (Fri, 30 Dec 2005) $
#   $Author: thaljef $
# $Revision: 182 $
########################################################################

package Perl::Critic::Policy::Modules::RequireEndWithOne;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.13_03';
$VERSION = eval $VERSION;    ## no critic

#----------------------------------------------------------------------------

my $expl = q{Must end with a recognizable true value};
my $desc = q{Module does not end with '1;'};

#----------------------------------------------------------------------------

sub default_severity { return $SEVERITY_HIGH }
sub applies_to { return 'PPI::Document' }

#----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, $doc ) = @_;

    return if is_script($doc);

    # Last statement should be just "1;"
    my @significant = grep { _is_code($_) } $doc->schildren();
    my $match = $significant[-1];
    return if ($match && (ref $match) eq 'PPI::Statement' && $match eq '1;');

    # Must be a violation...
    my $sev = $self->get_severity();
    return Perl::Critic::Violation->new( $desc, $expl, $match, $sev );
}

sub _is_code {
    my $elem = shift;
    return ! (    $elem->isa('PPI::Statement::End')
               || $elem->isa('PPI::Statement::Data'));
}

1;

__END__

#----------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::Modules::RequireEndWithOne

=head1 DESCRIPTION

All files included via C<use> or C<require> must end with a true value
to indicate to the caller that the include was successful.  The
standard practice is to conclude your .pm files with C<1;>, but some
authors like to get clever and return some other true value like
C<return "Club sandwich";>.  We cannot tolerate such frivolity!  OK, we
can, but we don't recommend it since it confuses the newcomers.

=head1 AUTHOR

Chris Dolan C<cdolan@cpan.org>

Some portions cribbed from
L<Perl::Critic::Policy::Modules::RequireExplicitPackage>.

=head1 COPYRIGHT

Copyright (c) 2005 Chris Dolan and Jeffrey Ryan Thalhammer.  All
rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut