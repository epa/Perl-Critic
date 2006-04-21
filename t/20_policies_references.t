##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/20_policies_references.t $
#    $Date: 2006-04-20 10:26:17 -0700 (Thu, 20 Apr 2006) $
#   $Author: chrisdolan $
# $Revision: 386 $
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
$code = <<'END_PERL';
$value = $one*$two;
END_PERL

TODO: {
   local $TODO = 'PPI bug -- multiplication misinterpreted as a glob';
   $policy = 'References::ProhibitDoubleSigils';
   is( pcritique($policy, \$code), 0, $policy);
}

