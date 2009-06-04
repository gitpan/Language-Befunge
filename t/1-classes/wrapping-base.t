#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2009 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#
# Language::Befunge::Wrapping
#

use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

use Language::Befunge::Wrapping;

#-- constructor

#- new()
my $w = Language::Befunge::Wrapping->new;
isa_ok($w, 'Language::Befunge::Wrapping');
can_ok($w, 'wrap');
throws_ok(sub { $w->wrap }, qr/not implemented in LBW/, "stub wrap method");
