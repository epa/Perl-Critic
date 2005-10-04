package Perl::Critic::Policy::Subroutines::ProhibitSubroutinePrototypes;

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
    my $expl      = [194];
    my $desc      = q{Subroutine prototypes used};
    my $nodes_ref = $doc->find('PPI::Statement::Sub') || return;
    my @matches   = grep { $_->prototype() } @{$nodes_ref};
    return
      map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) }
      @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::Subroutines::ProhibitSubroutinePrototypes

=head1 DESCRIPTION

Contrary to common belief, subroutine prototypes do not enable
compile-time checks for proper arguments.  Don't use them.  

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
