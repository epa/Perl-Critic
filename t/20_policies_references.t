##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.19/t/20_policies_references.t $
#    $Date: 2006-08-20 13:46:40 -0700 (Sun, 20 Aug 2006) $
#   $Author: thaljef $
# $Revision: 633 $
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

# old PPI bug (fixed as of PPI v1.112): multiplication is mistakenly
# interpreted as a glob.

$code = <<'END_PERL';
$value = $one*$two;
END_PERL

$policy = 'References::ProhibitDoubleSigils';
is( pcritique($policy, \$code), 0, $policy);


