#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

BEGIN { require 5.010; }
use strict;
use warnings;

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME          => 'Language::Befunge',
    AUTHOR        => 'Jerome Quelin, <jquelin@cpan.org>',
    VERSION_FROM  => 'lib/Language/Befunge.pm',
    ABSTRACT_FROM => 'lib/Language/Befunge.pm',
    EXE_FILES     => [ 'bin/jqbef98' ],
    LICENSE       => 'perl',
    PREREQ_PM     => {
        'aliased'               => '0.22',
        'Carp'                  => 0,
        'Class::Accessor::Fast' => 0,
        'Config'                => 0,
        'FindBin'               => 0,
        'List::Util'            => 0,
        'Math::BaseCalc'        => 0,
        'POSIX'                 => 0,
        'Readonly'              => 0,
        'Storable'              => 0,
        'Test::Exception'       => 0,
        'Test::More'            => 0,
        'UNIVERSAL::require'    => 0,
    },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => [
                    'Language-Befunge-*',
                    map { ( '*/' x $_ ) . '*~' } 0..5 ] },
    test          => { TESTS => 't/*.t t/*/*.t' },
);


