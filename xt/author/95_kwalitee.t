#!/usr/bin/perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/branches/Perl-Critic-PPI-1.203-cleanup/xt/author/95_kwalitee.t $
#     $Date: 2009-07-17 23:35:52 -0500 (Fri, 17 Jul 2009) $
#   $Author: clonezone $
# $Revision: 3385 $
##############################################################################

use strict;
use warnings;

use English qw< -no_match_vars >;

use Test::More;

#-----------------------------------------------------------------------------

our $VERSION = '1.100';

#-----------------------------------------------------------------------------

use Test::Kwalitee tests => [ qw{ -no_symlinks } ];

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
