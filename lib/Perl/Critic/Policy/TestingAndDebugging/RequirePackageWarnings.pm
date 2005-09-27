package Perl::Critic::Policy::TestingAndDebugging::RequirePackageWarnings;

use strict;
use warnings;
use Perl::Critic::Utils;
use List::Util qw(first);
use base 'Perl::Critic::Policy';

our $VERSION = '0.08_02';
$VERSION = eval $VERSION; ## pc:skip

#---------------------------------------------------------------------------

sub violations{
    my ($self, $doc) = @_;
    my $expl = [431];
    my $desc = q{Code before warnings are enabled};

    #Find first statement that isn't 'use', 'require', or 'package'
    my $nodes_ref  = $doc->find('PPI::Statement') || return;
    my $other_stmnt = first {   !$_->isa('PPI::Statement::Package')
			     && !$_->isa('PPI::Statement::Include')} @{$nodes_ref};

    #Find the first 'use warnings' statement
    my $strict_stmnt = first {   $_->isa('PPI::Statement::Include')
			      && $_->type() eq 'use'
			      && $_->pragma() eq 'warnings'} @{$nodes_ref};

    $other_stmnt || return;           #Both of these...
    $strict_stmnt ||= $other_stmnt;   #need to be defined
    my $other_at  =  $other_stmnt->location()->[0];
    my $strict_at = $strict_stmnt->location()->[0];
    
    return $other_at <= $strict_at ?
	Perl::Critic::Violation->new($desc, $expl, $other_stmnt->location()) : ();
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::TestingAndDebugging::RequirePackageWarnings

=head1 DESCRIPTION

Using warnings is probably the single most effective way to improve
the quality of your code.  This policy requires that the C<'use
warnings'> statement must come before any other staments except
C<package>, C<require>, and other C<use> statements.  Thus, all the
code in the entire package will be affected.

=head1 SEE ALSO

L<Perl::Critic::Policy::TestingAndDebugging::RequirePackageStricture>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module
