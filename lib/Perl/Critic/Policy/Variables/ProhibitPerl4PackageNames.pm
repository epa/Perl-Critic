##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-1.06/lib/Perl/Critic/Policy/Variables/ProhibitPerl4PackageNames.pm $
#     $Date: 2007-06-27 23:50:20 -0700 (Wed, 27 Jun 2007) $
#   $Author: thaljef $
# $Revision: 1709 $
##############################################################################

package Perl::Critic::Policy::Variables::ProhibitPerl4PackageNames;

use strict;
use warnings;
use Perl::Critic::Utils qw{ :characters :severities :classification };
use base 'Perl::Critic::Policy';

our $VERSION = 1.06;

#-----------------------------------------------------------------------------

my $desc = q{Use double colon (::) to separate package name components instead of single quotes (').};

#-----------------------------------------------------------------------------

sub supported_parameters { return() }
sub default_severity     { return $SEVERITY_LOW                              }
sub default_themes       { return qw(core maintenance)                       }
sub applies_to           { return qw( PPI::Token::Word PPI::Token::Symbol )  }

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, undef ) = @_;
    my $content = $elem->content();

    if ( (index $content, $QUOTE) < 0 ) {
                return;
    }

    if ( $elem->isa('PPI::Token::Word') && is_hash_key($elem) ) {
        return;
    }

    return
        $self->violation(
            $desc,
            qq{"$content" uses the obsolete single quote package separator."},
            $elem
        );
}

#-----------------------------------------------------------------------------

1;

__END__

#-----------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::Variables::ProhibitPerl4PackageNames

=head1 DESCRIPTION

Perl 5 kept single quotes (C<'>) as package component separators in
order to remain backward compatible with prior C<perl>s, but advocated
using double colon (C<::>) instead.  In the more than a decade since
Perl 5, double colons have been overwhelmingly adopted and most people
are not even aware that the single quote can be used in this manner.
So, unless you're trying to obfuscate your code, don't use them.

  package Foo::Bar::Baz;    #ok
  package Foo'Bar'Baz;      #not ok

=head1 SEE ALSO

L<perlmod>

=head1 AUTHOR

Elliot Shank C<< <perl@galumph.com> >>

=head1 COPYRIGHT

Copyright (c) 2007 Elliot Shank.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :