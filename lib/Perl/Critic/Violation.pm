package Perl::Critic::Violation;

use strict;
use warnings;
use Pod::Usage;
use Perl::Critic::Utils;
use overload q{""} => 'to_string';

our $VERSION = '0.10';
$VERSION = eval $VERSION;    ## no critic

#----------------------------------------------------------------------------

sub new {

    #Check arguments to help out developers who might
    #be creating new Perl::Critic::Policy modules.

    if ( @_ != 4 ) {
        my $msg = 'Wrong number of arguments to Perl::Critic->new()';
        pod2usage( -input => __FILE__, -message => $msg );
    }

    if ( ref $_[3] ne 'ARRAY' ) {
        my $msg = '3rd argument to Perl::Critic->new() must be ARRAY ref';
        pod2usage( -input => __FILE__, -message => $msg );
    }

    #Create object
    my ( $class, $desc, $expl, $loc ) = @_;
    my $self = bless {}, $class;
    $self->{_desc} = $desc;
    $self->{_expl} = $expl;
    $self->{_loc}  = $loc;
    return $self;
}

sub description { return $_[0]->{_desc} }
sub explanation { return $_[0]->{_expl} }
sub location    { return $_[0]->{_loc} }

sub to_string {

    my $self = shift;

    #Assemble message
    my ( $line, $col ) = @{ $self->location() };
    my $msg = $self->description() . " at line $line, column $col.";

    # Append explanation or page numbers
    my $expl = $self->explanation();
    if ( ref $expl eq 'ARRAY' ) {
        my $page = @{$expl} > 1 ? 'pages ' : 'page ';
        $page .= join $COMMA, @{$expl};
        $expl = "See $page of PBP.";
    }

    return "$msg $expl";
}

1;

__END__

=head1 NAME

Perl::Critic::Violation - Represents policy violations

=head1 SYNOPSIS

  use PPI;
  use Perl::Critic::Violation;

  my $loc  = $node->location();   #$node is a PPI::Node object
  my $desc = 'Offending code';    #Describe the violation
  my $expl = [1,45,67];           #Page numbers from PBB
  my $vio  = Perl::Critic::Violation->new($desc, $expl, $loc);

=head1 DESCRIPTION

Perl::Critic::Violation is the generic represntation of an individual
Policy violation.  Its primary purpose is to provide an abstraction
layer so that clients of L<Perl::Critic> don't have to know anything
about L<PPI>.  The C<violations> method of all L<Perl::Critic::Policy>
subclasses must return a list of these Perl::Critic::Violation
objects.

=head1 CONSTRUCTOR

=over 8

=item new( $description, $explanation, $location )

Retruns a reference to a new C<Perl::Critic::Violation> object. The
arguments are a description of the violation (as string), an
explanation for the policy (as string) or a series of page numbers in
PBB (as an ARRAY ref), and the location of the violation (as an ARRAY
ref).  The C<$location> must have two elements, representing the line
and column number, in that order.

=back

=head1 METHODS

=over 8

=item description ( void )

Returns a brief description of the policy that has been volated as a string.

=item explanation( void )

Returns the explanation for this policy as a string or as reference to
an array of page numbers in PBB.

=item location( void )

Returns a two-element list containing the line and column number where the 
violation occurred.

=item to_string( void )

Returns a pretty string repesentation of this violation.  This is
useful for basic reporting.  See also C<"OVERLOADS">.

=back

=head1 OVERLOADS

Perl::Critic::Violation overloads the "" operator to produce neat
little messages when evaluated in string context.  The format is
something like this:

 Your violation description at line ##, column ##. See page ## of PBB

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
