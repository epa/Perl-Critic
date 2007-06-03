##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/tags/Perl-Critic-1.053/lib/Perl/Critic/Config.pm $
#     $Date: 2007-06-03 13:16:10 -0700 (Sun, 03 Jun 2007) $
#   $Author: thaljef $
# $Revision: 1578 $
##############################################################################

package Perl::Critic::Config;

use strict;
use warnings;
use Carp qw(confess);
use English qw(-no_match_vars);
use List::MoreUtils qw(any none apply);
use Scalar::Util qw(blessed);
use Perl::Critic::PolicyFactory;
use Perl::Critic::Theme qw();
use Perl::Critic::UserProfile qw();
use Perl::Critic::Utils qw{
    :booleans :characters :severities :internal_lookup
};

#-----------------------------------------------------------------------------

our $VERSION = 1.053;

#-----------------------------------------------------------------------------
# Constructor

sub new {

    my ( $class, %args ) = @_;
    my $self = bless {}, $class;
    $self->_init( %args );
    return $self;
}

#-----------------------------------------------------------------------------

sub _init {

    my ( $self, %args ) = @_;

    # -top or -theme imply that -severity is 1, unless it is already defined
    if ( defined $args{-top} || defined $args{-theme} ) {
        $args{-severity} ||= $SEVERITY_LOWEST;
    }

    # Construct the UserProfile to get default options.
    my $p        = $args{-profile}; #Can be file path or data struct
    my $profile  = Perl::Critic::UserProfile->new( -profile => $p );
    my $defaults = $profile->defaults();
    $self->{_profile} = $profile;

    # If given, these options should always have a true value.
    $self->{_include}      = $args{-include}      || $defaults->include();
    $self->{_exclude}      = $args{-exclude}      || $defaults->exclude();
    $self->{_singlepolicy} = $args{-singlepolicy} || $defaults->singlepolicy();
    $self->{_verbose}      = $args{-verbose}      || $defaults->verbose();

    # Severity levels can be expressed as names or numbers
    my $severity        = $args{-severity} || $defaults->severity();
    $self->{_severity}  = severity_to_number( $severity );

    # If given, these options can be true or false (but defined)
    # We normalize these to numeric values by multiplying them by 1;
    no warnings 'numeric'; ## no critic (ProhibitNoWarnings)
    $self->{_top}   = 1 * _dor( $args{-top},   $defaults->top()   );
    $self->{_force} = 1 * _dor( $args{-force}, $defaults->force() );
    $self->{_only}  = 1 * _dor( $args{-only},  $defaults->only()  );

    # Construct a Theme object from rule
    my $theme_rule = $args{-theme} || $defaults->theme();
    my $theme = Perl::Critic::Theme->new( -rule => $theme_rule );
    $self->{_theme} = $theme;

    # Construct a Factory with the Profile
    my $factory = Perl::Critic::PolicyFactory->new( -profile => $profile );
    $self->{_factory} = $factory;

    # Initialize internal storage for Policies
    $self->{_policies} = [];

    # "NONE" means don't load any policies
    return $self if defined $p and $p eq 'NONE';

    # Heavy lifting here...
    $self->_load_policies();

    return $self;
}

#-----------------------------------------------------------------------------

sub add_policy {

    my ( $self, %args ) = @_;

    my $policy  = $args{-policy}
        or confess q{The -policy argument is required};

    # If the -policy is already a blessed object, then just add it directly.
    if ( blessed $policy ) {
        push @{ $self->{_policies} }, $policy;
        return $self;
    }

    # NOTE: The "-config" option is supported for backward compatibility.
    my $params = $args{-params} || $args{-config};

    my $factory    = $self->{_factory};
    my $policy_obj = $factory->create_policy(-name=>$policy, -params=>$params);
    push @{ $self->{_policies} }, $policy_obj;


    return $self;
}

#-----------------------------------------------------------------------------

