#use blib;
use strict;
use warnings;
use Test::More tests => 11;
use Perl::Critic;

my $code = undef;
my %config = ();

#----------------------------------------------------------------

$code = <<'END_PERL';
require 'some_library.pl';  ## no critic
print $crap if $condition;  ## no critic
END_PERL

is( critique(\$code), 0);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;
$foo = $bar;

## no critic

require 'some_library.pl';
print $crap if $condition;

## use critic

$baz = $nuts;

END_PERL

is( critique(\$code), 0);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;

for my $foo (@list) {
  ## no critic
  $long_int = 12345678;
  $oct_num  = 033;
}

my $noisy = '!';
END_PERL

is( critique(\$code), 1);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;

## no critic
for my $foo (@list) {
  $long_int = 12345678;
  $oct_num  = 033;
}
## use critic

my $noisy = '!';


END_PERL

is( critique(\$code), 1);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;

for my $foo (@list) {
  ## no critic
  $long_int = 12345678;
  $oct_num  = 033;
  ## use critic
}

my $noisy = '!';
my $empty = '';

END_PERL

is( critique(\$code), 2);

#----------------------------------------------------------------

$code = <<'END_PERL';
## no critic
package FOO;
use strict;
use warnings;

for my $foo (@list) {
  $long_int = 12345678;
  $oct_num  = 033;
}

my $noisy = '!';
my $empty = '';
END_PERL

is( critique(\$code), 0);

#----------------------------------------------------------------

$code = <<'END_PERL';
$long_int = 12345678;  ## no critic
$oct_num  = 033;       ## no critic
my $noisy = '!';       ## no critic
my $empty = '';        ## no critic
END_PERL

is( critique(\$code), 0);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;

$long_int = 12345678;  ## no critic
$oct_num  = 033;       ## no critic
my $noisy = '!';       ## no critic
my $empty = '';        ## no critic

$long_int = 12345678;
$oct_num  = 033;
my $noisy = '!';
my $empty = '';
END_PERL

is( critique(\$code), 4);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;

$long_int = 12345678;  ## no critic
$oct_num  = 033;       ## no critic
my $noisy = '!';       ## no critic
my $empty = '';        ## no critic

## use critic
$long_int = 12345678;
$oct_num  = 033;
my $noisy = '!';
my $empty = '';
END_PERL

%config = (-force => 1);
is( critique(\$code, \%config), 8);

#----------------------------------------------------------------

$code = <<'END_PERL';
## no critic
package FOO;
use strict;
use warnings;

for my $foo (@list) {
  $long_int = 12345678;
  $oct_num  = 033;
}

my $noisy = '!';
my $empty = '';
END_PERL

%config = (-force => 1);
is( critique(\$code, \%config), 4);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;


for my $foo (@list) {
  ## use critic
  $long_int = 12345678;
  $oct_num  = 033;
}

## use critic
my $noisy = '!';
my $empty = '';
END_PERL

%config = (-force => 1);
is( critique(\$code, \%config), 4);

#----------------------------------------------------------------
sub critique {
    my ($code_ref, $config_ref) = @_;
    my $c = Perl::Critic->new( %{$config_ref} );
    return scalar $c->critique($code_ref);
}
