use blib;
use strict;
use warnings;
use Test::More tests => 201;
use English qw(-no_match_vars);

our $VERSION = '0.12';
$VERSION = eval $VERSION;  ## pc:skip

my $obj = undef;
#---------------------------------------------------------------

use_ok('Perl::Critic');
can_ok('Perl::Critic', 'new');
can_ok('Perl::Critic', 'add_policy');
can_ok('Perl::Critic', 'critique');

$obj = Perl::Critic->new();
isa_ok($obj, 'Perl::Critic');
is($obj->VERSION(), $VERSION);

#---------------------------------------------------------------

use_ok('Perl::Critic::Config');
can_ok('Perl::Critic::Config', 'new');
can_ok('Perl::Critic::Config', 'find_profile');
can_ok('Perl::Critic::Config', 'default_config');

$obj = Perl::Critic::Config->new();
isa_ok($obj, 'Perl::Critic::Config');
is($obj->VERSION(), $VERSION);

#---------------------------------------------------------------

use_ok('Perl::Critic::Policy');
can_ok('Perl::Critic::Policy', 'new');
can_ok('Perl::Critic::Policy', 'violates');

$obj = Perl::Critic::Policy->new();
isa_ok($obj, 'Perl::Critic::Policy');
is($obj->VERSION(), $VERSION);

#---------------------------------------------------------------

use_ok('Perl::Critic::Violation');
can_ok('Perl::Critic::Violation', 'new');
can_ok('Perl::Critic::Violation', 'explanation');
can_ok('Perl::Critic::Violation', 'description');
can_ok('Perl::Critic::Violation', 'location');
can_ok('Perl::Critic::Violation', 'policy');
can_ok('Perl::Critic::Violation', 'to_string');

$obj = Perl::Critic::Violation->new(undef, undef, []);
isa_ok($obj, 'Perl::Critic::Violation');
is($obj->VERSION(), $VERSION);

#---------------------------------------------------------------

for my $mod ( Perl::Critic::Config::default_config() ) {

    $mod = "Perl::Critic::Policy::$mod";

    use_ok($mod);
    can_ok($mod, 'new');
    can_ok($mod, 'violates');

    $obj = $mod->new();
    isa_ok($obj, 'Perl::Critic::Policy');
    is($obj->VERSION(), $VERSION);
}

