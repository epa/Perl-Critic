#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/branches/Perl-Critic-backlog/xt/author/42_criticize-tests.t $
#     $Date: 2009-09-07 16:19:21 -0500 (Mon, 07 Sep 2009) $
#   $Author: clonezone $
# $Revision: 3629 $
##############################################################################

# Self-compliance tests

use strict;
use warnings;

use English qw( -no_match_vars );

use File::Spec qw();

use Perl::Critic::Utils qw{ :characters };
use Perl::Critic::TestUtils qw{ starting_points_including_examples };

# Note: "use PolicyFactory" *must* appear after "use TestUtils" for the
# -extra-test-policies option to work.
use Perl::Critic::PolicyFactory ( '-test' => 1 );

use Test::More;

#-----------------------------------------------------------------------------

our $VERSION = '1.105';

#-----------------------------------------------------------------------------

use Test::Perl::Critic;

#-----------------------------------------------------------------------------

# Fall over if P::C::More isn't installed.
use Perl::Critic::Policy::ErrorHandling::RequireUseOfExceptions;

#-----------------------------------------------------------------------------
# Set up PPI caching for speed (used primarily during development)

if ( $ENV{PERL_CRITIC_CACHE} ) {
    require PPI::Cache;
    my $cache_path =
        File::Spec->catdir(
            File::Spec->tmpdir,
            "test-perl-critic-cache-$ENV{USER}",
        );
    if ( ! -d $cache_path) {
        mkdir $cache_path, oct 700;
    }
    PPI::Cache->import( path => $cache_path );
}

#-----------------------------------------------------------------------------
# Run critic against all of our own files

my $rcfile = File::Spec->catfile( 'xt', 'author', '42_perlcriticrc-tests' );
Test::Perl::Critic->import( -profile => $rcfile );

all_critic_ok(
    glob ('t/*.t'),
    glob ('xt/author/*.t'),
    'generate_without_optional_dependencies_wrappers.PL',
);

#-----------------------------------------------------------------------------

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
