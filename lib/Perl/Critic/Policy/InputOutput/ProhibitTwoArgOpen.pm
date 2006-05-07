#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Policy/InputOutput/ProhibitTwoArgOpen.pm $
#     $Date: 2006-04-28 23:36:18 -0700 (Fri, 28 Apr 2006) $
#   $Author: thaljef $
# $Revision: 396 $
########################################################################

package Perl::Critic::Policy::InputOutput::ProhibitTwoArgOpen;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.15_03';
$VERSION = eval $VERSION; ## no critic

#--------------------------------------------------------------------------

my $desc = q{Two-argument 'open' used};
my $expl = [ 207 ];

#--------------------------------------------------------------------------

sub default_severity { return $SEVERITY_HIGHEST }
sub applies_to { return 'PPI::Token::Word' }

#--------------------------------------------------------------------------

sub violates {
    my ($self, $elem, $doc) = @_;
    return if !($elem eq 'open');
    return if is_method_call($elem);
    return if is_hash_key($elem);
    return if is_subroutine_name($elem);

    if( scalar parse_arg_list($elem) == 2 ) {
        my $sev = $self->get_severity();
	return Perl::Critic::Violation->new( $desc, $expl, $elem, $sev );
    }
    return; #ok!
}

1;

__END__

#--------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::InputOutput::ProhibitTwoArgOpen

=head1 DESCRIPTION

The three-argument form of C<open> (introduced in Perl 5.6) prevents
subtle bugs that occur when the filename starts with funny characters
like '>' or '<'.  The L<IO::File> module provides a nice
object-oriented interface to filehandles, which I think is more
elegant anyway.

  open( $fh, '>output.txt' );          # not ok
  open( $fh, q{>}, 'output.txt );      # ok

  use IO::File;
  my $fh = IO::File->new( 'output.txt', q{>} ); # even better!

=head1 NOTES

The only time you should use the two-argument form is when you re-open
STDIN, STDOUT, or STDERR.  But for now, this Policy doesn't provide
that loophole.

=head1 SEE ALSO

L<IO::Handle>

L<IO::File>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (C) 2005-2006 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
