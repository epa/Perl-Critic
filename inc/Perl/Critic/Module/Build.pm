#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/branches/Perl-Critic-backlog/inc/Perl/Critic/Module/Build.pm $
#     $Date: 2009-09-07 16:19:21 -0500 (Mon, 07 Sep 2009) $
#   $Author: clonezone $
# $Revision: 3629 $
########################################################################

package Perl::Critic::Module::Build;

use 5.006001;

use strict;
use warnings;

our $VERSION = '1.105';

use Carp;
use English qw< $OS_ERROR $EXECUTABLE_NAME -no_match_vars >;

use base 'Module::Build';


sub ACTION_test {
    my ($self, @arguments) = @_;

    $self->depends_on('manifest');

    return $self->SUPER::ACTION_test(@arguments);
}


sub ACTION_authortest {
    my ($self) = @_;

    $self->_authortest_dependencies();
    $self->depends_on('test');

    return;
}


sub ACTION_authortestcover {
    my ($self) = @_;

    $self->_authortest_dependencies();
    $self->depends_on('testcover');

    return;
}


sub ACTION_distdir {
    my ($self, @arguments) = @_;

    $self->depends_on('authortest');

    return $self->SUPER::ACTION_distdir(@arguments);
}


sub ACTION_nytprof {
    my ($self) = @_;
    $self->depends_on('build');
    $self->_run_nytprof();
    return;
}


sub ACTION_manifest {
    my ($self, @arguments) = @_;

    if (-e 'MANIFEST') {
        unlink 'MANIFEST' or die "Can't unlink MANIFEST: $OS_ERROR";
    }

    return $self->SUPER::ACTION_manifest(@arguments);
}


sub _authortest_dependencies {
    my ($self) = @_;

    $self->depends_on('build');
    $self->depends_on('manifest');
    $self->depends_on('distmeta');

    $self->test_files( qw< t xt/author > );
    $self->recursive_test_files(1);

    return;
}


sub _run_nytprof {
    my ($self) = @_;


    eval {require Devel::NYTProf}
      or croak 'Devel::NYTProf is required to run nytprof';

    eval {require File::Which; File::Which->import('which'); 1}
      or croak 'File::Which is required to run nytprof';

    my $nytprofhtml = which('nytprofhtml')
      or croak 'Could not find nytprofhtml in your PATH';

    my $this_perl = $EXECUTABLE_NAME;
    my @perl_args = qw(-Iblib/lib -d:NYTProf blib/script/perlcritic);
    my @perlcritic_args = qw(-noprofile -severity=1 -theme=core -exclude=TidyCode -exclude=PodSpelling blib);
    warn join q{ }, 'Running:', $this_perl, @perl_args, @perlcritic_args, "\n";

    my $status_perlcritic = system $this_perl, @perl_args, @perlcritic_args;
    croak "perlcritic failed with status $status_perlcritic" if $status_perlcritic == 1;

    my $status_nytprofhtml = system $nytprofhtml;
    croak "nytprofhtml failed with status $status_nytprofhtml" if $status_nytprofhtml;

    return;
}

1;


__END__

#-----------------------------------------------------------------------------

=pod

=for stopwords

=head1 NAME

Perl::Critic::Module::Build - Customization of L<Module::Build> for L<Perl::Critic>.


=head1 DESCRIPTION

This is a custom subclass of L<Module::Build> that enhances existing
functionality and adds more for the benefit of installing and
developing L<Perl::Critic>.


=head1 METHODS

=over

=item C<ACTION_test()>

In addition to the standard action, this adds a dependency upon the
C<manifest> action.


=item C<ACTION_authortest()>

Runs the regular tests plus the author tests (those in F<xt/author>).
It used to be the case that author tests were run if an environment
variable was set or if a F<.svn> directory existed.  What ended up
happening was that people that had that environment variable set for
other purposes or who had done a checkout of the code repository would
run those tests, which would fail, and we'd get bug reports for
something not expected to run elsewhere.  Now, you've got to
explicitly ask for the author tests to be run.


=item C<ACTION_authortestcover()>

As C<authortest> is to the standard C<test> action, C<authortestcover>
is to the standard C<testcover> action.


=item C<ACTION_distdir()>

In addition to the standard action, this adds a dependency upon the
C<authortest> action so you can't do a release without passing the
author tests.

=item C<ACTION_nytprof()>

Runs perlcritic under the L<Devel::NYTProf> profiler and generates
an HTML report in F<nytprof/index.html>.


=back


=head1 AUTHOR

Elliot Shank <perl@galumph.com>

=head1 COPYRIGHT

Copyright (c) 2007-2009 Elliot Shank.  All rights reserved.

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
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
