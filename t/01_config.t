use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use Test::More tests => 12;
use Perl::Critic;

my $c = undef;
my $samples_dir   = "$Bin/../t/samples";
my $config_none   = "$samples_dir/perlcriticrc.none";
my $config_all    = "$samples_dir/perlcriticrc.all";
my $config_levels = "$samples_dir/perlcriticrc.levels";

#--------------------------------------------------------------
# Test default config
$c = Perl::Critic->new( -profile => undef);
is(scalar $c->policies, 30);

#--------------------------------------------------------------
# Test default config w/ priorities
$c = Perl::Critic->new( -profile => undef, -priority => 2);
is(scalar $c->policies, 30);

#--------------------------------------------------------------
# Test all-off config
$c = Perl::Critic->new( -profile => $config_none);
is(scalar $c->policies, 0);

#--------------------------------------------------------------
# Test all-off config w/ priorities
$c = Perl::Critic->new( -profile => $config_none, -priority => 2);
is(scalar $c->policies, 0);

#--------------------------------------------------------------
# Test all-on config
$c = Perl::Critic->new( -profile => $config_all);
is(scalar $c->policies, 30);

#--------------------------------------------------------------
# Test all-on config w/ priorities
$c = Perl::Critic->new( -profile => $config_all, -priority => 2);
is(scalar $c->policies, 30);

#--------------------------------------------------------------
# Test config w/ multiple priority levels
$c = Perl::Critic->new( -profile => $config_levels, -priority => 1);
is(scalar $c->policies, 3);

$c = Perl::Critic->new( -profile => $config_levels, -priority => 2);
is(scalar $c->policies, 4);

$c = Perl::Critic->new( -profile => $config_levels, -priority => 3);
is(scalar $c->policies, 6);

$c = Perl::Critic->new( -profile => $config_levels, -priority => 4);
is(scalar $c->policies, 7);

$c = Perl::Critic->new( -profile => $config_levels, -priority => 5);
is(scalar $c->policies, 11);

$c = Perl::Critic->new( -profile => $config_levels, -priority => 20);
is(scalar $c->policies, 30);