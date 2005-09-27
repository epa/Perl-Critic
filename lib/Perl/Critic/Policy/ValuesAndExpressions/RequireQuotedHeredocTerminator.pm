package Perl::Critic::Policy::ValuesAndExpressions::RequireQuotedHeredocTerminator;

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
    my $expl = [62];
    my $desc = q{Heredoc terminator must be quoted};
    my $nodes_ref = $doc->find('PPI::Token::HereDoc') || return;
    my $heredoc_rx    = qr/ \A << ["|'] .* ['|"] \z /x;
    my @matches   = grep { $_ !~ $heredoc_rx } @{$nodes_ref};
     return map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) } 
      @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::ValuesAndExpressions::RequireQuotedHeredocTerminator

=head1 DESCRIPTION

Putting single or double-quotes around your HEREDOC terminator make it obvious
to the reader whether the content is going to be interpolated or not.

  print <<END_MESSAGE;    #not ok
  Hello World
  END_MESSAGE

  print <<'END_MESSAGE';  #ok
  Hello World
  END_MESSAGE

  print <<"END_MESSAGE";  #ok
  $greeting
  END_MESSAGE

=head1 SEE ALSO 

L<Perl::Critic::Policy::ValuesAndExpressions::RequireUpperCaseHeredocTerminator>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
