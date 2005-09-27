package Perl::Critic::Policy::Modules::ProhibitMultiplePackages;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.08_02';
$VERSION = eval $VERSION; ## pc:skip

#----------------------------------------------------------------------------

sub violations {
    my ($self, $doc) = @_;
    my $expl = q{Limit to one per file};
    my $desc = q{Multiple 'package' declarations};
    my $nodes_ref = $doc->find('PPI::Statement::Package') || return;
    my @matches = @{$nodes_ref} > 1 ? @{$nodes_ref}[1..$#{$nodes_ref}] : ();
    return map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) } 
      @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::Modules::ProhibitMultiplePackages

=head1 DESCRIPTION

Conway doesn't specifically mention this, but I find it annoying when
there are multiple packages in the same file.  When searching for
methods or keywords in your editor, it makes it hard to find the right
chunk of code, especially if each package is a subclass of the same
base.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.