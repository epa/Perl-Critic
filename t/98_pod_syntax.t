##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/98_pod_syntax.t $
#    $Date: 2005-12-29 12:29:22 -0800 (Thu, 29 Dec 2005) $
#   $Author: thaljef $
# $Revision: 174 $
##################################################################

use strict;
use warnings;
use Test::More;

eval 'use Test::Pod 1.00';
plan skip_all => 'Test::Pod 1.00 required for testing POD' if $@;
all_pod_files_ok();