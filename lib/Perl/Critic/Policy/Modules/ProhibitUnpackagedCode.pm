package Perl::Critic::Policy::Modules::ProhibitUnpackagedCode;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

use vars qw($VERSION);
$VERSION = '0.06';

sub violations {
    my ($self, $doc) = @_;
    my $expl = q{Violates encapsulation};
    my $desc = q{Unpackaged code};
    my $match = $doc->find_first( sub { $_[1]->significant() } ) || return;
    return if $match->isa('PPI::Statement::Package');
    return Perl::Critic::Violation->new( $desc, $expl, $match->location() );
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::Modules::ProhibitUnpackagedCode

=head1 DESCRIPTION

Conway doesn't specifically mention this, but I've come across it in
my own work.  In general, the first statement of any Perl module or
library should be a C<package> statement.  Otherwise, all the code
that comes before the C<package> statement is getting executed in the
caller's package, and you have no idea who that is.  Good
encapsulation and common decency require your module to keep its
innards to itself.

As for scripts, most people understand that the default package is
C<main>, but it doesn't hurt to be explicit about it either.  So
include the C<package main> statement at the top of your scripts too.

There are some valid reasons for not having a C<package> statement at
all.  But make sure you understand them before assuming that you
should do it too.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
