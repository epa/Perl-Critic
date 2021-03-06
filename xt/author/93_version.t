#!perl -w

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/branches/Perl-Critic-backlog/xt/author/93_version.t $
#     $Date: 2009-09-07 16:19:21 -0500 (Mon, 07 Sep 2009) $
#   $Author: clonezone $
# $Revision: 3629 $
##############################################################################

use strict;
use warnings;

use English qw< -no_match_vars >;
use Carp qw< confess >;

use File::Find;

use Test::More;

#-----------------------------------------------------------------------------

our $VERSION = '1.105';

#-----------------------------------------------------------------------------

plan 'no_plan';

my $last_version = undef;
find({wanted => \&check_version, no_chdir => 1}, 'blib');
if (! defined $last_version) {
    fail('Failed to find any files with $VERSION'); ## no critic (RequireInterpolationOfMetachars)
}

sub check_version {
    return if (! m< blib/script/ >xms && ! m< [.] pm \z >xms);

    local $INPUT_RECORD_SEPARATOR = undef;
    my $fh;
    open $fh, '<', $_ or confess "$OS_ERROR";
    my $content = <$fh>;
    close $fh or confess "$OS_ERROR";

    # Skip POD
    $content =~ s/^__END__.*//xms;

    # only look at perl scripts, not sh scripts
    return if (m{blib/script/}xms && $content !~ m/\A \#![^\r\n]+?perl/xms);

    my @version_lines = $content =~ m/ ( [^\n]* \$VERSION\b [^\n]* ) /gxms;
    # Special cases for printing/documenting version numbers
    @version_lines = grep {! m/(?:\\|\"|\'|C<|v)\$VERSION/xms} @version_lines;
    @version_lines = grep {! m/^\s*\#/xms} @version_lines;
    if (@version_lines == 0) {
        fail($_);
    }
    for my $line (@version_lines) {
        if (!defined $last_version) {
            $last_version = shift @version_lines;
            pass($_);
        }
        else {
            is($line, $last_version, $_);
        }
    }

    return;
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
