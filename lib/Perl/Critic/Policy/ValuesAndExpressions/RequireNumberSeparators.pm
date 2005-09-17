package Perl::Critic::Policy::ValuesAndExpressions::RequireNumberSeparators;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

use vars qw($VERSION);
$VERSION = '0.06';

sub violations {
    my ($self, $doc) = @_;
    my $expl = [55];
    my $desc = q{Long number not separated with underscores};
    my $nodes_ref = $doc->find('PPI::Token::Number') || return;
    my @matches = grep { $_ =~ m{ \d{4,} }x } @{$nodes_ref};
    return map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) } 
      @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::ValuesAndExpressions::RequireNumberSeparators

=head1 DESCRIPTION

Long numbers are be hard to read.  To improve legibility, Perl allows
numbers to be split into groups of digits separated by underscores.
This policy requires numbers sequences of more than three digits to be
separated.

 $long_int = 123456789;   #not ok
 $long_int = 123_456_789; #ok

 $long_float = 1234.56789;   #not ok
 $long_float = 1_234.567_89; #ok

=head1 NOTES

As it is currently written, this policy only works properly with
decimal (base 10) numbers.  And it is obviouly biased toward Western
notation.  I'll try and address those issues in the future.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
