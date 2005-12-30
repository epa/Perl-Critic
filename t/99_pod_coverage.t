##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/99_pod_coverage.t $
#    $Date: 2005-12-29 12:29:22 -0800 (Thu, 29 Dec 2005) $
#   $Author: thaljef $
# $Revision: 174 $
##################################################################

use strict;
use warnings;
use Test::More;

eval 'use Test::Pod::Coverage 1.00';
plan skip_all => 'Test::Pod::Coverage 1.00 requried to test POD' if $@;
my $trusted_rx = qr{ \A (?: new | violates | applies_to | default_severity ) \z }x; 
my $trustme = { trustme => [ $trusted_rx ] };
all_pod_coverage_ok($trustme);