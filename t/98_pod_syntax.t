#!perl

##############################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/98_pod_syntax.t $
#    $Date: 2008-10-30 11:20:47 -0500 (Thu, 30 Oct 2008) $
#   $Author: clonezone $
# $Revision: 2850 $
##############################################################################

use 5.006001;
use strict;
use warnings;

use English qw< -no_match_vars >;

use Perl::Critic::TestUtils qw{ starting_points_including_examples };

use Test::More;

#-----------------------------------------------------------------------------

our $VERSION = '1.093_02';

#-----------------------------------------------------------------------------

eval 'use Test::Pod 1.00';  ## no critic (StringyEval)
plan skip_all => 'Test::Pod 1.00 required for testing POD' if $EVAL_ERROR;
all_pod_files_ok( all_pod_files( starting_points_including_examples() ) );

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
