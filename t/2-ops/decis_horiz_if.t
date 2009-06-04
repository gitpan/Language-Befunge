#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2009 Jerome Quelin, all rights reserved.
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
use Language::Befunge::Vector;
use Test::More tests => 3;

my ($lbi, $ip, $v);


$lbi = Language::Befunge::Interpreter->new;
$ip  = Language::Befunge::IP->new;
$v   = Language::Befunge::Vector->new(4,4);
$ip->set_delta( $v );
$lbi->set_curip( $ip );

$ip->spush( 12, 42 );
Language::Befunge::Ops::decis_horiz_if( $lbi );
is( $ip->get_delta, '(-1,0)',
    'decis_horiz_if sets delta to west if popped value is true' );
is( $ip->spop, 12, 'decis_horiz_if pops only one value' );

$ip->spush( 0 );
Language::Befunge::Ops::decis_horiz_if( $lbi );
is( $ip->get_delta, '(1,0)',
    'decis_horiz_if sets delta to east if popped value is true' );

