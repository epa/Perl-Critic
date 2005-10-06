package Perl::Critic::Policy::Modules::ProhibitSpecificModules;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.10';
$VERSION = eval $VERSION;    ## no critic

#----------------------------------------------------------------------------

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;

    #Set config, if defined
    if ( defined $args{modules} ) {
        for my $module ( split m{\s+}, $args{modules} ) {
            $self->{_modules}->{$module} = 1;
        }
    }
    return $self;
}

sub violations {
    my ( $self, $doc ) = @_;
    my $expl      = q{Find an alternative module};
    my $desc      = q{Prohibited module used};
    my $nodes_ref = $doc->find('PPI::Statement::Include') || return;
    my @matches   =
      grep { exists $self->{_modules}->{ $_->module } } @{$nodes_ref};
    return
      map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) }
      @matches;
}

1;

__END__

=pod

=head1 NAME

Perl::Critic::Policy::Modules::ProhibitSpecificModules

=head1 DESCRIPTION

Use this policy if you wish to prohibit the use of certain modules.
These may be modules that you feel are deprecated, buggy, unsupported,
insecure, or just don't like.

=head1 CONSTRUCTOR

This policy accepts an additional key-value pair in the C<new> method.
The key should be 'modules' and the value is a string of
space-delimited fully qualified module names.  These can be configured in the
F<.perlcriticrc> file like this:

 [Modules::ProhibitSpecificModules]
 modules = Getopt::Std  Autoload

By default, there aren't any prohibited modules (although I can think
of a few that should be).

=head1 NOTES

Note that this policy doesn't apply to pragmas.  Future versions may
allow you to specify an alternative for each prohibited module, which
can be suggested by L<Perl::Critic>.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
