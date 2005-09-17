package Perl::Critic::Policy::ValuesAndExpressions::RequireUpperCaseHeredocTerminator;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

use vars qw($VERSION);
$VERSION = '0.06';

sub violations {
    my ($self, $doc) = @_;
    my $expl = [64];
    my $desc = q{Heredoc terminator must be in upper case};
    my $nodes_ref = $doc->find('PPI::Token::HereDoc') || return;
    my $heredoc_rx    = qr{ \A << ["|']? [A-Z_]+ ['|"]? \z }x;
    my @matches   = grep { $_ !~ $heredoc_rx } @{$nodes_ref};
     return map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) } 
      @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::ValuesAndExpressions::RequireUpperCaseHeredocTerminator

=head1 DESCRIPTION

For legibility, HEREDOC terminators should be all UPPER CASE letters, without
any whitespace.  Conway also recommends using a standard prefix like "END_"
but this policy doesn't enforce that.

  print <<'the End';  #not ok
  Hello World
  the End

  print <<'THE_END';  #ok
  Hello World
  THE_END

=head1 SEE ALSO 

L<Perl::Critic::Policy::ValuesAndExpressions::RequireQuotedHeredocTerminator>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
