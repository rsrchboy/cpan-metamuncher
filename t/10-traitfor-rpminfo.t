#!/usr/bin/env perl
#############################################################################
#
# Author:  Chris Weyl (cpan:RSRCHBOY), <cweyl@alumni.drew.edu>
# Company: No company, personal work
# Created: 05/08/2010
#
# Copyright (c) 2010  <cweyl@alumni.drew.edu>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
#############################################################################

=head1 DESCRIPTION

This test exercises applying the RPMInfo trait.

=head1 TESTS

This module defines the following tests.

=cut

use strict;
use warnings;

use Test::More;
use Test::Moose;

use CPAN::MetaMuncher;

my $class = CPAN::MetaMuncher->with_traits('RPMInfo');

diag "classname: $class";

isa_ok $class, 'CPAN::MetaMuncher';

meta_ok $class;
does_ok $class, 'CPAN::MetaMuncher::TraitFor::RPMInfo';
has_attribute_ok $class, '_rpm_requires';
has_attribute_ok $class, '_rpm_build_requires';

done_testing;
__END__

=head1 AUTHOR

Chris Weyl  <cweyl@alumni.drew.edu>

=cut