sub _load_policies {

    my ( $self ) = @_;
    my $factory  = $self->{_factory};
    my @policies = $factory->create_all_policies();

    for my $policy ( @policies ) {

        # If -singlepolicy is true, only load policies that match it
        if ( $self->singlepolicy() ) {
            if ( $self->_policy_is_single_policy( $policy ) ) {
                $self->add_policy( -policy => $policy );
            }
            next;
        }

        # To load, or not to load -- that is the question.
        my $load_me = $self->only() ? $FALSE : $TRUE;

        ## no critic (ProhibitPostfixControls)
        $load_me = $FALSE if     $self->_policy_is_disabled( $policy );
        $load_me = $TRUE  if     $self->_policy_is_enabled( $policy );
        $load_me = $FALSE if     $self->_policy_is_unimportant( $policy );
        $load_me = $FALSE if not $self->_policy_is_thematic( $policy );
        $load_me = $TRUE  if     $self->_policy_is_included( $policy );
        $load_me = $FALSE if     $self->_policy_is_excluded( $policy );


        next if not $load_me;
        $self->add_policy( -policy => $policy );
    }

    # When using -singlepolicy, only one policy should ever be loaded.
    if ($self->singlepolicy() && scalar $self->policies() != 1) {
        $self->_throw_single_policy_exception();
    }

    return $self;
}

#-----------------------------------------------------------------------------

sub _policy_is_disabled {
    my ($self, $policy) = @_;
    my $profile = $self->{_profile};
    return $profile->policy_is_disabled( $policy );
}

#-----------------------------------------------------------------------------

sub _policy_is_enabled {
    my ($self, $policy) = @_;
    my $profile = $self->{_profile};
    return $profile->policy_is_enabled( $policy );
}

#-----------------------------------------------------------------------------

sub _policy_is_thematic {
    my ($self, $policy) = @_;
    my $theme = $self->theme();
    return $theme->policy_is_thematic( -policy => $policy );
}

#-----------------------------------------------------------------------------

sub _policy_is_unimportant {
    my ($self, $policy) = @_;
    my $policy_severity = $policy->get_severity();
    my $min_severity    = $self->{_severity};
    return $policy_severity < $min_severity;
}

#-----------------------------------------------------------------------------

sub _policy_is_included {
    my ($self, $policy) = @_;
    my $policy_long_name = ref $policy;
    my @inclusions  = $self->include();
    return any { $policy_long_name =~ m/$_/imx } @inclusions;
}

#-----------------------------------------------------------------------------

sub _policy_is_excluded {
    my ($self, $policy) = @_;
    my $policy_long_name = ref $policy;
    my @exclusions  = $self->exclude();
    return any { $policy_long_name =~ m/$_/imx } @exclusions;
}

#-----------------------------------------------------------------------------

sub _policy_is_single_policy {
    my ($self, $policy) = @_;
    my $policy_long_name = ref $policy;
    my $singlepolicy = $self->singlepolicy() || return;
    return $policy_long_name =~ m/$singlepolicy/imx;
}

#-----------------------------------------------------------------------------

sub _throw_single_policy_exception {

    my $self = shift;

    my $error_msg = $EMPTY;
    my $sp_option = $self->singlepolicy();

    if (scalar $self->policies() == 0) {
        $error_msg = qq{No policies matched "$sp_option".};
    }
    else {
        $error_msg  = qq{Multiple policies matched "$sp_option":\n\t};
        $error_msg .= join qq{,\n\t}, apply { chomp } sort $self->policies();
    }

    die "$error_msg\n";
}

#-----------------------------------------------------------------------------

sub _dor {
    #The defined-or //
    my ($this, $that) = @_;
    return defined $this ? $this : $that;
}

#-----------------------------------------------------------------------------
# Begin ACCESSSOR methods

sub policies {
    my $self = shift;
    return @{ $self->{_policies} };
}

#-----------------------------------------------------------------------------

sub exclude {
    my $self = shift;
    return @{ $self->{_exclude} };
}

#-----------------------------------------------------------------------------

sub force {
    my $self = shift;
    return $self->{_force};
}

#-----------------------------------------------------------------------------

sub include {
    my $self = shift;
    return @{ $self->{_include} };
}

#-----------------------------------------------------------------------------

sub only {
    my $self = shift;
    return $self->{_only};
}

#-----------------------------------------------------------------------------

sub severity {
    my $self = shift;
    return $self->{_severity};
}

#-----------------------------------------------------------------------------

sub singlepolicy {
    my $self = shift;
    return $self->{_singlepolicy};
}

#-----------------------------------------------------------------------------

sub theme {
    my $self = shift;
    return $self->{_theme};
}

#-----------------------------------------------------------------------------

sub top {
    my $self = shift;
    return $self->{_top};
}

#-----------------------------------------------------------------------------

