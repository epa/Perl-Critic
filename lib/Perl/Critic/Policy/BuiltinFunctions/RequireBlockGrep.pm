package Perl::Critic::Policy::BuiltinFunctions::RequireBlockGrep;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.12';
$VERSION = eval $VERSION;    ## no critic

my $desc = q{Expression form of 'grep'};
my $expl = [169];

#----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, $doc ) = @_;
    $elem->isa('PPI::Token::Word') && $elem eq 'grep' || return;
    if ( !_first_arg_is_block($elem) ) {
        return Perl::Critic::Violation->new( $desc, $expl, $elem->location() );
    }
    return;    #ok!
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
