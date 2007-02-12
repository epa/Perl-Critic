#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-1.02/t/13_bundled_policies.t $
#     $Date: 2007-02-11 22:57:01 -0800 (Sun, 11 Feb 2007) $
#   $Author: thaljef $
# $Revision: 1228 $
##############################################################################

use strict;
use warnings;
use Perl::Critic::Config;
use Perl::Critic::PolicyFactory (-test => 1);
use Test::More (tests => 1);

# common P::C testing tools
use Perl::Critic::TestUtils qw(bundled_policy_names);
Perl::Critic::TestUtils::block_perlcriticrc();

#-----------------------------------------------------------------------------

my $config = Perl::Critic::Config->new( -theme => 'core', -profile => '' );
my @found_policies = sort map { ref $_ } $config->policies();
my $test_label = 'successfully loaded policies matches MANIFEST';
is_deeply( \@found_policies, [bundled_policy_names()], $test_label );

##############################################################################
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
