package Perl::Critic::Config;

use strict;
use warnings;
use Config::Tiny;
use English qw(-no_match_vars);
use File::Spec;

our $VERSION = '0.08_02';
$VERSION = eval $VERSION; ## pc:skip

#-----------------------------------------------------------------------------

sub new {

    my ( $class, %args ) = @_;

    my $profile = defined $args{-profile} ? $args{-profile} : find_profile();
    my ( $user_config, %final_config ) = ();

    # $profile can be a path to a config file, or a
    # hash reference that contains the profile itself.
    # If $profile is an empty string, then don't try
    # to load any config file at all.

    if ( ref $profile eq 'HASH' ) {
        $user_config = $profile;
    }
    elsif ( defined $profile && length $profile ) {
        $user_config = Config::Tiny->read( $profile );
	
    }

    # Merge user config with the default config
    for my $policy ( default_config() ) {
        next if exists $user_config->{"-$policy"};
        $final_config{$policy} = $user_config->{$policy};
    }

    for my $policy ( keys %{ $user_config } ) {
        next if $policy =~ m{\A - }x;
        $final_config{$policy} = $user_config->{$policy};
    }

    return bless \%final_config, $class;
}

#----------------------------------------------------------------------------

sub find_profile {
    my $rc_file = '.perlcriticrc';

    #Check explicit setting
    return $ENV{PERLCRITIC} if exists $ENV{PERLCRITIC};

    #Check current directory
    -f $rc_file && return $rc_file; 

    #Check usual env vars
    for my $var ( qw(HOME USERPROFILE HOMESHARE) ){
	next if ! defined $ENV{$var};
        my $path = File::Spec->catfile( $ENV{$var}, $rc_file );
        return $path if -f $path;
    }

    #No profile found!
    return;
}

sub default_config {

    return qw( BuiltinFunctions::ProhibitStringyEval
	       BuiltinFunctions::RequireBlockGrep
	       BuiltinFunctions::RequireBlockMap
	       BuiltinFunctions::RequireGlobFunction
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
	       Subroutines::ProhibitExplicitReturnUndef
	       Subroutines::ProhibitBuiltinHomonyms
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

This class is used internally by L<Perl::Critic>.  It has a few static
methods that are used for testing, but there aren't any user-servicable
parts here (yet).

=head1 SUBROUTINES

=over 8

=item find_profile( void )

Searches your environment variables and several predetermined
directories for a F<.perlcriticrc> file.  If the file is found, the
full path is returned.  Otherwise, returns undef;

=item default_config( void )

Returns a list of the Policy modules that are automatically loaded by
Perl::Critic.  Usually, all Policy modules that ship with Perl::Critic
are in the default configuration.  The only exceptions are modules
that have external dependencies, like L<Perl::Tidy>.

=back

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
