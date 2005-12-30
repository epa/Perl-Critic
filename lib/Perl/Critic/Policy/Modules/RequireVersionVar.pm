#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Policy/Modules/RequireVersionVar.pm $
#     $Date: 2005-12-29 19:48:54 -0800 (Thu, 29 Dec 2005) $
#   $Author: thaljef $
# $Revision: 176 $
########################################################################

package Perl::Critic::Policy::Modules::RequireVersionVar;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use List::MoreUtils qw(any);
use base 'Perl::Critic::Policy';

our $VERSION = '0.13_02';
$VERSION = eval $VERSION;    ## no critic

#---------------------------------------------------------------------------

my $desc = q{No 'VERSION' variable found};
my $expl = [ 404 ];

#---------------------------------------------------------------------------

sub default_severity { return $SEVERITY_LOW }
sub applies_to { return 'PPI::Document' }

#---------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, $doc ) = @_;

    return if $doc->find_first( \&_wanted );

    #If we get here, then no $VERSION was found
    my $sev = $self->get_severity();
    return Perl::Critic::Violation->new( $desc, $expl, $doc, $sev );
}

sub _wanted {
    return  ( _our_VERSION(@_) || _vars_VERSION(@_)  || _package_VERSION(@_) );
}

#------------------

sub _our_VERSION {
    my ($doc, $elem) = @_;
    $elem->isa('PPI::Statement::Variable') || return 0;
    $elem->type() eq 'our' || return 0;
    return any { $_ eq '$VERSION' } $elem->variables();
}

#------------------

sub _vars_VERSION {
    my ($doc, $elem) = @_;
    $elem->isa('PPI::Statement::Include') || return 0;
    $elem->pragma() eq 'vars' || return 0;
    return $elem =~ m{ \$VERSION }mx; #Crude, but usually works
}

#------------------

sub _package_VERSION {
    my ($doc, $elem) = @_;
    $elem->isa('PPI::Token::Symbol') || return 0;
    return $elem =~ m{ \A \$ \S+ ::VERSION \z }mx;
    #TODO: ensure that it is in _this_ package!
}

1;

__END__

#---------------------------------------------------------------------------

=pod

=head1 NAME

Perl::Critic::Policy::Modules::RequireVersionVar

=head1 DESCRIPTION

Every Perl file (modules, libraries, and scripts) should have a
C<$VERSION> variable.  The C<$VERSION> allows clients to insist on a
particular revision of your file like this:

  use SomeModule 2.4;  #Only loads version 2.4

This Policy scans your file for any package variable named
C<$VERSION>.  I'm assuming that you are using C<strict>, so you'll
have to declare it like one of these:

  our $VERSION = 1.01;
  $MyPackage::VERSION = 1.01;
  use vars qw($VERSION);

A common practice is to use the C<$Revision: 176 $> keyword to automatically
define the C<$VERSION> variable like this:

  our ($VERSION) = '$Revision: 176 $' =~ m{ \$Revision: \s+ (\S+) }x;

=head1 NOTES

Conway recommends using the C<version> pragma instead of raw numbers
or 'v-strings.'  However, this Policy only insists that the
C<$VERSION> be defined somehow.  I may try to extend this in the
future.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
