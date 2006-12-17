#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.22/t/13_bundled_policies.t $
#     $Date: 2006-12-16 22:33:36 -0800 (Sat, 16 Dec 2006) $
#   $Author: thaljef $
# $Revision: 1103 $
##############################################################################

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::TestUtils qw(bundled_policy_names);
use Perl::Critic::Config;
use Test::More (tests => 1);

my $config = Perl::Critic::Config->new(-theme => 'core');
my @found_policies = sort map { policy_long_name(ref $_) } $config->policies();
is_deeply(\@found_policies, [bundled_policy_names()], 'successfully loaded policies matches MANIFEST');

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
