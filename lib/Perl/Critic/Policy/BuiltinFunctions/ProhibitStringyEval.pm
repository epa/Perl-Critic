package Perl::Critic::Policy::BuiltinFunctions::ProhibitStringyEval;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.07';

sub violations {
    my ($self, $doc) = @_;
    my $expl = [161];
    my $desc = q{String form of 'eval'};
    my $nodes_ref = find_keywords( $doc, 'eval' ) || return;
    my @matches = grep { ! _first_arg_is_block($_) } @{$nodes_ref};
    return map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) } 
      @matches;
}

sub _first_arg_is_block {
    my $elem = shift || return;
    my $sib = $elem->snext_sibling() || return;
    my $arg = $sib->isa('PPI::Structure::List') ? $sib->schild(0) : $sib;
    return $arg && $arg->isa('PPI::Structure::Block');
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::BuiltinFunctions::ProhibitStringyEval

=head1 DESCRIPTION

The string form of eval is recompiled every time it is executed,
whereas the block form is only compiled once.  Also, the string form
doesn't give compile-time warnings.

  eval "print $foo";        #not ok
  eval {print $foo};        #ok

=head1 SEE ALSO

L<Perl::Critic::Policy::ControlStrucutres::ProhibitStringyGrep>

L<Perl::Critic::Policy::ControlStrucutres::ProhibitStringyMap>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
