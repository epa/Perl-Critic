#!perl

##############################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-1.04/t/98_pod_syntax.t $
#    $Date: 2007-03-19 18:06:56 -0800 (Mon, 19 Mar 2007) $
#   $Author: thaljef $
# $Revision: 1308 $
##############################################################################

use strict;
use warnings;
use Test::More;
use Perl::Critic::TestUtils qw{ starting_points_including_examples };

eval 'use Test::Pod 1.00';  ## no critic
plan skip_all => 'Test::Pod 1.00 required for testing POD' if $@;
all_pod_files_ok( all_pod_files( starting_points_including_examples() ) );

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
