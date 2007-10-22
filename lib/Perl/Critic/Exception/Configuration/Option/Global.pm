##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Perl-Critic/lib/Perl/Critic/Exception/Configuration/Option/Global.pm $
#     $Date: 2007-10-22 04:00:50 -0500 (Mon, 22 Oct 2007) $
#   $Author: clonezone $
# $Revision: 2000 $
##############################################################################

package Perl::Critic::Exception::Configuration::Option::Global;

use strict;
use warnings;

our $VERSION = '1.079_003';

#-----------------------------------------------------------------------------

use Exception::Class (
    'Perl::Critic::Exception::Configuration::Option::Global' => {
        isa         => 'Perl::Critic::Exception::Configuration::Option',
        description => 'A problem with global Perl::Critic configuration.',
    },
);

#-----------------------------------------------------------------------------

1;

__END__

#-----------------------------------------------------------------------------

=pod

=for stopwords

=head1 NAME

Perl::Critic::Exception::Configuration::Option::Global - A problem with L<Perl::Critic> global configuration

=head1 DESCRIPTION

A representation of a problem found with the global configuration of
L<Perl::Critic>, whether from a F<.perlcriticrc>, another profile
file, or command line.

This is an abstract class.  It should never be instantiated.


=head1 AUTHOR

Elliot Shank <perl@galumph.com>

=head1 COPYRIGHT

Copyright (c) 2007 Elliot Shank.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :