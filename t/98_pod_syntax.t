##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.18/t/98_pod_syntax.t $
#    $Date: 2006-07-16 22:15:05 -0700 (Sun, 16 Jul 2006) $
#   $Author: thaljef $
# $Revision: 506 $
##################################################################

use strict;
use warnings;
use Test::More;

eval 'use Test::Pod 1.00';  ## no critic
plan skip_all => 'Test::Pod 1.00 required for testing POD' if $@;
all_pod_files_ok();