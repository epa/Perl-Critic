##################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/20_policies_documentation.t $
#     $Date: 2006-01-29 18:18:18 -0800 (Sun, 29 Jan 2006) $
#   $Author: chrisdolan $
# $Revision: 271 $
##################################################################

use strict;
use warnings;
use Test::More tests => 5;
use Perl::Critic::Config;
use Perl::Critic;

# common P::C testing tools
use lib qw(t/tlib);
use PerlCriticTestUtils qw(pcritique);
PerlCriticTestUtils::block_perlcriticrc();

my $code;
my $policy;

#----------------------------------------------------------------

$code = <<'END_PERL';
#Nothing!
END_PERL

$policy = 'Documentation::RequirePodAtEnd';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
__END__
#Nothing!
END_PERL

$policy = 'Documentation::RequirePodAtEnd';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
=head1 Foo

=cut
END_PERL

$policy = 'Documentation::RequirePodAtEnd';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
__END__

=head1 Foo

=cut
END_PERL

$policy = 'Documentation::RequirePodAtEnd';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';

=head1 Foo

=cut

__END__

=head1 Bar

=cut
END_PERL

$policy = 'Documentation::RequirePodAtEnd';
is( pcritique($policy, \$code), 1, $policy);
