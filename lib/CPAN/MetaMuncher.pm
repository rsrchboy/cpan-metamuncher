#############################################################################
#
# Digest a META.yml so we can get at the good parts easily :)
#
# Author:  Chris Weyl (cpan:RSRCHBOY), <cweyl@alumni.drew.edu>
# Company: No company, personal work
# Created: 05/11/2009 11:32:18 PM PDT
#
# Copyright (c) 2009 Chris Weyl <cweyl@alumni.drew.edu>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
#############################################################################

package CPAN::MetaMuncher;

use Moose;
use namespace::autoclean;
use MooseX::Types::Moose       ':all';
use MooseX::Types::Path::Class ':all';

with 'MooseX::Traits';
has '+_trait_namespace' => (default => 'CPAN::MetaMuncher::TraitFor');

use CPAN::Easy;
use Path::Class;

our $VERSION = '0.007_02';

# debugging
#use Smart::Comments '###', '####';

#############################################################################
# required / buildargs

# we require either module or filename to be passed... since one or the other
# suffices, we forgo the usual "required => 1" and instead check that we have
# at least one of them after BUILDARGS has had a chance to run.

has module   => (is => 'ro', isa => Str, lazy_build => 1);
has filename => (is => 'ro', isa => File, coerce => 1, lazy_build => 1);

after BUILDARGS => sub {
    my $class = shift @_;

    my $args = ref $_[0] ? $_[0] : { @_ };
    die 'We require either module or filename, but neither was passed'
        unless exists $args->{module} || exists $args->{filename};

    return;
};

#############################################################################
# Our parsed META.yml

# pretty simplistic -- CPAN::Easy does most of the work here if we're passed
# a module, otherwise we just load and parse from the filename.

has _meta => (
    traits => ['Hash'], is => 'ro', lazy_build => 1, isa => 'HashRef',
    handles => {
        has_meta_key   => 'exists',
        meta_entry_for => 'get',

        meta_keys     => 'keys',
        num_meta_keys => 'count',
        has_meta_keys => 'count',
    },
);

sub _build__meta {
    my $self = shift @_;

    return CPAN::Easy->get_meta_for($self->module)
        if $self->has_module;

    die 'Need to implement loading from filename!';
    return;
}

#############################################################################
# Our scalar data

# we handle all of the items with only one value via one hash, and let Moose
# do the work by generating accessor methods.

sub _scalars_list { qw{ abstract distribution_type generated_by license name version } }
my @scalars = __PACKAGE__->_scalars_list;

has _scalars => (
    traits => ['Hash'], is => 'ro', isa => 'HashRef[Str]', lazy_build => 1,
    handles =>
        { sub { map { $_ => [ get => $_ ], "has_$_" => [ exists => $_ ] } @scalars }->() },
);

sub _build__scalars { [ shift->_meta->{@scalars} ] }

#############################################################################
# Our key/value data

# handle all data with one-level key/value pairs; e.g. requires.

sub _hashes_list { qw{  build_requires configure_requires requires } }
my @hashes = __PACKAGE__->_hashes_list;

for my $hash (@hashes) {

    has "_$hash" => (
        traits => ['Hash'], is => 'ro', isa => 'HashRef[Str]', lazy => 1,
        default => sub { shift->_meta->{$hash} || { } },
        handles => {
            "has_$hash" => 'count',             # has_foos
            "num_$hash" => 'count',             # num_foos
            $hash       => 'keys',              # foos
            $hash . '_value' => 'get',          # foos_value(x)
            "has_a_$hash" . '_on' => 'exists',  # has_a_foos_on(x)
        },
    );
}

#############################################################################
# "resources"

# Handle the resources section by providing direct exists/get accessors to the
# "official" keywords, as well as more generic access to all keywords that may
# exist.  Note that "license" is handled as "license_resource", so as to avoid
# conflicting with the license accessor above.
#
# Note also that while our values are URI's, we handle them as plain
# strings....  we might want to reevaluate this.

# license handled separately
sub _resources_list { qw{ homepage bugtracker repository } }
my @resources = __PACKAGE__->_resources_list;

has _resources => (
    traits => ['Hash'], is => 'ro', isa => 'HashRef[Str]', lazy_build => 1,
    handles => {

        # conflicts otherwise...
        has_license_resource => [ exists => 'license' ],
        license_resource     => [ get    => 'license' ],

        # has_resource, (get) resource for all resources defined
        sub { map { +"has_$_" => [ exists => $_ ], $_ => [ get => $_ ] } @resources }->(),

        # generic
        has_resource   => 'exists',
        resource_value_of => 'get',
        resources      => 'keys',
        num_resources  => 'count',
        has_resources  => 'count',
    },
);

sub _build_resources { shift->_meta->{resources} || { } }

#############################################################################
# author / author info

has _authors => (
    traits => ['Array'], is => 'ro', isa => 'ArrayRef[Str]', lazy_build => 1,
    handles => {
        author  => [ get => 0 ],
        authors => 'elements',
        num_authors => 'count',
        has_authors => 'count',
        grep_authors => 'grep',
        map_authors  => 'map',
        join_authors => 'join',
        all_authors => [ join => ', ' ],
    },
);

sub _build__authors { shift->_meta->{authors} }

__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

CPAN::MetaMuncher - Digest a META.yml

=head1 SYNOPSIS

    use CPAN::MetaMuncher;

    # ...
    my $mm = CPAN::MetaMuncher->new(module => $module_name);

    # or, to apply CPAN::MetaMuncher::RPMInfo and get handy rpm methods
    my $mmrpm = CPAN::MetaMuncher->with_traits('RPMInfo')->new(...);

    # ...

=head1 DESCRIPTION

B<WARNING: This is VERY early code.>

An abstraction layer for META.yml, and possibly others.  Right now we support
the META.yml spec 1.4, though this is likely to be expanded in the future.

=head1 "GENERIC" METHODS

=head2 has_meta_key

=head2 meta_entry_for

=head2 meta_keys

Returns a list of all keys used by this META.yml.

=head2 num_meta_keys

=head2 has_meta_keys

=head1 TRAITSFOR

This package can be composed with various traits to allow for additional
functionality, etc.  (Note this is "traits" in the sense of "role layered on
top of a concrete class" rather than "metaclass role"; see, e.g., the TraitFor
packages for L<Catalyst>.)

Traits for CPAN::MetaMuncher live under the CPAN::MetaMuncher::TraitsFor
namespace.

=head2 RPMInfo

Additional methods to help construct dependency info in a way RPM can
understand and use it.

See L<CPAN::MetaMuncher::TraitsFor::RPMInfo> for details.


=head1 SEE ALSO

L<CPAN::Easy>

=head1 AUTHOR

Chris Weyl  <cweyl@alumni.drew.edu>


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009-2010 Chris Weyl <cweyl@alumni.drew.edu>

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



