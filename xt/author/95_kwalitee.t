#!/usr/bin/perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/xt/author/95_kwalitee.t $
#     $Date: 2008-07-22 06:47:03 -0700 (Tue, 22 Jul 2008) $
#   $Author: clonezone $
# $Revision: 2609 $
##############################################################################

use strict;
use warnings;

use English qw< -no_match_vars >;

use Test::More;

#-----------------------------------------------------------------------------

our $VERSION = '1.090';

#-----------------------------------------------------------------------------

eval {
   require Test::Kwalitee;
   Test::Kwalitee->import( tests => [ qw{ -no_symlinks } ] );
   1;
}
    or plan skip_all => 'Test::Kwalitee not installed; skipping';

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
