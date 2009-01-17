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
use Language::Befunge::Vector;
use Test::More tests => 5;

my ($lbi, $ip, $v);


$lbi = Language::Befunge::Interpreter->new;
$ip  = Language::Befunge::IP->new;
$v   = Language::Befunge::Vector->new(1,0);
$ip->set_delta( $v );
$lbi->set_curip( $ip );

$ip->spush( 3, 0 );
$lbi->store_code( '789q' );
Language::Befunge::Ops::flow_repeat( $lbi );
is( $ip->get_position, '(1,0)', 'flow_repeat moves ip' );
is( $ip->spop, 3, 'flow_repeat pops only one value' );

# regular instruction.
$v   = Language::Befunge::Vector->new(0,0);
$ip->set_position( $v );
$lbi->store_code( '789q' );
$ip->spush( 3 );
Language::Befunge::Ops::flow_repeat( $lbi );
is( join('|', $ip->spop_mult(4)), '0|8|8|8', 'flow_repeat repeats the following instruction' );

# positive (>256) instruction.
$v   = Language::Befunge::Vector->new(0,0);
$ip->set_position( $v );
$v   = Language::Befunge::Vector->new(1,0);
$ip->set_delta( $v );
$lbi->store_code( '789q' );
$v   = Language::Befunge::Vector->new(1,0);
$lbi->get_storage->set_value( $v, 400 );
$ip->spush( 3 );
Language::Befunge::Ops::flow_repeat( $lbi );
is( $ip->get_delta, '(-1,0)', 'flow_repeat repeats also instructions >256' );

# negative instruction.
$v   = Language::Befunge::Vector->new(0,0);
$ip->set_position( $v );
$v   = Language::Befunge::Vector->new(1,0);
$ip->set_delta( $v );
$lbi->store_code( '789q' );
$v   = Language::Befunge::Vector->new(1,0);
$lbi->get_storage->set_value( $v, -4 );
$ip->spush( 3 );
Language::Befunge::Ops::flow_repeat( $lbi );
is( $ip->get_delta, '(-1,0)', 'flow_repeat repeats also negative instructions' );


# can't repeat negatively.
$v   = Language::Befunge::Vector->new(1,0);
$ip->set_delta( $v );
$v   = Language::Befunge::Vector->new(0,0);
$ip->set_position( $v );
$lbi->store_code( '789q' );
$ip->spush( -3 );
# no tests, it's just to use all code pathes


# don't repeat forbidden instruction.
$v   = Language::Befunge::Vector->new(1,0);
$ip->set_delta( $v );
$v   = Language::Befunge::Vector->new(0,0);
$ip->set_position( $v );
$lbi->store_code( '7;9q' );
$ip->spush( 3 );
# no tests, it's just to use all code pathes

