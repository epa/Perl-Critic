package Perl::Critic;

use strict;
use warnings;
use File::Spec;
use English qw(-no_match_vars);
use Perl::Critic::Config;
use Carp;
use PPI;

our $VERSION = '0.09';
$VERSION = eval $VERSION;    ## no critic

#----------------------------------------------------------------------------
#
sub new {

    my ( $class, %args ) = @_;

    # Default arguments
    my $priority     = defined $args{-priority} ? $args{-priority} : 0;
    my $profile_path = $args{-profile};
    my $force        = $args{-force} || 0;

    # Create object
    my $self = bless {}, $class;
    $self->{_force}    = $force;
    $self->{_policies} = [];

    # Allow all configuration to be skipped. This
    # is useful for testing an isolated policy.
    return $self if defined $profile_path && $profile_path eq 'NONE';

    # Read profile
    my $profile = Perl::Critic::Config->new( -profile => $profile_path );

    # Now load policy w/ its config
    while ( my ( $policy, $config ) = each %{$profile} ) {
        next if !$policy;    #Skip default section
        $config ||= {};      #Protect against undef config
        my $p = delete $config->{priority} || 1;  #Remove 'priority' from config
        next if $priority && ( $p > $priority );  #Skip 'low' priority policies
        $self->add_policy( -policy => $policy, -config => $config );
    }
    return $self;
}

#----------------------------------------------------------------------------
#
sub add_policy {

    my ( $self, %args ) = @_;
    my $module_name = $args{-policy} || return;
    my $config      = $args{-config} || {};

    #Qualify name if full module name not given
    my $namespace = 'Perl::Critic::Policy';
    if ( $module_name !~ m{ \A $namespace }x ) {
        $module_name = $namespace . q{::} . $module_name;
    }

    #Convert module name to file path.  I'm trying to do
    #this in a portable way, but I'm not sure it actually is.
    my $module_file = File::Spec->catfile( split q{::}, $module_name );
    $module_file .= '.pm';

    #Try to load module and instantiate
    eval {
        require $module_file;    ## no critic
        my $policy = $module_name->new( %{$config} );
        push @{ $self->{_policies} }, $policy;
    };

    #Failure to load is not fatal
    if ($EVAL_ERROR) {
        carp "Can't load policy module $module_name: $EVAL_ERROR";
        return;
    }

    return $self;
}

#----------------------------------------------------------------------------
#
sub critique {
    my ( $self, $source_code ) = @_;

    # Parse the code
    my $doc = PPI::Document->new($source_code) || croak q{Cannot parse code};
    $doc->index_locations();

    # Filter exempt code, if desired
    if ( !$self->{_force} ) { _filter_code($doc) }

    # Run engine and return violations (sorted lexically)
    my @violations = map { $_->violations($doc) } @{ $self->{_policies} };
    @violations = sort _by_location @violations;
    return @violations;
}

#----------------------------------------------------------------------------
#
sub policies { @{ $_[0]->{_policies} } }

#============================================================================
#PRIVATE SUBS

