#!perl

##############################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-0.22/t/20_policy_requirefilenamematchespackage.t $
#    $Date: 2006-12-16 22:33:36 -0800 (Sat, 16 Dec 2006) $
#   $Author: thaljef $
# $Revision: 1103 $
##############################################################################

use strict;
use warnings;
use Test::More tests => 18;

# common P::C testing tools
use Perl::Critic::TestUtils qw(fcritique);
Perl::Critic::TestUtils::block_perlcriticrc();

my $policy = 'Modules::RequireFilenameMatchesPackage';

COLONCOLON: {
    my $code = 'package Filename::OK; 1;';

    my @goodfiles = qw(
        OK.pm
        Filename/OK.pm
        lib/Filename/OK.pm
        blib/lib/Filename/OK.pm
        OK.pl
        Filename-OK-1.00/OK.pm
        Filename-OK/OK.pm
        Foobar-1.00/OK.pm
    );
    for my $file ( @goodfiles ) {
        is( fcritique($policy, \$code, $file), 0, "$policy - $file" );
    }

    my @badfiles = qw(
        Bad.pm
        Filename/Bad.pm
        lib/Filename/BadOK.pm
        ok.pm
        filename/OK.pm
        Foobar/OK.pm
    );
    for my $file ( @badfiles ) {
        is( fcritique($policy, \$code, $file), 1, "$policy - $file" );
    }
}

#-----------------------------------------------------------------------------

APOSTROPHE: {
    my $code = 'package D\'Oh; 1;';

    my @goodfiles = qw( Oh.pm D/Oh.pm );
    for my $file ( @goodfiles ) {
        is( fcritique($policy, \$code, $file), 0, "$policy - $file" );
    }
    my @badfiles = qw( oh.pm d/Oh.pm );
    for my $file ( @badfiles ) {
        is( fcritique($policy, \$code, $file), 1, "$policy - $file" );
    }
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
