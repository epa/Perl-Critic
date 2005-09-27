package Perl::Critic::Policy::ControlStructures::ProhibitPostfixControls;

use strict;
use warnings;
use Carp;
use List::MoreUtils qw(any);
use Perl::Critic::Violation;
use Perl::Critic::Utils;
use base 'Perl::Critic::Policy';

our $VERSION = '0.08_02';
$VERSION = eval $VERSION; ## pc:skip

#----------------------------------------------------------------------------

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    if( $args{allow} ){
	#Allowed controls can be in space-delimited string
	$self->{_allow} = [split m{\s+}, delete $args{allow}];
    }
    else {
	#Deafult to allow nothing
	$self->{_allow} = [];
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

    #Define controls and their page numbers in PBB
    my %pages_of = (if     => [93,94],  for    => [96],
		    while  => [96],     unless => [96,97],
		    until  => [96,97]);

    my @matches = ();

  CONTROL:
    for my $control ( keys %pages_of ){
	next CONTROL if any {$control eq $_} @{$self->{_allow}};
	my $nodes_ref = find_keywords( $doc, $control ) || next CONTROL;

      NODE:
	for my $node ( @{$nodes_ref} ) {

	    # Skip regular Compound variety (these are good)
	    my $stmnt = $node->statement();
	    next NODE if $stmnt->isa('PPI::Statement::Compound');

	    # Control 'if' is allowed when is part of a Break
	    next NODE if   $control eq 'if' 
			&& $node->statement->isa('PPI::Statement::Break');
		
	    # If we get here, it must be postfix.
	    my $desc = qq{Postfix control '$control' used};
	    my $expl = $pages_of{$control};
	    push @matches, Perl::Critic::Violation->new( $desc, $expl, $node->location() );
	}
    }
    return @matches;
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::ControlStructures::ProhibitPostfixControls

=head1 DESCRIPTION

Conway discourages using postfix control structures (C<if>, C<for>,
C<unless>, C<until>, C<while>).  The C<unless> and C<until> controls
are particularly evil becuase the lead to double-negatives that are
hard to comprehend.  The only tolerable usage of a postfix C<if> is
when it follows a loop break such as C<last>, C<next>, C<redo>, or
C<continue>.

  do_something() if $condition;         #not ok
  if($condition){ do_something() }      #ok

  do_something() while $condition;      #not ok
  while($condition){ do_something() }   #ok

  do_something() unless $condition;     #not ok
  do_something() unless ! $condition;   #really bad
  if(! $condition){ do_something() }    #ok

  do_something() until $condition;      #not ok
  do_something() until ! $condition;    #really bad
  while(! $condition){ do_something() } #ok 

  do_something($_) for @list;           #not ok

 LOOP:
  for my $n (0..100){
      next if $condition;               #ok
      last LOOP if $other_condition;    #also ok
  }

=head1 CONSTRUCTOR

This policy accepts an additional key-value pair in the C<new> method.
The key should be 'allow' and the value is a string of space-delimited
keywords.  Choose from C<if>, C<for>, C<unless>, C<until>,and
C<while>.  When using the L<Perl::Critic> engine, these can be
configured in the F<.perlcriticrc> file like this:

 [ControlStructures::ProhibitPostfixControls]
 allow = for if until

By default, all postfix control keywords are prohibited.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
