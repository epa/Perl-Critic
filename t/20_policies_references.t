##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.18_01/t/20_policies_references.t $
#    $Date: 2006-08-06 16:13:55 -0700 (Sun, 06 Aug 2006) $
#   $Author: thaljef $
# $Revision: 556 $
##################################################################

use strict;
use warnings;
use Test::More tests => 3;

# common P::C testing tools
use Perl::Critic::TestUtils qw(pcritique);
Perl::Critic::TestUtils::block_perlcriticrc();

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


