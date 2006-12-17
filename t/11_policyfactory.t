#!perl

##############################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.22/t/11_policyfactory.t $
#    $Date: 2006-12-16 22:33:36 -0800 (Sat, 16 Dec 2006) $
#   $Author: thaljef $
# $Revision: 1103 $
##############################################################################

use strict;
use warnings;
use English qw(-no_mactch_vars);
use Test::More tests => 12;
use Perl::Critic::UserProfile;
use Perl::Critic::PolicyFactory;

# common P::C testing tools
use Perl::Critic::TestUtils qw();
Perl::Critic::TestUtils::block_perlcriticrc();

#-----------------------------------------------------------------------------

{
    my $policy_name = 'Perl::Critic::Policy::CodeLayout::RequireTidyCode';
    my $params = {severity => 5, set_themes => 'foo bar', add_themes => 'bar baz'};
    my $profile  = {$policy_name => $params};
    my $userprof = Perl::Critic::UserProfile->new( -profile => $profile );

    my $pf = Perl::Critic::PolicyFactory->new( -profile  => $userprof,
                                               -policy_names => [$policy_name] );


    # Now test...
    my @policies = $pf->policies();
    is( scalar @policies, 1, 'Created 1 policy');

    my $policy = $policies[0];
    is( ref $policy, $policy_name, 'Created correct type of policy');

    my $severity = $policy->get_severity();
    is( $severity, 5, 'Set the severity');

    my @themes = $policy->get_themes();
    is_deeply( \@themes, [ qw(bar baz foo) ], 'Set the theme');
}

#-----------------------------------------------------------------------------

{
    my $policy_name = 'Perl::Critic::Policy::Modules::ProhibitEvilModules';
    my $params = {severity => 2, set_themes => 'betty', add_themes => 'wilma'};

    my $userprof = Perl::Critic::UserProfile->new( -profile => 'NONE' );
    my $pf = Perl::Critic::PolicyFactory->new( -profile  => $userprof );


    # Now test...
    my $policy = $pf->create_policy( $policy_name, $params );
    is( ref $policy, $policy_name, 'Created correct type of policy');

    my $severity = $policy->get_severity();
    is( $severity, 2, 'Set the severity');

    my @themes = $policy->get_themes();
    is_deeply( \@themes, [ qw(betty wilma) ], 'Set the theme');
}

#-----------------------------------------------------------------------------
# Using short module name.
{
    my $policy_name = 'Variables::ProhibitPunctuationVars';
    my $params = {set_themes => 'betty', add_themes => 'wilma'};

    my $userprof = Perl::Critic::UserProfile->new( -profile => 'NONE' );
    my $pf = Perl::Critic::PolicyFactory->new( -profile  => $userprof );


    # Now test...
    my $policy = $pf->create_policy( $policy_name, $params );
    my $policy_name_long = 'Perl::Critic::Policy::' . $policy_name;
    is( ref $policy, $policy_name_long, 'Created correct type of policy');

    my @themes = $policy->get_themes();
    is_deeply( \@themes, [ qw(betty wilma) ], 'Set the theme');
}

#-----------------------------------------------------------------------------
# Test exception handling

{
    my $bogus_policy = 'Perl::Critic::Foo';
    my $userprof = Perl::Critic::UserProfile->new( -profile => 'NONE' );
    my $pf = Perl::Critic::PolicyFactory->new( -profile  => $userprof );

    # Try creating bogus policy
    eval{ $pf->create_policy( $bogus_policy ) };
    like( $EVAL_ERROR, qr/Can't locate object method/m, 'create bogus policy' );

    # Try using a bogus severity level
    my $policy_name = 'Modules::RequireVersionVar';
    eval{ $pf->create_policy( $policy_name, {severity => 'bogus'} ) };
    like( $EVAL_ERROR, qr/Invalid severity: "bogus"/m, 'create policy w/ bogus severity' );
}



TODO:{

    # Try loading from bogus namespace
    local $TODO = 'Test not working yet';
    $Perl::Critic::Utils::POLICY_NAMESPACE = 'bogus';
    eval { Perl::Critic::PolicyFactory->import() };
    like( $EVAL_ERROR, qr/No Policies found/, 'loading from bogus namespace' );

}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :