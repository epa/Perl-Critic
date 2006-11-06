#!perl

##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.21/t/98_pod_syntax.t $
#    $Date: 2006-11-05 18:01:38 -0800 (Sun, 05 Nov 2006) $
#   $Author: thaljef $
# $Revision: 809 $
##################################################################

use strict;
use warnings;
use Test::More;

eval 'use Test::Pod 1.00';  ## no critic
plan skip_all => 'Test::Pod 1.00 required for testing POD' if $@;
all_pod_files_ok();