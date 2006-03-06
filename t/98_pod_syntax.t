##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/98_pod_syntax.t $
#    $Date: 2006-02-03 22:44:18 -0800 (Fri, 03 Feb 2006) $
#   $Author: thaljef $
# $Revision: 296 $
##################################################################

use strict;
use warnings;
use Test::More;

eval 'use Test::Pod 1.00';  ## no critic
plan skip_all => 'Test::Pod 1.00 required for testing POD' if $@;
all_pod_files_ok();