sub verbose {
    my $self = shift;
    return $self->{_verbose};
}

#-----------------------------------------------------------------------------

sub site_policy_names {
    return Perl::Critic::PolicyFactory::site_policy_names();
}

1;

#-----------------------------------------------------------------------------

__END__

=pod

=for stopwords -params INI-style -singlepolicy

=head1 NAME

Perl::Critic::Config - Find and load Perl::Critic user-preferences

=head1 DESCRIPTION

Perl::Critic::Config takes care of finding and processing
user-preferences for L<Perl::Critic>.  The Config object defines which
Policy modules will be loaded into the Perl::Critic engine and how
they should be configured.  You should never really need to
instantiate Perl::Critic::Config directly because the Perl::Critic
constructor will do it for you.

=head1 CONSTRUCTOR

=over 8

=item C<< new( [ -profile => $FILE, -severity => $N, -theme => $string, -include => \@PATTERNS, -exclude => \@PATTERNS, -singlepolicy => $PATTERN, -top => $N, -only => $B, -force => $B, -verbose => $N ] ) >>

=item C<< new() >>

Returns a reference to a new Perl::Critic::Config object.  The default
value for all arguments can be defined in your F<.perlcriticrc> file.
See the L<"CONFIGURATION"> section for more information about that.
All arguments are optional key-value pairs as follows:

B<-profile> is a path to a configuration file. If C<$FILE> is not
defined, Perl::Critic::Config attempts to find a F<.perlcriticrc>
configuration file in the current directory, and then in your home
directory.  Alternatively, you can set the C<PERLCRITIC> environment
variable to point to a file in another location.  If a configuration
file can't be found, or if C<$FILE> is an empty string, then all
Policies will be loaded with their default configuration.  See
L<"CONFIGURATION"> for more information.

B<-severity> is the minimum severity level.  Only Policy modules that
have a severity greater than C<$N> will be loaded into this Config.
Severity values are integers ranging from 1 (least severe) to 5 (most
severe).  The default is 5.  For a given C<-profile>, decreasing the
C<-severity> will usually result in more Policy violations.  Users can
redefine the severity level for any Policy in their F<.perlcriticrc>
file.  See L<"CONFIGURATION"> for more information.

B<-theme> is special string that defines a set of Policies based on
their respective themes.  If C<-theme> is given, only policies that
are members of that set will be loaded.  See the L<"POLICY THEMES">
section for more information about themes.  Unless the C<-severity>
option is explicitly given, setting C<-theme> causes the C<-severity>
to be set to 1.

B<-include> is a reference to a list of string C<@PATTERNS>.  Policies
that match at least one C<m/$PATTERN/imx> will be loaded into this
Config, irrespective of the severity settings.  You can use it in
conjunction with the C<-exclude> option.  Note that C<-exclude> takes
precedence over C<-include> when a Policy matches both patterns.

B<-exclude> is a reference to a list of string C<@PATTERNS>.  Polices
that match at least one C<m/$PATTERN/imx> will not be loaded into this
Config, irrespective of the severity settings.  You can use it in
conjunction with the C<-include> option.  Note that C<-exclude> takes
precedence over C<-include> when a Policy matches both patterns.

B<-singlepolicy> is a string C<PATTERN>.  Only the policy that matches
C<m/$PATTERN/imx> will be used.  This value overrides the
C<-severity>, C<-theme>, C<-include>, C<-exclude>, and C<-only>
options.

B<-top> is the maximum number of Violations to return when ranked by
their severity levels.  This must be a positive integer.  Violations
are still returned in the order that they occur within the file.
Unless the C<-severity> option is explicitly given, setting C<-top>
silently causes the C<-severity> to be set to 1.

B<-only> is a boolean value.  If set to a true value, Perl::Critic
will only choose from Policies that are mentioned in the user's
profile.  If set to a false value (which is the default), then
Perl::Critic chooses from all the Policies that it finds at your site.

B<-force> controls whether Perl::Critic observes the magical C<"## no
critic"> pseudo-pragmas in your code.  If set to a true value,
Perl::Critic will analyze all code.  If set to a false value (which is
the default) Perl::Critic will ignore code that is tagged with these
comments.  See L<"BENDING THE RULES"> for more information.

B<-verbose> can be a positive integer (from 1 to 10), or a literal
format specification.  See L<Perl::Critic::Violations> for an
explanation of format specifications.

