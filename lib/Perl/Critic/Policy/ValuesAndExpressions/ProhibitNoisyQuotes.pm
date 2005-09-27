package Perl::Critic::Policy::ValuesAndExpressions::ProhibitNoisyQuotes;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.08_02';
$VERSION = eval $VERSION; ## pc:skip

#---------------------------------------------------------------------------

sub violations {
    my ($self, $doc) = @_;
    my $expl = [53];
    my $desc = q{Quotes used with a noisy string};
    my $doubles_ref = $doc->find('PPI::Token::Quote::Double') || [];
    my $singles_ref = $doc->find('PPI::Token::Quote::Single') || [];
    my @matches   = grep { m{\A ["|'] \W{1,2} ['|"] \z}x } @{$doubles_ref}, @{$singles_ref};
     return map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) } 
      @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::ValuesAndExpressions::ProhibitNoisyQuotes

=head1 DESCRIPTION

Don't use quotes for one or two-character strings of non-alphanumeric
characters (i.e. noise).  These tend to be hard to read.  For
legibility, use C<q{}> or a named value.

  $str = join ',', @list;     #not ok
  $str = join ",", @list;     #not ok
  $str = join q{,}, @list;    #better

  $COMMA = q{,};
  $str = join $COMMA, @list;  #best

=head1 SEE ALSO 

L<Perl::Critic::Policy::ValuesAndExpressions::ProhibitEmptyQuotes>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
