package Perl::Critic::Policy::BuiltinFunctions::RequireGlobFunction;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.10';
$VERSION = eval $VERSION;    ## no critic

#----------------------------------------------------------------------------

sub violations {
    my ( $self, $doc ) = @_;
    my $expl      = [167];
    my $desc      = q{Glob written as <...>};
    my $nodes_ref = $doc->find('PPI::Token::QuoteLike::Readline') || return;
    my @matches   = grep { $_->content() =~ /[\*\?]/ } @{$nodes_ref};
    return
      map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) }
      @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::BuiltinFunctions::RequireGlobFunction

=head1 DESCRIPTION

Conway discourages the use of the C<E<lt>..E<gt>> construct for globbing, as
its heavily associated with I/O in most people's minds.  Instead, he recommends
the use of the C<glob()> function as it makes it much more obvious what you're
attempting to do.

  @files = <*.pl>;              # not ok
  @files = glob( "*.pl" );      # ok

=head1 AUTHOR

Graham TerMarsch <graham@howlingfrog.com>

Copyright (C) 2005 Graham TerMarsch.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
