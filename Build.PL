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
my $builder = Module::Build->new
  ( module_name          => 'Language::Befunge',
    license              => 'perl',
    dist_author          => 'Jerome Quelin <jquelin@cpan.org>',
    dist_version_from    => 'lib/Language/Befunge.pm',
    build_requires       => {
        'perl'                  => '5.010',
        'aliased'               => '0.22',
        'Carp'                  => 0,
        'Class::Accessor::Fast' => 0,
        'List::Util'            => 0,
        'Readonly'              => 0,
        'Storable'              => 0,
        'Test::Exception'       => 0,
        'Test::More'            => 0,
        'UNIVERSAL::require'    => 0,
    },
    requires             => {
        'perl'                  => '5.010',
        'aliased'               => '0.22',
        'Carp'                  => 0,
        'Class::Accessor::Fast' => 0,
        'List::Util'            => 0,
        'Readonly'              => 0,
        'Storable'              => 0,
        'UNIVERSAL::require'    => 0,
    },
    recommends           => {
        'Language::Befunge::Vector::XS' => '0.2.2',
        'Test::Pod'                     => 0,
        'Test::Pod::Coverage'           => 0,
    },
    script_files         => [ 'bin/jqbf98' ],
    add_to_cleanup       =>
      [ 'Language-Befunge-*', map { ( '*/' x $_ ) . '*~' } 0..5 ],
    recursive_test_files => 1,
  );
$builder->create_build_script;

