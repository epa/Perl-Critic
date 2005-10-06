package Perl::Critic::Policy::ValuesAndExpressions::ProhibitNoisyQuotes;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.10';
$VERSION = eval $VERSION;    ## no critic

#---------------------------------------------------------------------------

sub violations {
    my ( $self, $doc ) = @_;
    my $expl        = [53];
    my $desc        = q{Quotes used with a noisy string};
    my $doubles_ref = $doc->find('PPI::Token::Quote::Double') || [];
    my $singles_ref = $doc->find('PPI::Token::Quote::Single') || [];
    my $noise_rx    = qr{\A ["|']  [^ \w () {} [\] <> ]{1,2}  ['|"] \z}x;
    my @matches     = grep { $_ =~ $noise_rx } @{$doubles_ref}, @{$singles_ref};
    return
      map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) }
      @matches;
}

1;

__END__

=pod

=head1 NAME

Perl::Critic::Policy::ValuesAndExpressions::ProhibitNoisyQuotes

=head1 DESCRIPTION

Don't use quotes for one or two-character strings of non-alphanumeric
characters (i.e. noise).  These tend to be hard to read.  For
legibility, use C<q{}> or a named value.  However, braces, parens, and 
brackets tend do to look better in quotes, so those are allowed.

  $str = join ',', @list;     #not ok
  $str = join ",", @list;     #not ok
  $str = join q{,}, @list;    #better

  $COMMA = q{,};
  $str = join $COMMA, @list;  #best

  $lbrace = '(';          #ok
  $rbrace = ')';          #ok
  print '(', @list, ')';  #ok

=head1 SEE ALSO 

L<Perl::Critic::Policy::ValuesAndExpressions::ProhibitEmptyQuotes>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
