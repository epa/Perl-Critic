#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/branches/Perl-Critic-backlog/t/15_statistics.t $
#     $Date: 2009-09-07 16:19:21 -0500 (Mon, 07 Sep 2009) $
#   $Author: clonezone $
# $Revision: 3629 $
##############################################################################

use 5.006001;
use strict;
use warnings;

use English qw(-no_match_vars);

use Perl::Critic::PolicyFactory (-test => 1);
use Perl::Critic::TestUtils;

use Test::More (tests => 25);

#-----------------------------------------------------------------------------

our $VERSION = '1.105';

#-----------------------------------------------------------------------------

Perl::Critic::TestUtils::block_perlcriticrc();

#-----------------------------------------------------------------------------

my $pkg = 'Perl::Critic::Statistics';
use_ok( $pkg );

my @methods = qw(
    average_sub_mccabe
    lines
    modules
    new
    statements
    subs
    total_violations
    violations_by_policy
    violations_by_severity
    statements_other_than_subs
    violations_per_file
    violations_per_statement
    violations_per_line_of_code
);

for my $method ( @methods ) {
    can_ok( $pkg, $method );
}

#-----------------------------------------------------------------------------

my $code = <<'END_PERL';
package Foo;

use My::Module;
$this = $that if $condition;
sub foo { return @list unless $condition };
END_PERL

#-----------------------------------------------------------------------------

# User may not have Perl::Tidy installed...
my $profile = { '-CodeLayout::RequireTidyCode' => {} };
my $critic =
    Perl::Critic->new(
        -severity => 1,
        -profile => $profile,
        -theme => 'core',
    );
my @violations = $critic->critique( \$code );

#print @violations;
#exit;

my %expected_stats = (
    average_sub_mccabe            => 2,
    lines                         => 5,
    modules                       => 1,
    statements                    => 6,
    statements_other_than_subs    => 5,
    subs                          => 1,
    total_violations              => 10,
    violations_per_file           => 10,
    violations_per_line_of_code   => 2,
    violations_per_statement      => 2,
);

my $stats = $critic->statistics();
isa_ok($stats, $pkg);

while ( my($method, $expected) = each %expected_stats) {
    is( $stats->$method, $expected, "Statistics: $method");
}

#-----------------------------------------------------------------------------

# ensure we return true if this test is loaded by
# t/15_statistics.t_without_optional_dependencies.t
1;

###############################################################################
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
