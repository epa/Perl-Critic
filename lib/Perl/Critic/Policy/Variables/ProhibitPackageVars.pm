package Perl::Critic::Policy::Variables::ProhibitPackageVars;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

use vars qw($VERSION);
$VERSION = '0.06';

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
    return grep { $_ =~ m{::} } @{$nodes_ref};
}

sub _find_our_vars {
    my $doc = shift;
    my $nodes_ref = $doc->find('PPI::Statement::Variable') || return;
    return grep { $_->type() eq 'our' } @{$nodes_ref};
}

sub _find_vars_pragmas {
    my $doc = shift;
    my $nodes_ref = $doc->find('PPI::Statement::Include') || return;
    return grep { $_->pragma() eq 'vars' } @{$nodes_ref};
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::Variables::ProhibitPackageVars

=head1 DESCRIPTION

Package variables are globally visible, thus exposing your
implementation to prying eyes.  'Tis better to use accessor methods or
static subs to change the state of things in your package.

This policy assumes that you're using C<strict vars> so that variables
declarations are not package variables by default.  Thus, it complains
you declare a variable with C<our> or C<use vars>, or if you make
reference to variable with a fully-qualified package name.

  $Some::Package::foo = 1;    #not ok
  our $foo            = 1;    #not ok
  use vars '$foo';            #not ok
  $foo = 1;                   #not allowed by 'strict'
  my $foo = 1;                #ok

=head1 SEE ALSO

L<Perl::Critic::Policy::Variables::ProhibitPunctuationVars>

L<Perl::Critic::Policy::Variables::ProhibitLocalVars>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
