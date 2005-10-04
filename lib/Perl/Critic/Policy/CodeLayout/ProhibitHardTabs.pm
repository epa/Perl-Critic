package Perl::Critic::Policy::CodeLayout::ProhibitHardTabs;

use strict;
use warnings;
use Perl::Critic::Utils;
use Perl::Critic::Violation;
use base 'Perl::Critic::Policy';

our $VERSION = '0.09';
$VERSION = eval $VERSION;    ## no critic

#----------------------------------------------------------------------------

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;

    #Set config, if defined
    $self->{_allow_leading_tabs} = defined $args{allow_leading_tabs} ? 
                                           $args{allow_leading_tabs} : 0;

    return $self;
}
    
sub violations {
    my ( $self, $doc ) = @_;
    my $expl      = [20];
    my $desc      = q{Hard tabs used};
    my $nodes_ref = $doc->find( \&_is_tab ) || return;

    #Permit leading tabs, if asked
    if( $self->{_allow_leading_tabs} ) {
        @{$nodes_ref} = grep {$_->location->[1] != 1} @{$nodes_ref};
    }

    return map { Perl::Critic::Violation->new( $desc, $expl, $_->location() ) }
        @{$nodes_ref};
}

sub _is_tab {
    my ( $doc, $elem ) = @_;
    return $elem->isa('PPI::Token') && $elem =~ m{\t};
}

1;

__END__

=head1 NAME

Perl::Critic::Policy::CodeLayout::ProhibitHardTabs

=head1 DESCRIPTION

Putting hard tabs in your source code (or POD) is one of the worst
things you can do to your co-workers and colleagues.  Because various
applications and devices represent tabs differnently, they can cause
you code to look vastly different to other people.  Any decent editor
can be configured to expand tabs into spaces.  L<Perl::Tidy> also does
this for you.

Some folks feel that hard tabs are ok, if and only if they are in the
leading position.  To permit leading tabs, add this to your
F<.perlcriticrc> file:

  [CodeLayout::ProhibitHardTabs]
  allow_leading_tabs = 1

This Policy also covers tabs in quotes and HEREDOCS.  If you need to
put a tab there, use the C<"\t"> escape character instead.  Beware
that Perl::Critic reports the location of the string that contains the
tab, not the actual location of the tab, so you may need to do some
hunting.  I'll try and fix this in the future.

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut
