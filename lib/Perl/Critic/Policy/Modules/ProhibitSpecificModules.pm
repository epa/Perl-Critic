package Perl::Critic::Policy::Modules::ProhibitSpecificModules;

use strict;
use warnings;
use Carp;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use List::MoreUtils qw(any);
use base 'Perl::Critic::Policy';

our $VERSION = '0.07';

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    #Be flexible with configuration
    if (ref $args{modules} eq 'ARRAY'){
	#Modules can be in array ref
	$self->{_modules} = delete $args{modules};
    }
    elsif ($args{modules}) {
	#Modules can be in space-delimited string
	$self->{_modules} = [split m{\s+}, delete $args{modules}];
    }
    else {
	#Deafult to no modules at all
	$self->{_modules} = [];
    }

    #Sanity check for bad configuration.  We deleted all the args
    #that we know about, so there shouldn't be anything left.
    if(%args) {
	my $msg = 'Unsupported arguments to ' . __PACKAGE__ . '->new(): ';
	$msg .= join $COMMA, keys %args;
	croak $msg;
    }

    return $self;
}

sub violations {
    my ($self, $doc) = @_;
    my $expl = q{Find an alternative module};
    my $desc = q{Prohibited module used};
    my $nodes_ref = $doc->find('PPI::Statement::Include') || return;
    my @matches = grep { _is_prohibited($_->module, $self->{_modules}) } @{$nodes_ref};
    return map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) } 
      @matches;
}

sub _is_prohibited {
    my ($module, $prohibited_ref) = @_;
    return any { $_ eq $module } @{$prohibited_ref};
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::Modules::ProhibitSpecificModules

=head1 DESCRIPTION

Use this policy if you wish to prohibit the use of certain modules.
These may be modules that you feel are deprecated, buggy, unsupported,
insecure, or just don't like.

=head1 CONSTRUCTOR

This policy accepts an additional key-value pair in the C<new> method.  The
key should be 'modules' and the value should be a reference to an array
of module names that you want to prohibit.  Alternatively, the value
can be a string of space-delimited module names.  These can be configured
in the F<.perlcriticrc> file like this:

 [Modules::ProhibitSpecificModules]
 modules = Getopt::Std  Autoload

 #or 

 [Modules::ProhibitSpecificModules]
 modules = Getopt::Std
 modules = Autoload

By default, there aren't any prohibited modules (although I can think
of a few that should be).

=head1 NOTES

Note that this policy doesn't apply to pragmas.  Future versions may
allow you to specify an alternative for each prohibited module, which
can be suggested by L<Perl::Critic>.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