=back

=head1 METHODS

=over 8

=item C<< add_policy( -policy => $policy_name, -params => \%param_hash ) >>

Creates a Policy object and loads it into this Config.  If the object
cannot be instantiated, it will throw a fatal exception.  Otherwise,
it returns a reference to this Critic.

B<-policy> is the name of a L<Perl::Critic::Policy> subclass
module.  The C<'Perl::Critic::Policy'> portion of the name can be
omitted for brevity.  This argument is required.

B<-params> is an optional reference to a hash of Policy parameters.
The contents of this hash reference will be passed into to the
constructor of the Policy module.  See the documentation in the
relevant Policy module for a description of the arguments it supports.

=item C< policies() >

Returns a list containing references to all the Policy objects that
have been loaded into this Config.  Objects will be in the order that
they were loaded.

=item C< exclude() >

Returns the value of the C<-exclude> attribute for this Config.

=item C< include() >

Returns the value of the C<-include> attribute for this Config.

=item C< force() >

Returns the value of the C<-force> attribute for this Config.

=item C< only() >

Returns the value of the C<-only> attribute for this Config.

=item C< severity() >

Returns the value of the C<-severity> attribute for this Config.

=item C< singlepolicy() >

Returns the value of the C<-singlepolicy> attribute for this Config.

=item C< theme() >

Returns the L<Perl::Critic::Theme> object that was created for
this Config.

=item C< top() >

Returns the value of the C<-top> attribute for this Config.

=item C< verbose() >

Returns the value of the C<-verbose> attribute for this Config.

=back

=head1 SUBROUTINES

Perl::Critic::Config has a few static subroutines that are used
internally, but may be useful to you in some way.

=over 8

=item C<site_policy_names()>

Returns a list of all the Policy modules that are currently installed
in the Perl::Critic:Policy namespace.  These will include modules that
are distributed with Perl::Critic plus any third-party modules that
have been installed.

=back

=head1 CONFIGURATION

Most of the settings for Perl::Critic and each of the Policy modules
can be controlled by a configuration file.  The default configuration
file is called F<.perlcriticrc>.  L<Perl::Critic::Config> will look
for this file in the current directory first, and then in your home
directory.  Alternatively, you can set the C<PERLCRITIC> environment
variable to explicitly point to a different file in another location.
If none of these files exist, and the C<-profile> option is not given
to the constructor, then all Policies will be loaded with their
default configuration.

The format of the configuration file is a series of INI-style
blocks that contain key-value pairs separated by '='. Comments
should start with '#' and can be placed on a separate line or after
the name-value pairs if you desire.

Default settings for Perl::Critic itself can be set B<before the first
named block.>  For example, putting any or all of these at the top of
your configuration file will set the default value for the
corresponding Perl::Critic constructor argument.

    severity  = 3                                     #Integer from 1 to 5
    only      = 1                                     #Zero or One
    force     = 0                                     #Zero or One
    verbose   = 4                                     #Integer or format spec
    top       = 50                                    #A positive integer
    theme     = risky + (pbp * security) - cosmetic   #A theme expression
    include   = NamingConventions ClassHierarchies    #Space-delimited list
    exclude   = Variables  Modules::RequirePackage    #Space-delimited list

The remainder of the configuration file is a series of blocks like
this:

    [Perl::Critic::Policy::Category::PolicyName]
    severity = 1
    set_themes = foo bar
    add_themes = baz
    arg1 = value1
    arg2 = value2

C<Perl::Critic::Policy::Category::PolicyName> is the full name of a
module that implements the policy.  The Policy modules distributed
with Perl::Critic have been grouped into categories according to the
table of contents in Damian Conway's book B<Perl Best Practices>. For
brevity, you can omit the C<'Perl::Critic::Policy'> part of the
module name.

C<severity> is the level of importance you wish to assign to the
Policy.  All Policy modules are defined with a default severity value
ranging from 1 (least severe) to 5 (most severe).  However, you may
disagree with the default severity and choose to give it a higher or
lower severity, based on your own coding philosophy.

The remaining key-value pairs are configuration parameters that will
be passed into the constructor of that Policy.  The constructors for
most Policy modules do not support arguments, and those that do should
have reasonable defaults.  See the documentation on the appropriate
Policy module for more details.

