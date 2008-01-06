#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

use Language::Befunge::Ops;

use strict;
use warnings;

use Language::Befunge::Interpreter;
use Language::Befunge::IP;
use Language::Befunge::Ops;
use Test::More tests => 2;

my ($lbi, $ip, $v);


$lbi = Language::Befunge::Interpreter->new;
$ip  = Language::Befunge::IP->new;
$lbi->set_curip( $ip );

$ip->spush( 12 );
Language::Befunge::Ops::decis_neg( $lbi );
is( $ip->spop, 0, 'decis_neg pushes false when given true' );

$ip->spush( 0 );
Language::Befunge::Ops::decis_neg( $lbi );
is( $ip->spop, 1, 'decis_neg pushes true when given false' );
