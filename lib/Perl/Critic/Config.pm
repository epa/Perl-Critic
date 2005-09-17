package Perl::Critic::Config;

use strict;
use warnings;
use Config::Std;
use English qw(-no_match_vars);
use File::Spec::Functions qw(catfile);

use vars qw($VERSION);
$VERSION = '0.06';

sub new {

    my ( $class, %args ) = @_;

    my $profile = defined $args{-profile} ? $args{-profile} : _find_profile();
    my ( %user_config, %final_config ) = ();

    # $profile can be a path to a config file, or a
    # hash reference that contains the profile itself.
    # If $profile is an empty string, then don't try
    # to load any config file at all.

    if ( ref $profile eq 'HASH' ) {
        %user_config = %{$profile};
    }
    elsif ( defined $profile && length $profile ) {
        read_config( $profile => %user_config );
    }

    # Merge user config with the default config
    for my $policy ( _default_config() ) {
        next if exists $user_config{"-$policy"};
        $final_config{$policy} = $user_config{$policy};
    }

    for my $policy ( keys %user_config ) {
        next if $policy =~ m{\A -}x;
        $final_config{$policy} = $user_config{$policy};
    }

    return bless \%final_config, $class;
}

#----------------------------------------------------------------------------

sub _find_profile {
    my $rc_file = '.perlcriticrc';

    #Check explicit setting
    return $ENV{PERLCRITIC} if exists $ENV{PERLCRITIC};

    #Check usual env vars
    for my $var (qw(HOME USERPROFILE HOMESHARE)) {
        my $path = catfile( $ENV{$var}, $rc_file );
        return $path if -f $path;
    }

    #Check current directory
    return $rc_file if -f $rc_file;

    #No profile found!
    return;
}

sub _default_config {

    return qw( BuiltinFunctions::ProhibitStringyEval
	       BuiltinFunctions::ProhibitStringyGrep
	       BuiltinFunctions::ProhibitStringyMap
	       CodeLayout::ProhibitParensWithBuiltins
	       ControlStructures::ProhibitCascadingIfElse
	       ControlStructures::ProhibitPostfixControls
	       InputOutput::ProhibitBacktickOperators
	       Modules::ProhibitMultiplePackages
	       Modules::ProhibitRequireStatements
	       Modules::ProhibitSpecificModules
	       Modules::ProhibitUnpackagedCode
	       NamingConventions::ProhibitMixedCaseSubs
	       NamingConventions::ProhibitMixedCaseVars
	       Subroutines::ProhibitHomonyms
	       Subroutines::ProhibitSubroutinePrototypes
	       TestingAndDebugging::RequirePackageStricture
	       TestingAndDebugging::RequirePackageWarnings
	       ValuesAndExpressions::ProhibitConstantPragma
	       ValuesAndExpressions::ProhibitEmptyQuotes
	       ValuesAndExpressions::ProhibitInterpolationOfLiterals
	       ValuesAndExpressions::ProhibitLeadingZeros
	       ValuesAndExpressions::ProhibitNoisyQuotes
	       ValuesAndExpressions::RequireInterpolationOfMetachars
	       ValuesAndExpressions::RequireNumberSeparators
	       ValuesAndExpressions::RequireQuotedHeredocTerminator
	       ValuesAndExpressions::RequireUpperCaseHeredocTerminator
	       Variables::ProhibitLocalVars
	       Variables::ProhibitPackageVars
	       Variables::ProhibitPunctuationVars
    );
}

__END__

=head1 NAME

Perl::Critic::Config

=head1 DESCRIPTION

This class is used internally by L<Perl::Critic>.  There is nothing to
see here (yet).

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