Instead of redefining the severity for a given Policy, you can
completely disable a Policy by prepending a '-' to the name of the
module in your configuration file.  In this manner, the Policy will
never be loaded, regardless of the C<-severity> given to the
Perl::Critic::Config constructor.

A simple configuration might look like this:

    #--------------------------------------------------------------
    # I think these are really important, so always load them

    [TestingAndDebugging::RequireUseStrict]
    severity = 5

    [TestingAndDebugging::RequireUseWarnings]
    severity = 5

    #--------------------------------------------------------------
    # I think these are less important, so only load when asked

    [Variables::ProhibitPackageVars]
    severity = 2

    [ControlStructures::ProhibitPostfixControls]
    allow = if unless  #My custom configuration
    severity = 2

    #--------------------------------------------------------------
    # Give these policies a custom theme.  I can activate just
    # these policies by saying (-theme => 'larry + curly')

    [Modules::RequireFilenameMatchesPackage]
    add_themes = larry

    [TestingAndDebugging::RequireTestLables]
    add_themes = curly moe

    #--------------------------------------------------------------
    # I do not agree with these at all, so never load them

    [-NamingConventions::ProhibitMixedCaseVars]
    [-NamingConventions::ProhibitMixedCaseSubs]

    #--------------------------------------------------------------
    # For all other Policies, I accept the default severity, theme
    # and other parameters, so no additional configuration is
    # required for them.

For additional configuration examples, see the F<perlcriticrc> file
that is included in this F<t/examples> directory of this distribution.

=head1 THE POLICIES

A large number of Policy modules are distributed with Perl::Critic.
They are described briefly in the companion document
L<Perl::Critic::PolicySummary> and in more detail in the individual
modules themselves.

=head1 POLICY THEMES

Each Policy is defined with one or more "themes".  Themes can be used to
create arbitrary groups of Policies.  They are intended to provide an
alternative mechanism for selecting your preferred set of Policies.  For
example, you may wish disable a certain subset of Policies when analyzing test
scripts.  Conversely, you may wish to enable only a specific subset of
Policies when analyzing modules.

The Policies that ship with Perl::Critic are have been broken into the
following themes.  This is just our attempt to provide some basic logical
groupings.  You are free to invent new themes that suit your needs.

    THEME             DESCRIPTION
    --------------------------------------------------------------------------
    core              All policies that ship with Perl::Critic
    pbp               Policies that come directly from "Perl Best Practices"
    bugs              Policies that that prevent or reveal bugs
    maintenance       Policies that affect the long-term health of the code
    cosmetic          Policies that only have a superficial effect
    complexity        Policies that specificaly relate to code complexity
    security          Policies that relate to security issues
    tests             Policies that are specific to test scripts


Say C<`perlcritic -list`> to get a listing of all available policies
and the themes that are associated with each one.  You can also change
the theme for any Policy in your F<.perlcriticrc> file.  See the
L<"CONFIGURATION"> section for more information about that.

Using the C<-theme> option, you can combine theme names with mathematical and
boolean operators to create an arbitrarily complex expression that represents
a custom "set" of Policies.  The following operators are supported

   Operator       Alternative         Meaning
   ----------------------------------------------------------------------------
   *              and                 Intersection
   -              not                 Difference
   +              or                  Union

Operator precedence is the same as that of normal mathematics.  You
can also use parenthesis to enforce precedence.  Here are some examples:

   Expression                  Meaning
   ----------------------------------------------------------------------------
   pbp * bugs                  All policies that are "pbp" AND "bugs"
   pbp and bugs                Ditto

   bugs + cosmetic             All policies that are "bugs" OR "cosmetic"
   bugs or cosmetic            Ditto

   pbp - cosmetic              All policies that are "pbp" BUT NOT "cosmetic"
   pbp not cosmetic            Ditto

   -maintenance                All policies that are NOT "maintenance"
   not maintenance             Ditto

   (pbp - bugs) * complexity     All policies that are "pbp" BUT NOT "bugs",
                                    AND "complexity"
   (pbp not bugs) and complexity  Ditto

Theme names are case-insensitive.  If C<-theme> is set to an empty string,
then it is equivalent to the set of all Policies.  A theme name that doesn't
exist is equivalent to an empty set.  Please See
L<http://en.wikipedia.org/wiki/Set> for a discussion on set theory.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2007 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut

##############################################################################
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
