##################################################################
#     $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/t/20_policies_modules.t $
#    $Date: 2006-03-05 21:53:07 -0800 (Sun, 05 Mar 2006) $
#   $Author: thaljef $
# $Revision: 313 $
##################################################################

use strict;
use warnings;
use Test::More tests => 37;
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
#no package
$some_code = $foo;
END_PERL

$policy = 'Modules::ProhibitMultiplePackages';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
package foo;
package bar;
package nuts;
$some_code = undef;
END_PERL

$policy = 'Modules::ProhibitMultiplePackages';
is( pcritique($policy, \$code), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
package foo;
$some_code = undef;
END_PERL

$policy = 'Modules::ProhibitMultiplePackages';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
require; #incomplete statement
use;     #incomplete statement
no;      #incomplete statement
END_PERL

$policy = 'Modules::RequireBarewordIncludes';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
require 'Exporter';
require 'My/Module.pl';
use 'SomeModule';
use "OtherModule.pm";
no "Module";
no "Module.pm";
END_PERL

$policy = 'Modules::RequireBarewordIncludes';
is( pcritique($policy, \$code), 6, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
require MyModule;
use MyModule;
no MyModule;
use strict;
END_PERL

$policy = 'Modules::RequireBarewordIncludes';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = $bar;
package foo;
END_PERL

$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Some::Module;
package foo;
END_PERL

$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Some::Module;
print 'whatever';
END_PERL

$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
package foo;
use strict;
$foo = $bar;
END_PERL

$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
#!/usr/bin/perl
$foo = $bar;
package foo;
END_PERL

%config = (exempt_scripts => 1); 
$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
#!/usr/bin/perl
use strict;
use warnings;
my $foo = 42;
END_PERL

%config = (exempt_scripts => 0);
$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code, \%config), 1, $policy);


#----------------------------------------------------------------

$code = <<'END_PERL';
#!/usr/bin/perl
package foo;
$foo = $bar;
END_PERL

%config = (exempt_scripts => 0); 
$policy = 'Modules::RequireExplicitPackage';
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Evil::Module qw(bad stuff);
use Super::Evil::Module;
END_PERL

$policy = 'Modules::ProhibitEvilModules';
%config = (modules => 'Evil::Module Super::Evil::Module');
is( pcritique($policy, \$code, \%config), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Good::Module;
END_PERL

$policy = 'Modules::ProhibitEvilModules';
%config = (modules => 'Evil::Module Super::Evil::Module');
is( pcritique($policy, \$code, \%config), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Evil::Module qw(bad stuff);
use Demonic::Module
END_PERL

$policy = 'Modules::ProhibitEvilModules';
%config = (modules => '/Evil::/ /Demonic/');
is( pcritique($policy, \$code, \%config), 2, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use Evil::Module qw(bad stuff);
use Super::Evil::Module;
use Demonic::Module;
use Acme::Foo;
END_PERL

$policy = 'Modules::ProhibitEvilModules';
%config = (modules => '/Evil::/ Demonic::Module /Acme/');
is( pcritique($policy, \$code, \%config), 4, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
#Nothing!
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
our $VERSION = 1.0;
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
our ($VERSION) = 1.0;
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$Package::VERSION = 1.0;
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use vars '$VERSION';
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
use vars qw($VERSION);
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
my $VERSION;
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
our $Version;
END_PERL

$policy = 'Modules::RequireVersionVar';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
__END__
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
__DATA__
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
# The end
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1; # final true value
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1  ;   #With extra space.
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
  1  ;   #With extra space.
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
$foo = 2; 1;   #On same line..
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 0, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
0;
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
sub foo {}
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
1;
END {}
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 1, $policy);

#----------------------------------------------------------------

$code = <<'END_PERL';
'Larry';
END_PERL

$policy = 'Modules::RequireEndWithOne';
is( pcritique($policy, \$code), 1, $policy);
