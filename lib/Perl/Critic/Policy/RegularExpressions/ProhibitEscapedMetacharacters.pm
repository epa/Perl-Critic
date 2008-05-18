##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Policy/RegularExpressions/ProhibitEscapedMetacharacters.pm $
#     $Date: 2008-05-17 20:03:55 -0500 (Sat, 17 May 2008) $
#   $Author: clonezone $
# $Revision: 2349 $
##############################################################################

package Perl::Critic::Policy::RegularExpressions::ProhibitEscapedMetacharacters;

use strict;
use warnings;
use Readonly;

use English qw(-no_match_vars);
use List::MoreUtils qw(any);

use Perl::Critic::Utils qw{ :booleans :severities hashify };
use Perl::Critic::Utils::PPIRegexp qw{ ppiify parse_regexp };
use base 'Perl::Critic::Policy';

our $VERSION = '1.083_003';

#-----------------------------------------------------------------------------

Readonly::Scalar my $DESC => q{Use character classes for literal metachars instead of escapes};
Readonly::Scalar my $EXPL => [247];

Readonly::Hash my %REGEXP_METACHARS =>
    hashify split m/ /xms, '{ } ( ) . * + ? |'; ##no critic(Interpolation)

#-----------------------------------------------------------------------------

sub supported_parameters { return qw()                    }
sub default_severity     { return $SEVERITY_LOWEST        }
sub default_themes       { return qw( core pbp cosmetic ) }
sub applies_to           { return qw(PPI::Token::Regexp::Match
                                     PPI::Token::Regexp::Substitute
                                     PPI::Token::QuoteLike::Regexp) }

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, undef ) = @_;

    # optimization: don't bother parsing the regexp if there are no escapes
    return if $elem !~ m/\\/xms;

    my $re = ppiify(parse_regexp($elem));
    return if !$re;

    # Must pass a sub to find() because our node classes don't start with PPI::
    my $exacts = $re->find(sub {$_[1]->isa('Perl::Critic::PPIRegexp::exact')});
    return if !$exacts;
    for my $exact (@{$exacts}) {
       my @escapes = $exact =~ m/\\(.)/gxms;
       return $self->violation( $DESC, $EXPL, $elem ) if any { $REGEXP_METACHARS{$_} } @escapes;
    }

    return;  # OK
}

1;

__END__

#-----------------------------------------------------------------------------

=pod

=for stopwords IPv4

=head1 NAME

Perl::Critic::Policy::RegularExpressions::ProhibitEscapedMetacharacters - Use character classes for literal meta-characters instead of escapes.

=head1 AFFILIATION

This Policy is part of the core L<Perl::Critic> distribution.


=head1 DESCRIPTION

Ever heard of leaning toothpick syndrome?  That comes from writing
regular expressions that match on characters that are significant in
regular expressions.  For example, the expression to match four
forward slashes looks like:

    m/\/\/\/\//;

Well, this policy doesn't solve that problem (write it as C<m{////}>
instead!) but solves a related one.  As seen above, the escapes make
the expression hard to parse visually.  One solution is to use
character classes.  You see, inside of character classes, the only
characters that are special are C<\>, C<]>, C<^> and C<->, so you don't need
to escape the others.  So instead of the following loose IPv4 address matcher:

    m/ \d+ \. \d+ \. \d+ \. \d+ /x;

You could write:

    m/ \d+ [.] \d+ [.] \d+ [.] \d+ /x;

which is certainly more readable, if less recognizable prior the
publication of Perl Best Practices.  (Of course, you should really use
L<Regexp::Common::net> to match IPv4 addresses!)

Specifically, this policy forbids backslashes immediately prior to the following characters:

    { } ( ) . * + ? | #

We make special exception for C<$> because C</[$]/> turns into
C</[5.008006/> for Perl 5.8.6.  We also make an exception for C<^>
because it has special meaning (negation) in a character class.
Finally, C<[> and C<]> are exempt, of course, because they are awkward
to represent in character classes.

Note that this policy does not forbid unnecessary escaping.  So go
ahead and (pointlessly) escape C<!> characters.


=head1 CONFIGURATION

This Policy is not configurable except for the standard options.


=head1 BUGS

Perl treats C<m/[#]/x> in unexpected ways.
I think it's a bug in Perl itself, but am not 100% sure that I have
not simply misunderstood...

This part makes sense:

  "#f" =~ m/[#]f/x;     # match
  "#f" =~ m/[#]a/x;     # no match

This doesn't:

  $qr  = qr/f/;
  "#f" =~ m/[#]$qr/x; # no match

Neither does this:

  print qr/[#]$qr/x;  # yields '(?x-ism:[#]$qr
                                )'

=head1 CREDITS

Initial development of this policy was supported by a grant from the Perl Foundation.

=head1 AUTHOR

Chris Dolan <cdolan@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2007-2008 Chris Dolan.  Many rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
