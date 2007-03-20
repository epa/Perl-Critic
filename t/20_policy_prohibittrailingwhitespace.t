#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-1.05/t/20_policy_prohibittrailingwhitespace.t $
#     $Date: 2007-03-20 00:49:45 -0800 (Tue, 20 Mar 2007) $
#   $Author: thaljef $
# $Revision: 1323 $
##############################################################################

use strict;
use warnings;
use Test::More tests => 2;

use Perl::Critic::Utils qw( :characters );

use Perl::Critic::TestUtils qw( pcritique );
Perl::Critic::TestUtils::block_perlcriticrc();

# This specific policy is being tested without 20_policies.t because the .run file
# would have to contain invisible characters.

my $code;
my $policy = 'CodeLayout::ProhibitTrailingWhitespace';
my %config;
my @violations;
my $violation_line_number;
my $violation_column_number;

#-----------------------------------------------------------------------------

$code = <<"END_PERL";
say${SPACE}"\tblurp\t";\t
say${SPACE}"${SPACE}blorp${SPACE}";${SPACE}
\f


chomp;\t${SPACE}${SPACE}
chomp;${SPACE}${SPACE}\t
END_PERL

is ( pcritique($policy, \$code), 5, $policy );

#-----------------------------------------------------------------------------

$code = <<"END_PERL";
sub${SPACE}do_frobnication${SPACE}\{
\tfor${SPACE}(${SPACE}is_frobnicating()${SPACE})${SPACE}\{
${SPACE}${SPACE}${SPACE}${SPACE}frobnicate();
\l}
}

END_PERL

is( pcritique($policy, \$code), 0, $policy );

#-----------------------------------------------------------------------------

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
