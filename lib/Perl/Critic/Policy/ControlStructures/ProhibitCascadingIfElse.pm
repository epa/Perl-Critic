package Perl::Critic::Policy::ControlStructures::ProhibitCascadingIfElse;

use strict;
use warnings;
use Pod::Usage;
use List::MoreUtils qw(any);
use Perl::Critic::Violation;
use Perl::Critic::Utils;
use base 'Perl::Critic::Policy';

use vars qw($VERSION);
$VERSION = '0.06';

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    #Set configuration
    $self->{_max} = delete $args{max} || 2;

    #Sanity check for bad configuration.  We deleted all the args
    #that we know about, so there shouldn't be anything left.
    if(%args) {
	my $msg = "Unsupported arguments to __PACKAGE__->new(): ";
	$msg .= join $COMMA, keys %args;
	pod2usage(-message => $msg, -input => __FILE__ , -verbose => 2);
    }

    return $self;
}


sub violations {
    my ($self, $doc) = @_;

    my $n = $self->{_max};
    my $desc = q{Cascading if-else chain};
    my $expl = [117, 118];
    my $nodes_ref = $doc->find('PPI::Statement::Compound');
    my @matches = grep {$_->type eq 'if' && else_count($_) > $n} @{$nodes_ref};
    return map { Perl::Critic::Violation->new($desc, $expl, $_->location() ) }
      @matches;
}

sub else_count {
    my $elem = shift;
    return grep {    $_->isa('PPI::Token::Word') 
		  && $_ =~ m{\A (?:elsif | else ) \z}x } $elem->schildren();
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::ControlStructures::ProhibitCascadingIfElse

=head1 DESCRIPTION

Long C<if-elsif> chains are hard to digest, especially if they are
longer than a single page or screen.  If testing for equality, use a
hash-lookup instead.  See L<Switch> for another approach.

  if ($condition1) {         #ok
      $foo = 1;
  }
  elseif ($condition2) {     #ok
      $foo = 2;
  }
  elsif ($condition3) {      #too many!
      $foo = 3;
  }
  else{                      #ok
      $foo = $default;
  }

=head1 CONSTRUCTOR

This policy accepts an additional key-value pair in the C<new> method.
The key should be 'max' and the value should be an integer indicating
the maximum number of C<elsif> alternatives to allow.  The default is
1.  When using the L<Perl::Critic> engine, these can be configured in
the F<.perlcriticrc> file like this:

 [ControlStructures::ProhibitCascadingIfElse]
 max = 3

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.


