package Perl::Critic::Policy::ValuesAndExpressions::ProhibitLeadingZeros;

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
    my $expl      = [55];
    my $desc      = q{Integer with leading zeros};
    my $nodes_ref = $doc->find('PPI::Token::Number') || return;
    my @matches   = grep { $_ =~ m{\A -? 0+ \d+ \z }x } @{$nodes_ref};
    return
      map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) }
      @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::ValuesAndExpressions::ProhibitLeadingZeros

=head1 DESCRIPTION

Perl interprets numbers with leading zeros as octal.  If that's what
you really want, its better to use C<oct> and make it obvious.

  $var = 041;     #not ok, actually 33
  $var = oct(41); #ok

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
