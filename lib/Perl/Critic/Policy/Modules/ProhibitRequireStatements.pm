package Perl::Critic::Policy::Modules::ProhibitRequireStatements;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.12';
$VERSION = eval $VERSION;    ## no critic

my $desc = q{Deprecated 'require' statement used};
my $expl = q{Use 'use' pragma instead};

#----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, $doc ) = @_;
    $elem->isa('PPI::Statement::Include') && $elem->type() eq 'require'
      || return;
    return Perl::Critic::Violation->new( $desc, $expl, $elem->location() );
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::Modules::ProhibitRequireStatements

=head1 DESCRIPTION

C<require> statements aren't really deprecated, but ever since Perl 5,
the C<use> pragma is the norm.  There are some perfectly legitimate
reasons to use C<require>, but most are outside the realm of everyday
programming.  The primary goal of this policy is to steer people
toward writing F<*.pm> modules instead of old-school F<*.pl>
libraries.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