sub _filter_code {

    my $doc        = shift;
    my $nodes_ref  = $doc->find('PPI::Token::Comment') || return;
    my $no_critic  = qr{\A \s* \#\# \s* no  \s+ critic}x;
    my $use_critic = qr{\A \s* \#\# \s* use \s+ critic}x;

  PRAGMA:
    for my $pragma ( grep { $_ =~ $no_critic } @{$nodes_ref} ) {

        #Handle single-line usage
        if ( my $sib = $pragma->sprevious_sibling() ) {
            if ( $sib->location->[0] == $pragma->location->[0] ) {
                $sib->statement->delete();
                next PRAGMA;
            }
        }

      SIB:
        while ( my $sib = $pragma->next_sibling() ) {
            my $ended = $sib->isa('PPI::Token::Comment') && $sib =~ $use_critic;
            $sib->delete();    #$sib is undef now.
            last SIB if $ended;
        }
    }
    continue {
        $pragma->delete();
    }
}

#----------------------------------------------------------------------------

sub _by_location {
    return $a->location->[0] <=> $b->location->[0]
      || $a->location->[1] <=> $b->location->[1];
}

1;


## no critic

__END__

=pod

=head1 NAME

Perl::Critic - Critique Perl source for style and standards

=head1 SYNOPSIS

  use Perl::Critic;

  #Create Critic and load Policies from default config file
  $critic = Perl::Critic->new();

  #Create Critic and load only the most important Polices
  $critic = Perl::Critic->new(-priority => 1);

  #Create Critic and load Policies from specific config file
  $critic = Perl::Critic->new(-profile => $file);

  #Create Critic and load Policy by hand
  $critic = Perl::Critic->new(-profile => '');
  $critic->add_policy('MyPolicyModule');

  #Analyze code for policy violations
  @violations = $critic->critique($source_code);

=head1 DESCRIPTION

Perl::Critic is an extensible framework for creating and applying
coding standards to Perl source code.  It is, essentially, an
automated code review.	Perl::Critic is distributed with a number of
L<Perl::Critic::Policy> modules that attempt to enforce the guidelines
in Damian Conway's book B<Perl Best Practices>.  You can choose and
customize those Polices through the Perl::Critic interface.  You can
also create new Policy modules that suit your own tastes.

For a convenient command-line interface to Perl::Critic, see the
documentation for L<perlcritic>.

=head1 CONSTRUCTOR

=over 8

=item new( [ -profile => $FILE, -priority => $N, -force => 1 ] )

Returns a reference to a Perl::Critic object.  All arguments are
optional key-value pairs.

B<-profile> is the path to a configuration file that dictates which
policies should be loaded into the Perl::Critic engine and how to
configure each one. If C<$FILE> is not defined, Perl::Critic attempts
to find a F<.perlcriticrc> configuration file in several different
places.	 If a configuration file can't be found, or if C<$FILE> is an
empty string, then Perl::Critic reverts to its factory setup and all
Policy modules that are distributed with C<Perl::Critic> will be
loaded.	 See L<"CONFIGURATION"> for more information.

B<-priority> is the maximum priority value of Policies that should be
loaded. 1 is the "highest" priority, and all numbers larger than 1
have "lower" priority.	Only Policies that have been configured with a
priority value less than or equal to C<$N> will not be loaded into the
engine.	 For a given C<-profile>, increasing C<$N> will result in more
violations.  The default C<-priority> is 1.  See L<"CONFIGURATION">
for more information.

B<-force> controls whether Perl::Critic observes the magical C<"## no
critic"> pseudo-pragma comments in your code.  If set to a true value,
Perl::Critic will analyze all code.  If set to a false value (which is
the default) Perl::Critic will overlook code that is tagged with these
comments.  See L<"BENDING THE RULES"> for more information.

=back

=head1 METHODS

=over 8

=item add_policy( -policy => $STRING [, -config => \%HASH ] )

Loads a Policy into this Critic engine.  The engine will attmept to
C<require> the module named by $STRING and instantiate it. If the
module fails to load or cannot be instantiated, it will throw a
warning and return a false value.  Otherwise, it returns a reference
to this Critic engine.

B<-policy> is the name of a L<Perl::Critic::Policy> subclass
module.  The C<'Perl::Critic::Policy'> portion of the name can be
omitted for brevity.  This argument is required.

B<-config> is an optional reference to a hash of Policy configuration
parameters. The contents of this hash reference will be passed into to
the constructor of the Policy module.  See the documentation in the
relevant Policy module for a description of the arguments it supports.

=item critique( $source_code )

Runs the C<$source_code> through the Perl::Critic engine using all the
policies that have been loaded into this engine.  If C<$source_code>
is a scalar reference, then it is treated as string of actual Perl
code.  Otherwise, it is treated as a path to a file containing Perl
code.  Returns a list of L<Perl::Critic::Violation> objects for each
violation of the loaded Policies.  The list is sorted in the order
that the Violations appear in the code.  If there are no violations,
returns an empty list.

=item policies( void )

Returns a list containing references to all the Policy objects that
have been loaded into this engine.  Objects will be in the order that
they were loaded.

=back

=head1 CONFIGURATION

The default configuration file is called F<.perlcriticrc>.
Perl::Critic will look for this file in the current directory first,
and then in your home directory.  Alternatively, you can set the
PERLCRITIC environment variable to explicitly point to a different
configuration file in another location.	 If none of these files exist,
and the C<-profile> option is not given to the constructor,
Perl::Critic defaults to its factory setup, which means that all the
policies that are distributed with Perl::Critic will be loaded.

The format of the configuration file is a series of named sections
that contain key-value pairs separated by '='.	Comments should
start with '#' and can be placed on a separate line or after the
name-value pairs if you desire.  The general recipe is a series of
blocks like this:

    [Perl::Critic::Policy::Category::PolicyName]
    priority = 1
    arg1 = value1
    arg2 = value2

C<Perl::Critic::Policy::Category::PolicyName> is the full name of a
module that implements the policy.  The Policy modules distributed
with Perl::Critic have been grouped into categories according to the
table of contents in Damian Conway's book B<Perl Best Practices>. For
brevity, you can ommit the C<'Perl::Critic::Policy'> part of the
module name.  The module must be a subclass of
L<Perl::Critic::Policy>.

C<priority> is the level of importance you wish to assign to this
policy.	 1 is the "highest" priority level, and all numbers greater
than 1 have increasingly "lower" priority.  Only those policies with a
priority less than or equal to the C<-priority> value given to the
Perl::Critic constructor will be loaded.  The priority can be an
arbitrarily large positive integer.  If the priority is not defined,
it defaults to 1.

The remaining key-value pairs are configuration parameters for that
specific Policy and will be passed into the constructor of the
L<Perl::Critic::Policy> subclass.  The constructors for most Policy
modules do not support arguments, and those that do should have
reasonable defaults.  See the documentation on the appropriate Policy
module for more details.

By default, all the policies that are distributed with Perl::Critic
are loaded.  Rather than assign a priority level to a Policy, you can
simply "turn off" a Policy by prepending a '-' to the name of the
module in the config file.  In this manner, the Policy will never be
loaded, regardless of the C<-priority> given to the Perl::Critic
constructor.


A simple configuration might look like this:

    #--------------------------------------------------------------
    # These are really important, so always load them

    [TestingAndDebugging::RequirePackageStricture]
    priority = 1

    [TestingAndDebugging::RequirePackageWarnings]
    priority = 1

    #--------------------------------------------------------------
    # These are less important, so only load when asked

    [Variables::ProhibitPackageVars]
    priority = 2

    [ControlStructures::ProhibitPostfixControls]
    priority = 2

    #--------------------------------------------------------------
    # I do not agree with these, so never load them

    [-NamingConventions::ProhibitMixedCaseVars]
    [-NamingConventions::ProhibitMixedCaseSubs]

=head1 THE POLICIES

The following Policy modules are distributed with Perl::Critic.
The Policy modules have been categorized according to the table of
contents in Damian Conway's book B<Perl Best Practices>.  Since most
coding standards take the form "do this..." or "don't do that...", I
have adopted the convention of naming each module C<RequireSomething>
or C<ProhibitSomething>.  See the documentation of each module for
it's specific details.

=head2 L<Perl::Critic::Policy::BuiltinFunctions::ProhibitStringyEval>

=head2 L<Perl::Critic::Policy::BuiltinFunctions::RequireBlockGrep>

=head2 L<Perl::Critic::Policy::BuiltinFunctions::RequireBlockMap>

=head2 L<Perl::Critic::Policy::BuiltinFunctions::RequireGlobFunction>

=head2 L<Perl::Critic::Policy::CodeLayout::ProhibitHardTabs>

=head2 L<Perl::Critic::Policy::CodeLayout::ProhibitParensWithBuiltins>

=head2 L<Perl::Critic::Policy::CodeLayout::RequireTidyCode>

=head2 L<Perl::Critic::Policy::ControlStructures::ProhibitCascadingIfElse>

=head2 L<Perl::Critic::Policy::ControlStructures::ProhibitCStyleForLoops>

=head2 L<Perl::Critic::Policy::ControlStructures::ProhibitPostfixControls>

=head2 L<Perl::Critic::Policy::ControlStructures::ProhibitUnlessBlocks>

=head2 L<Perl::Critic::Policy::ControlStructures::ProhibitUntilBlocks>

=head2 L<Perl::Critic::Policy::InputOutput::ProhibitBacktickOperators>

=head2 L<Perl::Critic::Policy::Modules::ProhibitMultiplePackages>

=head2 L<Perl::Critic::Policy::Modules::ProhibitRequireStatements>

=head2 L<Perl::Critic::Policy::Modules::ProhibitSpecificModules>

=head2 L<Perl::Critic::Policy::Modules::ProhibitUnpackagedCode>

=head2 L<Perl::Critic::Policy::NamingConventions::ProhibitMixedCaseSubs>

=head2 L<Perl::Critic::Policy::NamingConventions::ProhibitMixedCaseVars>

=head2 L<Perl::Critic::Policy::Subroutines::ProhibitBuiltinHomonyms>

=head2 L<Perl::Critic::Policy::Subroutines::ProhibitExplicitReturnUndef>

=head2 L<Perl::Critic::Policy::Subroutines::ProhibitSubroutinePrototypes>

=head2 L<Perl::Critic::Policy::TestingAndDebugging::RequirePackageStricture>

=head2 L<Perl::Critic::Policy::TestingAndDebugging::RequirePackageWarnings>

=head2 L<Perl::Critic::Policy::ValuesAndExpressions::ProhibitConstantPragma>

=head2 L<Perl::Critic::Policy::ValuesAndExpressions::ProhibitEmptyQuotes>

=head2 L<Perl::Critic::Policy::ValuesAndExpressions::ProhibitInterpolationOfLiterals>

=head2 L<Perl::Critic::Policy::ValuesAndExpressions::ProhibitLeadingZeros>

=head2 L<Perl::Critic::Policy::ValuesAndExpressions::ProhibitNoisyQuotes>

=head2 L<Perl::Critic::Policy::ValuesAndExpressions::RequireInterpolationOfMetachars>

=head2 L<Perl::Critic::Policy::ValuesAndExpressions::RequireNumberSeparators>

=head2 L<Perl::Critic::Policy::ValuesAndExpressions::RequireQuotedHeredocTerminator>

=head2 L<Perl::Critic::Policy::ValuesAndExpressions::RequireUpperCaseHeredocTerminator>

=head2 L<Perl::Critic::Policy::Variables::ProhibitLocalVars>

=head2 L<Perl::Critic::Policy::Variables::ProhibitPackageVars>

=head2 L<Perl::Critic::Policy::Variables::ProhibitPunctuationVars>

=head1 BENDING THE RULES

B<NOTE:> This feature changed in version 0.09 and is not backward
compatible with earlier versions.

Perl::Critic takes a hard-line approach to your code: either you
comply or you don't.  In the real world, it is not always practical
(or even possible) to fully comply with coding standards.  In such
cases, it is wise to show that you are knowlingly violating the
standards and that you have a Damn Good Reason (DGR) for doing so.

To help with those situations, you can direct Perl::Critic to ignore
certain lines or blocks of code by using pseudo-pragmas:

    require 'LegacyLibaray1.pl';  ## no critic
    require 'LegacyLibrary2.pl';  ## no critic

    for my $element (@list) {

        ## no critic

        $foo = "";               #Violates 'ProhibitEmptyQuotes'
        $barf = bar() if $foo;   #Violates 'ProhibitPostfixControls'
        #Some more evil code...

        ## use critic

        #Some good code...
        do_something($_);
    }

The C<## no critic> comments direct Perl::Critic to overlook the
remaining lines of code within the block, or until a C<## use critic>
comment is found.  If the C<## no critic> comment is found on the same
line as a code statement, then only that line of code is overlooked.
To force perlcritic to ignore the C<## no critic> comments, use the
C<-force> option at the command line.

Use this feature wisely.  C<## no critic> should be used in the smallest
possible scope, or only on individual lines of code. If Perl::Critic
complains about your code, try and find a compliant solution before
resorting to this feature.

=head1 EXTENDING THE CRITIC

The modular design of Perl::Critic is intended to facilitate the
addition of new Policies.  To create a new Policy, make a subclass of
L<Perl::Critic::Policy> and override the C<violations()> method.  Your
module should go somewhere in the Perl::Critic::Policy namespace.  To
use the new Policy, just add it to your F<.perlcriticrc> file.  You'll
need to have some understanding of L<PPI>, but most Policy modules are
pretty straightforward and only require about 20 lines of code.

If you develop any new Policy modules, feel free to send them to
<thaljef@cpan.org> and I'll be happy to put them into the Perl::Critic
distribution.

 =head1 BUGS

Scrutinizing Perl code is hard for humans, let alone machines.  If you
find any bugs, particularly false-positives or false-negatives from a
Perl::Critic::Policy, please submit them to 
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Perl-Critic>.  Thanks.

=head1 CREDITS

Adam Kennedy - For creating L<PPI>, the heart and soul of Perl::Critic.

Damian Conway - For writing B<Perl Best Practices>

Giuseppe Maxia - For all the great ideas and enhancements.

Sharon, my wife - For putting up with my all-night code sessions

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
