use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use Test::More qw(no_plan);
use English qw(-no_match_vars);

#---------------------------------------------------------------
# Test policy modules for compilation, methods and inheritance

my @policy_modules
  = qw(BuiltinFunctions::ProhibitStringyEval
       BuiltinFunctions::ProhibitStringyGrep
       BuiltinFunctions::ProhibitStringyMap
       CodeLayout::ProhibitParensWithBuiltins
       ControlStructures::ProhibitCascadingIfElse
       ControlStructures::ProhibitPostfixControls
       InputOutput::ProhibitBacktickOperators
       Modules::ProhibitMultiplePackages
       Modules::ProhibitRequireStatements
       Modules::ProhibitSpecificModules
       Modules::ProhibitUnpackagedCode
       NamingConventions::ProhibitMixedCaseSubs
       NamingConventions::ProhibitMixedCaseVars
       Subroutines::ProhibitHomonyms
       Subroutines::ProhibitSubroutinePrototypes
       TestingAndDebugging::RequirePackageStricture
       TestingAndDebugging::RequirePackageWarnings
       ValuesAndExpressions::ProhibitConstantPragma
       ValuesAndExpressions::ProhibitEmptyQuotes
       ValuesAndExpressions::ProhibitInterpolationOfLiterals
       ValuesAndExpressions::ProhibitLeadingZeros
       ValuesAndExpressions::ProhibitNoisyQuotes
       ValuesAndExpressions::RequireInterpolationOfMetachars
       ValuesAndExpressions::RequireNumberSeparators
       ValuesAndExpressions::RequireQuotedHeredocTerminator
       ValuesAndExpressions::RequireUpperCaseHeredocTerminator
       Variables::ProhibitLocalVars
       Variables::ProhibitPackageVars
       Variables::ProhibitPunctuationVars
);

for my $mod (@policy_modules) {

    #Test 'use'
    $mod = "Perl::Critic::Policy::$mod";
    use_ok($mod);

    #Test methods
    can_ok($mod, 'new');
    can_ok($mod, 'violations');

    #Test inheritance
    my $obj = $mod->new();
    isa_ok($obj, 'Perl::Critic::Policy');
}

#---------------------------------------------------------------
# Separate tests for modules that may have external dependancies

SKIP: {
  eval { require Perl::Tidy };
  skip( 'Perl::Tidy not installed', 3) if $EVAL_ERROR;
  my $mod = 'Perl::Critic::Policy::CodeLayout::RequireTidyCode';
  use_ok($mod);
  can_ok($mod, qw( new violations ) );
  isa_ok($mod->new(), 'Perl::Critic::Policy');
}

#---------------------------------------------------------------
# Test main modules for compilation, construction

my @main_modules =
qw(Critic
   Critic::Config
   Critic::Policy
   Critic::Violation
);

for my $mod (@main_modules) {

    #Test 'use'
    $mod = "Perl::$mod";
    use_ok($mod);

    #Test constructor
    can_ok($mod, 'new');
}

#---------------------------------------------------------------
# Test other methods
can_ok('Perl::Critic', 'add_policy');
can_ok('Perl::Critic', 'critique');
can_ok('Perl::Critic::Violation', 'location');
can_ok('Perl::Critic::Violation', 'description');
can_ok('Perl::Critic::Violation', 'explanation');

