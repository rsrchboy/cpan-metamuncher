#!/usr/bin/env perl
#############################################################################
#
# Author:  Chris Weyl (cpan:RSRCHBOY), <cweyl@alumni.drew.edu>
# Company: No company, personal work
# Created: 05/06/2010
#
# Copyright (c) 2010  <cweyl@alumni.drew.edu>
#
#############################################################################

=head1 DESCRIPTION

This test exercises...

=head1 TESTS

This module defines the following tests.

=cut

use strict;
use warnings;

use Test::More 0.92;

use CPAN::MetaMuncher;

my $mm = CPAN::MetaMuncher->new(module => 'MooseX::Traits');

isa_ok $mm, 'CPAN::MetaMuncher';

ok $mm->has_build_requires, 'has_build_requires';
is $mm->num_build_requires, 5, 'correct num_build_requires';

done_testing;

__END__

=head1 AUTHOR

Chris Weyl  <cweyl@alumni.drew.edu>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010  <cweyl@alumni.drew.edu>

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the

     Free Software Foundation, Inc.
     59 Temple Place, Suite 330
     Boston, MA  02111-1307  USA

=cut
