##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/20_policies_references.t $
#    $Date: 2006-05-08 23:15:31 -0700 (Mon, 08 May 2006) $
#   $Author: thaljef $
# $Revision: 420 $
##################################################################

use strict;
use warnings;
use Test::More tests => 3;
use Perl::Critic::Config;
use Perl::Critic;

# common P::C testing tools
use lib qw(t/tlib);
use PerlCriticTestUtils qw(pcritique);
PerlCriticTestUtils::block_perlcriticrc();

my $code ;
my $policy;
my %config;

#----------------------------------------------------------------

$code = <<'END_PERL';
%hash   = %{ $some_ref };
@array  = @{ $some_ref };
$scalar = ${ $some_ref };

$some_ref = \%hash;
$some_ref = \@array;
$some_ref = \$scalar;
$some_ref = \&code;
END_PERL

$policy = 'References::ProhibitDoubleSigils';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
%hash   = %$some_ref;
%array  = @$some_ref;
%scalar = $$some_ref;

%hash   = ( %$some_ref );
%array  = ( @$some_ref );
%scalar = ( $$some_ref );
END_PERL

$policy = 'References::ProhibitDoubleSigils';
is( pcritique($policy, \$code), 6, $policy);

#----------------------------------------------------------------

# PPI bug: multiplication is mistakenly interpreted as a glob.
#
# Update 2006-05-08: As-of PPI v1.112, this seems to be fixed.
# So this test is no longer a "TODO" test.

$code = <<'END_PERL';
$value = $one*$two;
END_PERL

$policy = 'References::ProhibitDoubleSigils';
is( pcritique($policy, \$code), 0, $policy);


