use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(

  module_name    => 'Perl::Critic',
  dist_author    => 'Jeffrey Thalhammer <thaljef@cpan.org>',
  dist_abstract  => 'Critiques Perl source code',
  license        => 'perl',

  requires       => {'PPI'                   => 1.003,
	             'Config::Std'           => 0,
	             'File::Spec::Functions' => 0,
  	             'List::MoreUtils'       => 0,
	             'List::Util'            => 0,
	             'Pod::Usage'            => 0,
	             'English'               => 0,
	            },

  build_requires => {'Test::More'            => 0,
	             'FindBin'               => 0,
                    },

  recommends     => {'Perl::Tidy'            => 0,},
  script_files   => ['bin/perlcritic'],
);

$builder->create_build_script();
