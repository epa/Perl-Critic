package Perl::Critic::Policy::Modules::ProhibitRequireStatements;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

use vars qw($VERSION);
$VERSION = '0.06';

sub violations {
    my ($self, $doc) = @_;
    my $expl = q{Use 'use' pragma instead};
    my $desc = q{Deprecated 'require' statement used};
    my $nodes_ref = $doc->find('Statement::Include') || return;
    my @matches   = grep { $_->type() eq 'require' } @{$nodes_ref};
    return map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) } 
      @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::Modules::ProhibitRequireStatements

=head1 DESCRIPTION

Since Perl 5, C<require> statements are pretty much obsolete.  Use the
C<use> pragma instead.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
