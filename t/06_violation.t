use strict;
use warnings;
use PPI::Document;
use English qw(-no_match_vars);
use Test::More tests => 26;

#-----------------------------------------------------------------------------

BEGIN
{
    # Needs to be in BEGIN for global vars
    use_ok('Perl::Critic::Violation');
}

use lib qw(t/tlib);
use ViolationTest;   # this is solely to test the import() method; has diagnostics
use ViolationTest2;  # this is solely to test the import() method; no diagnostics

#-----------------------------------------------------------------------------
#  method tests

can_ok('Perl::Critic::Violation', 'sort_by_location');
can_ok('Perl::Critic::Violation', 'new');
can_ok('Perl::Critic::Violation', 'location');
can_ok('Perl::Critic::Violation', 'diagnostics');
can_ok('Perl::Critic::Violation', 'description');
can_ok('Perl::Critic::Violation', 'explanation');
can_ok('Perl::Critic::Violation', 'source');
can_ok('Perl::Critic::Violation', 'policy');
can_ok('Perl::Critic::Violation', 'to_string');

#-----------------------------------------------------------------------------
# Constructor Failures:
eval { Perl::Critic::Violation->new('desc', 'expl'); };
ok($EVAL_ERROR, 'new, wrong number of args');
eval { Perl::Critic::Violation->new('desc', 'expl', {}, 'severity'); };
ok($EVAL_ERROR, 'new, bad arg');

#-----------------------------------------------------------------------------
# Accessor tests

my $pkg  = __PACKAGE__;
my $code = 'Hello World;';
my $doc = PPI::Document->new(\$code);
my $no_diagnostics_msg = qr/ \s* No [ ] diagnostics [ ] available \s* /xms;
my $viol = Perl::Critic::Violation->new( 'Foo', 'Bar', $doc, 99, );

is(        $viol->description(), 'Foo',    'description');
is(        $viol->explanation(), 'Bar',    'explanation');
is_deeply( $viol->location(),    [0,0],    'location');
is(        $viol->severity(),    99,       'severity');
is(        $viol->source(),      $code,    'source');
is(        $viol->policy(),      $pkg,     'policy');
like(      $viol->diagnostics(), qr/ \A $no_diagnostics_msg \z /xms, 'diagnostics');

{
    local $Perl::Critic::Violation::FORMAT = '%l,%c,%m,%e,%p,%d,%r';
    my $expect = qr/\A 0,0,Foo,Bar,$pkg,$no_diagnostics_msg,\Q$code\E \z/xms;

    like($viol->to_string(), $expect, 'to_string');
    like("$viol",            $expect, 'stringify');
}

$viol = Perl::Critic::Violation->new('Foo', [28], $doc, 99);
is($viol->explanation(), 'See page 28 of PBP', 'explanation');

$viol = Perl::Critic::Violation->new('Foo', [28,30], $doc, 99);
is($viol->explanation(), 'See pages 28,30 of PBP', 'explanation');


#-----------------------------------------------------------------------------
# Import tests
like(ViolationTest->get_violation()->diagnostics(),
     qr/ \A \s* This [ ] is [ ] a [ ] test [ ] diagnostic\. \s*\z /xms, 'import diagnostics');

#-----------------------------------------------------------------------------
# Violation sorting

$code = <<'END_PERL';
my $foo = 1; my $bar = 2;
my $baz = 3;
END_PERL

$doc = PPI::Document->new(\$code);
my @children   = $doc->schildren();
my @violations = map {Perl::Critic::Violation->new('', '', $_, 0)} $doc, @children;
my @sorted = Perl::Critic::Violation->sort_by_location( reverse @violations);
is_deeply(\@sorted, \@violations, 'sort_by_location');


my @severities = (5, 3, 4, 0, 2, 1);
@violations = map {Perl::Critic::Violation->new('', '', $doc, $_)} @severities;
@sorted = Perl::Critic::Violation->sort_by_severity( @violations );
is_deeply( [map {$_->severity()} @sorted], [sort @severities], 'sort_by_severity');