package Perl::Critic::Policy;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = '0.06';

sub new { return bless {}, shift }
sub violations { _abstract_method() }

sub _abstract_method {
    my $method_name = ( caller(1) )[3];
    my ( $file, $line ) = ( caller(0) )[ 1, 2 ];
    die "Can't call abstract method '$method_name' at $file line $line.\n";
}

1;

__END__

=head1 NAME

Perl::Critic::Policy - Base class for Policy modules

=head1 DESCRIPTION

Perl::Critic::Policy is the abstract base class for all Policy
objects.  Your job is to implement and override its methods in a
subclass.  To work with the L<Perl::Critic> engine, your
implementation must behave as described below.

=head1 METHODS

=over 8

=item new(key1 => value1, key2 => value2...)

Returns a reference to a new subclass of C<Perl::Critic::Policy>. If
your Policy requires any special arguments, they should be passed
in here as key-value paris.  Users of L<perlcritic> can specify
these in their config file.  Unless you override the C<new> method,
the default method simply returns a reference to an empty hash that
has been blessed into your subclass.

=item violations( $doc )

Given a L<PPI::Document> or L<PPI::DocumentFragment>, returns a list
of L<Perl::Critic::Violation> objects for each violation of the
policy.  If there are no violations, then it returns an empty list.
This is an abstract method and it will croak if you attempt to invoke
it directly.  Your subclass B<must> override this method.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
