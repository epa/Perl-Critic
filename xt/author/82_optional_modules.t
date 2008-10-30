#!/usr/bin/perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/xt/author/82_optional_modules.t $
#     $Date: 2008-10-30 11:20:47 -0500 (Thu, 30 Oct 2008) $
#   $Author: clonezone $
# $Revision: 2850 $
##############################################################################

use 5.006001;
use strict;
use warnings;

use Readonly; # So we don't barf when we hit Readonly::XS below.

use lib 'inc';
use Perl::Critic::BuildUtilities qw< recommended_module_versions >;

use Test::More;

#-----------------------------------------------------------------------------

our $VERSION = '1.093_02';

#-----------------------------------------------------------------------------

# Certain developers change perl installations on occasion and don't always
# have all the optional modules installed.  Make sure that they know that they
# don't.  :]

my %module_versions = recommended_module_versions();

plan tests => scalar keys %module_versions;

foreach my $module (sort keys %module_versions) {
    use_ok( $module, $module_versions{$module} );
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
