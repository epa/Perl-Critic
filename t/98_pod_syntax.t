##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.19/t/98_pod_syntax.t $
#    $Date: 2006-08-20 13:46:40 -0700 (Sun, 20 Aug 2006) $
#   $Author: thaljef $
# $Revision: 633 $
##################################################################

use strict;
use warnings;
use Test::More;

eval 'use Test::Pod 1.00';  ## no critic
plan skip_all => 'Test::Pod 1.00 required for testing POD' if $@;
all_pod_files_ok();