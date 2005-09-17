package Perl::Critic::Policy::CodeLayout::RequireTidyCode;

use strict;
use warnings;
use Perl::Tidy;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

use vars qw($VERSION);
$VERSION = '0.06';

sub violations {
    my ($self, $doc) = @_;
    my $expl = [33];
    my $desc = q{Code is not tidy};

    my $source  = "$doc";
    my $dest    = $EMPTY;
    my $logfile = $EMPTY;
    my $errfile = $EMPTY;
    my $stderr  = $EMPTY;

    Perl::Tidy::perltidy(source      => \$source, 
			 destination => \$dest,
			 stderr      => \$stderr, 
			 logfile     => \$logfile, 
			 errorfile   => \$errfile);
    
    $desc = q{perltidy had errors} if $stderr;  #There were errors
    return if $source eq $dest;                 #Code is tidy
    return Perl::Critic::Violation->new( $desc, $expl, [0,0] );
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::CodeLayout::RequireTidyCode

=head1 DESCRIPTION

Conway does make specific recommendations for whitespace and
curly-braces in your code, but the most important thing is to adopt a
consistent layout, regardless of the specifics.  And the easiest way
to do that is to use L<Perl::Tidy>.  This policy will complain if
you're code hasn't been run through Perl::Tidy.

=head1 NOTES

Since L<Perl::Tidy> is not widely deployed, this is the only policy in
the L<Perl::Reveiw> distribution that is not enabled by default.  To
enable it, put this line in your F<.perlcriticrc> file:

 [CodeLayout::RequireTidyCode]

=head1 SEE ALSO

L<Perl::Tidy>


=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.
