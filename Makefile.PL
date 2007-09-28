#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

use strict;
use warnings;

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME          => 'Language::Befunge',
    AUTHOR        => 'Jerome Quelin, <jquelin@cpan.org>',
    VERSION_FROM  => 'lib/Language/Befunge.pm',
    ABSTRACT_FROM => 'lib/Language/Befunge.pm',
    EXE_FILES     => [ 'bin/jqbf98' ],
    LICENSE       => 'perl',
    PREREQ_PM     => { Storable => 0, 'Test::More' => 0 },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => [
                    'Language-Befunge-*',
					map { ( '*/' x $_ ) . '*~' } 0..4 ] },
);


