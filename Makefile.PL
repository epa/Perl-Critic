use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile( NAME           => 'Perl::Critic',
	       AUTHOR         => 'Jeffrey Thalhammer <thaljef@cpan.org>',
	       ABSTRACT_FROM  => 'lib/Perl/Critic.pm',
	       VERSION_FROM   => 'lib/Perl/Critic.pm',
	       EXE_FILES      => ['bin/perlcritic'],
	       PREREQ_PM      => {'PPI'                   => 1.003,
				  'Config::Std'           => 0,
				  'File::Spec::Functions' => 0,
				  'List::MoreUtils'       => 0,
				  'List::Util'            => 0,
				  'Pod::Usage'            => 0,
                                  'Test::More'            => 0,
				  'FindBin'               => 0,
			      },
	       PL_FILES       => {},
);
