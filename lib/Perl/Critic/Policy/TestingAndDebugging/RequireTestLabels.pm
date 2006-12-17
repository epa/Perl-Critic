##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.22/lib/Perl/Critic/Policy/TestingAndDebugging/RequireTestLabels.pm $
#     $Date: 2006-12-16 22:33:36 -0800 (Sat, 16 Dec 2006) $
#   $Author: thaljef $
# $Revision: 1103 $
##############################################################################

package Perl::Critic::Policy::TestingAndDebugging::RequireTestLabels;

use strict;
use warnings;
use List::MoreUtils qw(any);
use Perl::Critic::Utils;
use base 'Perl::Critic::Policy';

our $VERSION = 0.22;

my %label_arg_pos = (
   ok        => 1,
   is        => 2,
   isnt      => 2,
   like      => 2,
   unlike    => 2,
   cmp_ok    => 3,
   is_deeply => 2,
   pass      => 0,
   fail      => 0,
);

my %default_test_modules = hashify( qw( Test::More ) );

#-----------------------------------------------------------------------------

my $desc = q{Test without a label};
my $expl = q{Add a label argument to all Test::More functions};

#-----------------------------------------------------------------------------

sub policy_parameters { return qw( modules )                }
sub default_severity  { return $SEVERITY_MEDIUM             }
sub default_themes    { return qw( core maintenance tests ) }
sub applies_to        { return 'PPI::Token::Word'           }

#-----------------------------------------------------------------------------

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;

    $self->{_test_modules} = \%default_test_modules;
    if (defined $args{modules}) {
        my @modules = words_from_string( $args{modules} );
        $self->{_test_modules} = { %default_test_modules, hashify(@modules) };
    }

    return $self;
}

#-----------------------------------------------------------------------------

sub violates {
    my ($self, $elem, $doc) = @_;

    my $arg_index = $label_arg_pos{$elem};
    return if not defined $arg_index;
    return if not is_function_call($elem);
    return if not $self->_has_test_more($doc);

    # Does the function call have enough arguments?
    my @args = parse_arg_list($elem);
    return if ( @args > $arg_index );

    return $self->violation( $desc, $expl, $elem );
}

#-----------------------------------------------------------------------------

sub _has_test_more {
    my ( $self, $doc ) = @_;

    # TODO: This method gets called every time violates() is invoked,
    # but it only needs to happen once per document.  Perhaps this
    # policy should just apply to PPI::Document, and then do its own
    # search for for method calls.  Since Perl::Critic::Document is
    # optimized, this should be pretty fast.

    my $includes = $doc->find('PPI::Statement::Include');
    return if not $includes;
    return any { exists $self->{_test_modules}->{$_->module()} }
        @{ $includes };
}

1;

#-----------------------------------------------------------------------------

__END__

=pod

=head1 NAME

Perl::Critic::Policy::TestingAndDebugging::RequireTestLabels

=head1 DESCRIPTION

Most Perl modules with regression tests use L<Test::More> as
infrastructure for writing and running those tests.  It has an easy,
procedural syntax for writing comparisons of results to expectations.

Most of the Test::More functions allow the programmer to add an
optional label that describes what each test is trying to judge.  When
a test goes wrong, these labels are very useful for quickly
determining where the problem originated.

This policy enforces that all Test::More functions have labels where
applicable.  This only applies to code that has a C<use Test::More> or
C<require Test::More> declaration (see below to add more test modules
to the list).

=head1 CONFIGURATION

A list of additional modules to require label parameters be passed to
their methods can be specified with the C<modules> option.  The list
must consist of whitespace-delimited, fully-qualified module names.
For example:

 [TestingAndDebugging::RequireTestLabels]
 modules = My::Test::SubClass  Some::Other::Module

The module list always implicitly includes L<Test::More>.

=head1 AUTHOR

Chris Dolan <cdolan@cpan.org>

=head1 COPYRIGHT

Copyright (C) 2006 Chris Dolan.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :