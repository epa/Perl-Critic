package Perl::Critic::Policy::BuiltinFunctions::RequireBlockGrep;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.08_02';
$VERSION = eval $VERSION; ## pc:skip

#----------------------------------------------------------------------------

sub violations {
    my ($self, $doc) = @_;
    my $expl = [169];
    my $desc = q{Expression form of 'grep'};
    my $nodes_ref = find_keywords( $doc, 'grep' ) || return;
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

Perl::Critic::Policy::BuiltinFunctions::RequireBlockGrep

=head1 DESCRIPTION

The expression form of C<grep> and C<map> is awkward and hard to read.
Use the block forms instead.

  @matches = grep  /pattern/,    @list;        #not ok
  @matches = grep { /pattern/ }  @list;        #ok

  @mapped = map  transform($_),    @list;      #not ok
  @mapped = map { transform($_) }  @list;      #ok


=head1 SEE ALSO

L<Perl::Critic::Policy::BuiltinFunctions::ProhibitStringyEval>

L<Perl::Critic::Policy::BuiltinFunctions::RequireBlockMap>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
