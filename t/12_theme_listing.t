#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/distributions/Perl-Critic/t/12_theme_listing.t $
#     $Date: 2009-01-01 12:50:16 -0600 (Thu, 01 Jan 2009) $
#   $Author: clonezone $
# $Revision: 2938 $
##############################################################################

use 5.006001;
use strict;
use warnings;

use English qw<-no_match_vars>;

use Perl::Critic::UserProfile;
use Perl::Critic::PolicyFactory (-test => 1);
use Perl::Critic::ThemeListing;

use Test::More tests => 1;

#-----------------------------------------------------------------------------

our $VERSION = '1.094';

#-----------------------------------------------------------------------------

my $profile = Perl::Critic::UserProfile->new( -profile => 'NONE' );
my @policy_names = Perl::Critic::PolicyFactory::site_policy_names();
my $factory = Perl::Critic::PolicyFactory->new( -profile => $profile );
my @policies = map { $factory->create_policy( -name => $_ ) } @policy_names;
my $listing = Perl::Critic::ThemeListing->new( -policies => \@policies );

my $expected = <<'END_EXPECTED';
bugs
complexity
core
cosmetic
maintenance
pbp
performance
portability
readability
security
tests
unicode
END_EXPECTED

my $listing_as_string = "$listing";
is( $listing_as_string, $expected, 'Theme list matched.' );

#-----------------------------------------------------------------------------

# ensure we run true if this test is loaded by
# t/12_themelisting.t_without_optional_dependencies.t
1;

#-----------------------------------------------------------------------------
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
