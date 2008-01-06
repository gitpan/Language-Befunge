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
use Test::More tests => 3;

my ($lbi, $ip, $v);


$lbi = Language::Befunge::Interpreter->new;
$ip  = Language::Befunge::IP->new;
$lbi->set_curip( $ip );

$ip->spush( 21, 42, 4 );
Language::Befunge::Ops::math_remainder( $lbi );
is( $ip->spop, 2,  'math_remainder pushes new value' );
is( $ip->spop, 21, 'math_remainder pops only two values' );

$ip->spush( 21, 10, 0 ); # remainder by zero
Language::Befunge::Ops::math_remainder( $lbi );
is( $ip->spop, 0, 'math_remainder deals with division by zero' );

