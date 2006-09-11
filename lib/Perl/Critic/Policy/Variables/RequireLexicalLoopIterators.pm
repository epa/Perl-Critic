#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.20/lib/Perl/Critic/Policy/Variables/RequireLexicalLoopIterators.pm $
#     $Date: 2006-09-10 21:18:18 -0700 (Sun, 10 Sep 2006) $
#   $Author: thaljef $
# $Revision: 663 $
# ex: set ts=8 sts=4 sw=4 expandtab
########################################################################

package Perl::Critic::Policy::Variables::RequireLexicalLoopIterators;

use strict;
use warnings;
use Perl::Critic::Utils;
use base 'Perl::Critic::Policy';

our $VERSION = 0.20;

#---------------------------------------------------------------------------

my $desc = q{Loop iterator is not lexical};
my $expl = [ 108 ];

#---------------------------------------------------------------------------

sub default_severity { return $SEVERITY_HIGHEST }
sub applies_to { return 'PPI::Statement::Compound' }

#---------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, undef ) = @_;

    # First child will be 'for' or 'foreach' keyword
    my $first_child = $elem->schild(0);
    return if !$first_child;
    return if $first_child ne 'for' and $first_child ne 'foreach';

    # The second child could be the iteration list
    my $second_child = $elem->schild(1);
    return if !$second_child;
    return if $second_child->isa('PPI::Structure::ForLoop');

    return if $second_child eq 'my';

    return $self->violation( $desc, $expl, $elem );
}

#---------------------------------------------------------------------------

1;

__END__

#---------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::Variables::RequireLexicalLoopIterators

=head1 DESCRIPTION

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2006 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut