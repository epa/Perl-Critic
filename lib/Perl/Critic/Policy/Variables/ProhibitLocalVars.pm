package Perl::Critic::Policy::Variables::ProhibitLocalVars;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use List::MoreUtils qw(none);
use base 'Perl::Critic::Policy';

our $VERSION = '0.10';
$VERSION = eval $VERSION;    ## no critic

#---------------------------------------------------------------------------

sub violations {
    my ( $self, $doc ) = @_;
    my $expl      = [ 77, 78, 79 ];
    my $desc      = q{Variable declared as 'local'};
    my $nodes_ref = $doc->find('PPI::Statement::Variable') || return;
    my @matches   =
      grep { $_->type() eq 'local' && !_all_global_vars($_) } @{$nodes_ref};
    return
      map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) }
      @matches;
}

sub _all_global_vars {

    my $elem = shift;
    for my $var ( $elem->variables() ) {
        return if none { $var =~ m{\A [\$@%] $_ }x } @GLOBALS;
    }
    return 1;
}

1;

__END__

=pod

=head1 NAME

Perl::Critic::Policy::Variables::ProhibitLocalVars

=head1 DESCRIPTION

Since Perl 5, there are very few reasons to declare C<local>
variables.  The only reasonable exceptions are Perl's magical global
variables.  If you do need to modify one of those global variables,
you should localize it first.  You should also use the L<English>
module to give those variables more meaningful names.

  local $foo;   #not ok
  my $foo;      #ok

  use English qw(-no_match_vars);
  local $INPUT_RECORD_SEPARATOR    #ok
  local $RS                        #ok
  local $/;                        #not ok

=head1 SEE ALSO

L<Perl::Critic::Policy::Variables::ProhibitPunctuationVars>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
