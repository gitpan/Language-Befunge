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
use Test::More tests => 4;

my ($lbi, $ip, $v);


$lbi = Language::Befunge::Interpreter->new;
$ip  = Language::Befunge::IP->new;
$v   = Language::Befunge::Vector->new(4,4);
$ip->spush( 12, 42 );
$ip->set_delta( $v );
$lbi->set_curip( $ip );

Language::Befunge::Ops::flow_quit( $lbi );
is( $ip->get_end, 'q', 'flow_quit sets end of thread' );
is( $lbi->get_retval, 42, 'flow_quit sets return value for lbi' );
is( scalar @{$lbi->get_newips}, 0, 'flow_quit removes all ips to be ran next tick' );
is( scalar @{$lbi->get_ips},    0, 'flow_quit removes all ips to be ran' );
