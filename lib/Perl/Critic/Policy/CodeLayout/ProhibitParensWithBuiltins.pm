package Perl::Critic::Policy::CodeLayout::ProhibitParensWithBuiltins;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use List::MoreUtils qw(any);
use base 'Perl::Critic::Policy';

our $VERSION = '0.10';
$VERSION = eval $VERSION;    ## no critic

#----------------------------------------------------------------------------

sub violations {
    my ( $self, $doc ) = @_;
    my $expl    = [13];
    my $desc    = q{Builtin function called with parens};
    my @matches = ();
    my @allow   = qw(my our local);
    for my $builtin (@BUILTINS) {
        next if any { $builtin eq $_ } @allow;
        my $nodes_ref = find_keywords( $doc, $builtin ) || next;
        push @matches,
          grep { _sibling_is_list($_) && !_is_object_method($_) } @{$nodes_ref};
    }
    return
      map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) }
      @matches;
}

sub _sibling_is_list {
    my $elem = shift;
    my $sib = $elem->snext_sibling() || return;
    return $sib->isa('PPI::Structure::List');
}

sub _is_object_method {
    my $elem = shift;
    my $sib = $elem->sprevious_sibling() || return;
    return $sib->isa('PPI::Token::Operator') && $sib eq q{->};
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::CodeLayout::ProhibitParensWithBuiltins

=head1 DESCRIPTION

Conway suggests that all built-in functions should be called without
parenthesis around the argument list.  This reduces visual clutter and
disambiguates built-in functions from user functions.  Exceptions are
made for C<my>, C<local>, and C<our> which require parenthesis when
called with multiple arguments.

  open($handle, '>', $filename); #not ok
  open $handle, '>', $filename;  #ok 

  split(/$pattern/, @list); #not ok
  split /$pattern/, @list;  #ok

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
