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
use Test::More tests => 1;

my ($lbi, $ip, $v);


$lbi = Language::Befunge::Interpreter->new;
$ip  = Language::Befunge::IP->new;
$v   = Language::Befunge::Vector->new(1,0);
$ip->set_delta( $v );
$lbi->set_curip( $ip );
Language::Befunge::Ops::dir_turn_right( $lbi );
is( $ip->get_delta, '(0,1)', 'dir_turn_left calls dir_turn_right (LB::IP)' );
