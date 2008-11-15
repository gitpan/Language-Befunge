#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

use strict;
use warnings;

use Module::Build;

my %requires = (
    'perl'                  => '5.010',
    'aliased'               => '0.22',
    'Carp'                  => 0,
    'Class::Accessor::Fast' => 0,
    'Config'                => 0,
    'FindBin'               => 0,
    'Math::BaseCalc'        => 0,
    'Readonly'              => 0,
    'Storable'              => 0,
    'UNIVERSAL::require'    => 0,
);
my %build_requires = (
    %requires,
    'List::Util'            => 0,
    'POSIX'                 => 0,
    'Test::Exception'       => 0,
    'Test::More'            => 0,
);
my %recommends = (
    'Language::Befunge::Storage::Generic::Vec::XS' => 0,
    'Language::Befunge::Vector::XS'                => '0.2.2',
    'Test::Builder'                                => 0, # TEST lib
    'Test::Pod'                                    => 0,
    'Test::Pod::Coverage'                          => 0,
    'Time::HiRes'                                  => 0, # HRTI lib
);


my $builder = Module::Build->new
  ( module_name          => 'Language::Befunge',
    license              => 'perl',
    dist_author          => 'Jerome Quelin <jquelin@cpan.org>',
    dist_version_from    => 'lib/Language/Befunge.pm',
    build_requires       => \%build_requires,
    requires             => \%requires,
    recommends           => \%recommends,
    script_files         => [ 'bin/jqbef98' ],
    add_to_cleanup       =>
      [ 'Language-Befunge-*', map { ( '*/' x $_ ) . '*~' } 0..5 ],
    recursive_test_files => 1,
  );
$builder->create_build_script;

