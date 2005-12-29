##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/99_pod-coverage.t $
#    $Date: 2005-12-13 16:46:24 -0800 (Tue, 13 Dec 2005) $
#   $Author: thaljef $
# $Revision: 121 $
##################################################################

use strict;
use warnings;
use Test::More;

eval 'use Test::Pod::Coverage 1.00';
plan skip_all => 'Test::Pod::Coverage 1.00 requried to test POD' if $@;
my $trusted_rx = qr{ \A (?: new | violates | applies_to | default_severity ) \z }x; 
my $trustme = { trustme => [ $trusted_rx ] };
all_pod_coverage_ok($trustme);