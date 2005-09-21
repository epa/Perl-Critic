package Perl::Critic::Policy::Variables::ProhibitPackageVars;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use List::MoreUtils qw(all);
use base 'Perl::Critic::Policy';

our $VERSION = '0.07';

sub violations {
    my ($self, $doc) = @_;
    my $expl = [73,75];
    my $desc = q{Package variable declared or used};
    my @package_vars  = _find_package_vars($doc);
    my @our_vars      = _find_our_vars($doc);
    my @vars_pragmas  = _find_vars_pragmas($doc);
    return map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) } 
      @package_vars, @our_vars, @vars_pragmas;
}

sub _find_package_vars {
    my $doc = shift;
    my $nodes_ref = $doc->find('PPI::Token::Symbol') || return;
    return grep { $_ =~ m{::} && $_ !~ m{ [A-Z0-9_]+ \z}x } @{$nodes_ref};
}

sub _find_our_vars {
    my $doc = shift;
    my $nodes_ref = $doc->find('PPI::Statement::Variable') || return;
    return grep { $_->type() eq 'our' && ! _all_upcase($_->variables() )}  
       @{$nodes_ref};
}

sub _find_vars_pragmas {
    my $doc = shift;
    my $nodes_ref = $doc->find('PPI::Statement::Include') || return;
    return grep { $_->pragma() eq 'vars' } @{$nodes_ref};
}

sub _all_upcase {return all {$_ eq uc $_} @_}

1;

__END__

=head1 NAME

Perl::Critic::Policy::Variables::ProhibitPackageVars

=head1 DESCRIPTION

Conway suggests avoiding package variables completely, because they
expose your internals to other packages.  Never use a package variable
when a lexical variable will suffice.  If your package needs to keep
some dynamic state, consider using an object or closures to keep the
state private.  

This policy assumes that you're using C<strict vars> so that naked
variable declarations are not package variables by default.  Thus, it
complains you declare a variable with C<our> or C<use vars>, or if you
make reference to variable with a fully-qualified package name.

  $Some::Package::foo = 1;    #not ok
  our $foo            = 1;    #not ok
  use vars '$foo';            #not ok
  $foo = 1;                   #not allowed by 'strict'
  local $foo = 1;             #bad taste, but ok.
  my $foo = 1;                #ok

In practice though, its not really practical prohibit all package
variables.  Common variables like C<$VERSION> and C<@EXPORT> need to
be global, as do any variables that you want to Export.  To work
around this, the Policy overlooks any variables that are in ALL_CAPS.
This forces you to put all your expored variables in ALL_CAPS too, which
seems to be the usual practice anyway.

=head1 BUGS

The exemption for ALL_CAPS variables doesn't work with the C<use vars>
pragma.  I'll fix this at some point.

=head1 SEE ALSO

L<Perl::Critic::Policy::Variables::ProhibitPunctuationVars>

L<Perl::Critic::Policy::Variables::ProhibitLocalVars>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
