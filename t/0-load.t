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

use Test::More tests => 1;

BEGIN { use_ok( 'Language::Befunge' ); }
diag( "Testing Language::Befunge $Language::Befunge::VERSION, Perl $], $^X" );

exit;
