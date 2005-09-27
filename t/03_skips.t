use blib;
use strict;
use warnings;
use Test::More tests => 10;
use Perl::Critic;

my $code = undef;
my %config = ();

#----------------------------------------------------------------

$code = <<'END_PERL';
require 'some_library.pl';  ## pc:skip
print $crap if $condition;  ## pc:skip
END_PERL

is( critique(\$code), 0);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;
$foo = $bar;

## pc: begin-skip

require 'some_library.pl';
print $crap if $condition;

## pc: end-skip

$baz = $nuts;

END_PERL

is( critique(\$code), 0);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;

for my $foo (@list) {
  ## pc: begin-skip
  $long_int = 12345678;
  $oct_num  = 033;
  ## pc: end-skip
}

my $noisy = '!';
END_PERL

is( critique(\$code), 1);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;

for my $foo (@list) {
  ## pc: begin-skip
  $long_int = 12345678;
  $oct_num  = 033;
}

my $noisy = '!';
## pc: end-skip

END_PERL

is( critique(\$code), 1);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;

for my $foo (@list) {
  ## pc:begin-skip
  $long_int = 12345678;
  $oct_num  = 033;
  ## pc:end-skip
}

my $noisy = '!';
my $empty = '';

END_PERL

is( critique(\$code), 2);

#----------------------------------------------------------------

$code = <<'END_PERL';
## pc:begin-skip
package FOO;
use strict;
use warnings;

for my $foo (@list) {
  $long_int = 12345678;
  $oct_num  = 033;
}

my $noisy = '!';
my $empty = '';
## pc:end-skip
END_PERL

is( critique(\$code), 0);

#----------------------------------------------------------------

$code = <<'END_PERL';
$long_int = 12345678;  ## pc:skip
$oct_num  = 033;       ## pc:skip
my $noisy = '!';       ## pc:skip
my $empty = '';        ## pc:skip
END_PERL

is( critique(\$code), 0);

#----------------------------------------------------------------

$code = <<'END_PERL';
package FOO;
use strict;
use warnings;

$long_int = 12345678;  ## pc:skip
$oct_num  = 033;       ## pc:skip
my $noisy = '!';       ## pc:skip
my $empty = '';        ## pc:skip

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

$long_int = 12345678;  ## pc:skip
$oct_num  = 033;       ## pc:skip
my $noisy = '!';       ## pc:skip
my $empty = '';        ## pc:skip

$long_int = 12345678;
$oct_num  = 033;
my $noisy = '!';
my $empty = '';
END_PERL

%config = (-noskip => 1);
is( critique(\$code, \%config), 8);

#----------------------------------------------------------------

$code = <<'END_PERL';
## pc:begin-skip
package FOO;
use strict;
use warnings;

for my $foo (@list) {
  $long_int = 12345678;
  $oct_num  = 033;
}

my $noisy = '!';
my $empty = '';
## pc:end-skip
END_PERL

%config = (-noskip => 1);
is( critique(\$code, \%config), 4);

#----------------------------------------------------------------
sub critique {
    my ($code_ref, $config_ref) = @_;
    my $r = Perl::Critic->new( %{$config_ref} );
    return scalar $r->critique($code_ref);
}
