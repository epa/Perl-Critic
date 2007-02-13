#!perl

##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-1.03/t/80_policysummary.t $
#     $Date: 2007-02-13 10:58:53 -0800 (Tue, 13 Feb 2007) $
#   $Author: thaljef $
# $Revision: 1247 $
##############################################################################


use strict;
use warnings;
use File::Spec;
use Test::More;
use List::MoreUtils qw(any);
use Perl::Critic::PolicyFactory ( -test => 1 );
use Perl::Critic::TestUtils qw{ should_skip_author_tests get_author_test_skip_message 
                                bundled_policy_names };

#-----------------------------------------------------------------------------

if (should_skip_author_tests()) {
    plan skip_all => get_author_test_skip_message();
}

if (open my ($fh), '<', File::Spec->catfile(qw(lib Perl Critic PolicySummary.pod))) {

    my @policy_names = bundled_policy_names();
    my @summaries    = map { m/^=head2 [ ]+ L<([\w:]+)>/mx } <$fh>;
    plan( tests => scalar @policy_names );

    for my $policy_name ( @policy_names ) {
        my $label = qq{PolicySummary.pod has "$policy_name"};
        my $has_summary = any{ $_ eq $policy_name } @summaries;
        is( $has_summary, 1, $label );
    }
}
else {
    fail 'Cannot locate the PolicySummary.pod file';
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
