package Perl::Critic::Policy::ValuesAndExpressions::ProhibitInterpolationOfLiterals;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.09';
$VERSION = eval $VERSION;    ## no critic

#---------------------------------------------------------------------------

sub violations {
    my ( $self, $doc ) = @_;
    my $expl      = [51];
    my $desc      = q{Useless interpolation of literal string};
    my $nodes_ref = $doc->find( \&_is_double_quote_or_qq ) || return;
    my @matches   = grep { !_has_interpolation($_) } @{$nodes_ref};
    return
      map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) }
      @matches;
}

sub _is_double_quote_or_qq {
    my ( $doc, $elem ) = @_;
    return $elem->isa('PPI::Token::Quote::Double')
      || $elem->isa('PPI::Token::Quote::Interpolate');
}

sub _has_interpolation {
    my $elem = shift || return;
    return $elem =~ m{(?<!\\)[\$\@]}x            #Contains unescaped $ or @
      || $elem   =~ m{\\[tnrfae0xcNLuLUEQ]}x;    #Containts escaped metachars
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::ValuesAndExpressions::ProhibitInterpolationOfLiterals

=head1 DESCRIPTION

Don't use double-quotes or C<qq//> if your string doesn't require
interpolation.  This saves the interpreter a bit of work and it lets
the reader know that you really did intend the string to be literal.

  print "foobar";     #not ok
  print 'foobar';     #ok
  print qq/foobar/;   #not ok
  print q/foobar/;    #ok

  print "$foobar";    #ok
  print "foobar\n";   #ok
  print qq/$foobar/;  #ok
  print qq/foobar\n/; #ok

=head1 SEE ALSO

L<Perl::Critic::Policy::ValuesAndExpressions::RequireInterpolationOfMetachars>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
