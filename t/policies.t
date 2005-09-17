use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use Test::More qw(no_plan);
use Perl::Critic;

my $code = undef;
my $policy = undef;
my %config = ();

#----------------------------------------------------------------

$code = <<'END_PERL';
eval "$some_code";
eval { some_code() };
END_PERL

$policy = 'BuiltinFunctions::ProhibitStringyEval';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
grep "$_ eq 'foo'", @list;
grep {$_ eq 'foo'}  @list;
END_PERL

$policy = 'BuiltinFunctions::ProhibitStringyGrep';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
map "$_++'", @list;
map {$_++}   @list;
END_PERL

$policy = 'BuiltinFunctions::ProhibitStringyMap';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
open ($foo, $bar);
open($foo, $bar);
uc();
lc();
END_PERL

$policy = 'CodeLayout::ProhibitParensWithBuiltins';
is( critique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
open $foo, $bar;
uc $foo;
lc $foo;
my $foo;
my ($foo, $bar);
our ($foo, $bar);
local ($foo $bar);
my_subroutine($foo $bar);
END_PERL

$policy = 'CodeLayout::ProhibitParensWithBuiltins';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
do_something() if $condition;
do_something() while $condition;
do_something() until $condition;
do_something() unless $condition;
do_something() for @list;
END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
is( critique($policy, \$code), 5, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
do_something() if $condition;
do_something() while $condition;
do_something() until $condition;
do_something() unless $condition;
do_something() for @list;
END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
%config = (allow => 'if while until unless for');
is( critique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
if ($condition){ do_something() };
while ($condition){ do_something() };
until ($condition){ do_something() };
unless ($condition){ do_something() };
for (@list){ do_something() };
END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
while ($condition) {
    next if $condition;
    last if $condition; 
    redo if $condition;
    return if $condition;
}
END_PERL

$policy = 'ControlStructures::ProhibitPostfixControls';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
if ($condition1){
  $foo;
}
elsif ($condition2){
  $bar;
}
elsif ($condition3){
  $baz;
}
else {
  $nuts;
}
END_PERL

$policy = 'ControlStructures::ProhibitCascadingIfElse';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
if ($condition1){
  $foo;
}
elsif ($condition2){
  $bar;
}
else {
  $nuts;
}

if ($condition1){
  $foo;
}
else {
  $nuts;
}

if ($condition1){
  $foo;
}
END_PERL

$policy = 'ControlStructures::ProhibitCascadingIfElse';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
package foo;
package bar;
package nuts;
$some_code = undef;
END_PERL

$policy = 'Modules::ProhibitMultiplePackages';
is( critique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
package foo;
$some_code = undef;
END_PERL

$policy = 'Modules::ProhibitMultiplePackages';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
require 'Exporter';
require 'My/Module.pl';
END_PERL

$policy = 'Modules::ProhibitRequireStatements';
is( critique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use MyModule;
no MyModule;
use strict;
END_PERL

$policy = 'Modules::ProhibitRequireStatements';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
package foo;
END_PERL

$policy = 'Modules::ProhibitUnpackagedCode';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
package foo;
$foo = $bar;
END_PERL

$policy = 'Modules::ProhibitUnpackagedCode';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Evil::Module qw(bad stuff);
use Super::Evil::Module;
END_PERL

$policy = 'Modules::ProhibitSpecificModules';
%config = (modules => 'Evil::Module Super::Evil::Module');
is( critique($policy, \$code, \%config), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Good::Module;
END_PERL

$policy = 'Modules::ProhibitSpecificModules';
%config = (modules => 'Evil::Module Super::Evil::Module');
is( critique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
@out = `some_command`;
@out = qx{some_command};
END_PERL

$policy = 'InputOutput::ProhibitBacktickOperators';
is( critique($policy, \$code), 2, $policy);

#----------------------------------------------------------------
$code = <<'END_PERL';
print "this is literal";
print qq{this is literal};
END_PERL

$policy = 'ValuesAndExpressions::ProhibitInterpolationOfLiterals';
is( critique($policy, \$code), 2, $policy);

#----------------------------------------------------------------
$code = <<'END_PERL';
print 'this is literal';
print q{this is literal};
END_PERL

$policy = 'ValuesAndExpressions::ProhibitInterpolationOfLiterals';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------
$code = <<'END_PERL';
print 'this is not $literal';
print q{this is not $literal};
print 'this is not literal\n';
print q{this is not literal\n};
END_PERL

$policy = 'ValuesAndExpressions::RequireInterpolationOfMetachars';
is( critique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print "this is not $literal";
print qq{this is not $literal};
print "this is not literal\n";
print qq{this is not literal\n};
END_PERL

$policy = 'ValuesAndExpressions::RequireInterpolationOfMetachars';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = 01;
$var = 010;
$var = 001;
$var = 0010;
$var = 0.10;
$var = 00.001;
$var = -01;
$var = -010;
$var = -001;
$var = -0010;
$var = -0.10;
$var = -00.001;
$var = +01;
$var = +010;
$var = +001;
$var = +0010;
$var = +0.10;
$var = +00.001;
END_PERL

$policy = 'ValuesAndExpressions::ProhibitLeadingZeros';
is( critique($policy, \$code), 18, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = 0;
$var = 0.;
$var = 10;
$var = 0.0;
$var = 10.0;
$var = -0;
$var = -0.;
$var = -10;
$var = -0.0;
$var = -10.0;
$var = +0;
$var = +0.;
$var = +10;
$var = +0.0;
$var = +10.0;
END_PERL

$policy = 'ValuesAndExpressions::ProhibitLeadingZeros';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = 1234;
$var = 1234.01;
$var = 1234_567;
$var = 1234_567.;
$var = 1234_567.890;
$var = -1234_567.8901;
$var = -1234;
$var = -1234.01;
$var = -1234_567;
$var = -1234_567.;
$var = -1234_567.890;
$var = -1234_567.8901;
$var = +1234;
$var = +1234.01;
$var = +1234_567;
$var = +1234_567.;
$var = +1234_567.890;
$var = +1234_567.8901;

END_PERL

$policy = 'ValuesAndExpressions::RequireNumberSeparators';
is( critique($policy, \$code), 18, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = 1_234;
$var = 1_234.01;
$var = 1_234_567;
$var = 1_234_567.;
$var = 1_234_567.890_123;
$var = -1_234;
$var = -1_234.01;
$var = -1_234_567;
$var = -1_234_567.;
$var = -1_234_567.890_123;
$var = +1_234;
$var = +1_234.01;
$var = +1_234_567;
$var = +1_234_567.;
$var = +1_234_567.890_123;
END_PERL

$policy = 'ValuesAndExpressions::RequireNumberSeparators';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $fooBAR;
my $FooBar;
END_PERL

$policy = 'NamingConventions::ProhibitMixedCaseVars';
is( critique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $foo_BAR;
my $FOO_BAR;
my $foo_bar;
END_PERL

$policy = 'NamingConventions::ProhibitMixedCaseVars';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub fooBAR {}
sub FooBar {}
sub Foo_Bar {}
sub FOObar {}
END_PERL

$policy = 'NamingConventions::ProhibitMixedCaseSubs';
is( critique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub foo_BAR {}
sub foo_bar {}
sub FOO_bar {}
END_PERL

$policy = 'NamingConventions::ProhibitMixedCaseSubs';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub my_sub1 ($@) {}
sub my_sub2 (@@) {}
END_PERL

$policy = 'Subroutines::ProhibitSubroutinePrototypes';
is( critique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub my_sub1 {}
sub my_sub1 {}
END_PERL

$policy = 'Subroutines::ProhibitSubroutinePrototypes';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub open {}
sub map {}
sub eval {}
END_PERL

$policy = 'Subroutines::ProhibitHomonyms';
is( critique($policy, \$code), 3, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
sub my_open {}
sub my_map {}
sub eval2 {}
END_PERL

$policy = 'Subroutines::ProhibitHomonyms';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
use warnings;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageWarnings';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageWarnings';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use warnings;
$foo = $bar;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageWarnings';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
use strict;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageStricture';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageStricture';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Module;
use strict;
$foo = $bar;
END_PERL

$policy = 'TestingAndDebugging::RequirePackageStricture';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use constant FOO => 42;
use constant BAR => 24;
END_PERL

$policy = 'ValuesAndExpressions::ProhibitConstantPragma';
is( critique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $FOO = 42;
local BAR = 24;
our $NUTS = 16;
END_PERL

$policy = 'ValuesAndExpressions::ProhibitConstantPragma';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = "";
$var = ''
$var = '     ';
$var = "     ";
END_PERL

$policy = 'ValuesAndExpressions::ProhibitEmptyQuotes';
is( critique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = qq{};
$var = q{}
$var = qq{     };
$var = q{     };
END_PERL

$policy = 'ValuesAndExpressions::ProhibitEmptyQuotes';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = qq{this};
$var = q{that}
$var = qq{the};
$var = q{other};
$var = "this";
$var = 'that';
$var = 'the'; 
$var = "other";
END_PERL

$policy = 'ValuesAndExpressions::ProhibitEmptyQuotes';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = "!";
$var = '!';
$var = '!!';
$var = "||";
END_PERL

$policy = 'ValuesAndExpressions::ProhibitNoisyQuotes';
is( critique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$var = q{!};
$var = q{!};
$var = q{!!};
$var = q{||};
$var = "!!!";
$var = '!!!';
$var = 'a';
$var = "a";
$var = '1';
$var = "1";
END_PERL

$policy = 'ValuesAndExpressions::ProhibitNoisyQuotes';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<END_QUOTE;
Four score and seven years ago...
END_QUOTE
END_PERL

$policy = 'ValuesAndExpressions::RequireQuotedHeredocTerminator';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<'END_QUOTE';
Four score and seven years ago...
END_QUOTE
END_PERL

$policy = 'ValuesAndExpressions::RequireQuotedHeredocTerminator';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<"END_QUOTE";
Four score and seven years ago...
END_QUOTE
END_PERL

$policy = 'ValuesAndExpressions::RequireQuotedHeredocTerminator';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<"endquote";
Four score and seven years ago...
endquote
END_PERL

$policy = 'ValuesAndExpressions::RequireUpperCaseHeredocTerminator';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<endquote;
Four score and seven years ago...
endquote
END_PERL

$policy = 'ValuesAndExpressions::RequireUpperCaseHeredocTerminator';
is( critique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
print <<"QUOTE";
Four score and seven years ago...
QUOTE
END_PERL

$policy = 'ValuesAndExpressions::RequireUpperCaseHeredocTerminator';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
local $foo = $bar;
local $/ = undef;
local $| = 1;

#These should be caught,
#but PPI doesn't support.
#local ($foo, $bar) = ();
#local ($/) = undef;
END_PERL

$policy = 'Variables::ProhibitLocalVars';
is( critique($policy, \$code), 3, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
local $INPUT_RECORD_SEPARATOR;
local $PROGRAM_NAME;
my  $var1 = 'foo';
our $var2 = 'bar';
END_PERL

$policy = 'Variables::ProhibitLocalVars';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
our $var1 = 'foo';
our %var2 = 'foo';
$Package::var = 'nuts';
use vars qw($FOO $BAR);
END_PERL

$policy = 'Variables::ProhibitPackageVars';
is( critique($policy, \$code), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $var1 = 'foo';
my %var2 = 'foo';
my ($foo, $bar) = ();
END_PERL

$policy = 'Variables::ProhibitPackageVars';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$/ = undef;
$| = 1;
$> = 3;
END_PERL

$policy = 'Variables::ProhibitPunctuationVars';
is( critique($policy, \$code), 3, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$RS = undef;
$INPUT_RECORD_SEPARATOR = "\n";
$OUTPUT_AUTOFLUSH = 1;
print $foo, $baz;
END_PERL

$policy = 'Variables::ProhibitPunctuationVars';
is( critique($policy, \$code), 0, $policy);

#----------------------------------------------------------------
sub critique {
    my($policy, $code_ref, $config_ref) = @_;
    my $r = Perl::Critic->new( -profile => 'NONE' );
    $r->add_policy(-policy => $policy, -config => $config_ref);
    return scalar $r->critique($code_ref);
}
