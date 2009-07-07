#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2009 Jerome Quelin, all rights reserved.
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
    'Class::XSAccessor'     => 0,
    'Config'                => 0,
    'DateTime'              => 0,
    'File::Spec::Functions' => 0,
    'FindBin'               => 0,
    'Getopt::Long'          => 0,
    'IO::File'              => 0,
    'Math::BaseCalc'        => 0, # BASE lib
    'Math::Complex'         => 0, # CPLI lib
    'Math::Trig'            => 0, # FIXP lib
    'Readonly'              => 0,
    'Storable'              => 0,
    'Test::Builder'         => 0, # TEST lib
    'Time::HiRes'           => 0, # HRTI lib
    'UNIVERSAL::require'    => 0,
);
my %build_requires = (
    %requires,
    'IO::Handle'            => 0,
    'IO::Pipe'              => 0,
    'IO::Select'            => 0,
    'List::Util'            => 0,
    'POSIX'                 => 0,
    'Test::Exception'       => 0,
    'Test::More'            => 0,
    'Test::Output'          => 0,
);
my %recommends = (
    'Language::Befunge::Storage::Generic::Vec::XS' => 0,
    'Language::Befunge::Vector::XS'                => '0.2.2',
    'Test::Pod'                                    => 0,
    'Test::Pod::Coverage'                          => 0,
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
      [ 'Language-Befunge-*', '*.tmp', '*.bak', map { ( '*/' x $_ ) . '*~' } 0..5 ],
    recursive_test_files => 1,
    meta_merge           => {
        resources => {
            bugtracker  => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Language-Befunge',
            homepage    => 'http://search.cpan.org/dist/Language-Befunge',
            repository  => 'http://repo.or.cz/w/language-befunge.git',
            MailingList => 'http://listes.mongueurs.net/mailman/listinfo/language-befunge'
        },
    },
  );
$builder->create_build_script;

