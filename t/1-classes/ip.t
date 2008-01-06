#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#----------------------------------#
#          The IP module.          #
#----------------------------------#

use strict;
use Test::More;
use Language::Befunge::IP;

my $tests;
BEGIN { $tests = 0 };

# Constructor.
my $ip = Language::Befunge::IP->new;
is( ref($ip), "Language::Befunge::IP");
BEGIN { $tests += 1 };

# Unique ids.
is( $ip->get_id, 0 );
$ip = Language::Befunge::IP->new;
is( $ip->get_id, 1 );
$ip = Language::Befunge::IP->new;
is( $ip->get_id, 2 );
is( Language::Befunge::IP::_get_new_id, 3 );
BEGIN { $tests += 4 };

# Test accessors.
$ip->get_position->set_component(0,36);
is( $ip->get_position->get_component(0), 36 );
$ip->get_position->set_component(1,27);
is( $ip->get_position->get_component(1), 27 );
$ip->set_position(Language::Befunge::Vector->new(2, 4, 6));
is( $ip->get_position->get_component(0), 4 );
is( $ip->get_position->get_component(1), 6 );
$ip->get_delta->set_component(0,15);
is( $ip->get_delta->get_component(0), 15 );
$ip->get_delta->set_component(1,-4);
is( $ip->get_delta->get_component(1), -4 );
$ip->get_storage->set_component(0, -5 );
is( $ip->get_storage->get_component(0), -5 );
$ip->get_storage->set_component(0, 16 );
is( $ip->get_storage->get_component(0), 16 );
$ip->set_string_mode( 1 );
is( $ip->get_string_mode, 1 );
$ip->set_end( 1 );
is( $ip->get_end, 1 );
$ip->set_input( "gnirts" );
is( $ip->get_input, "gnirts" );
$ip->set_data({}); # meaningless, only to test accessors
$ip->set_libs([]); # meaningless, only to test accessors
$ip->set_ss([]);   # meaningless, only to test accessors
BEGIN { $tests += 11 };

# Test stack operations.
is( $ip->spop, 0, "empty stack returns a 0" );
is( $ip->spop_gnirts, "", "empty stack returns empty gnirts" );
is( $ip->svalue(5), 0); # empty stack should return a 0.
$ip->spush( 45 );
is( $ip->spop, 45);
$ip->spush( 65, 32, 78, 14, 0, 103, 110, 105, 114, 116, 83 );
is( $ip->svalue(2),  116 );
is( $ip->svalue(-2), 116 );
is( $ip->svalue(1),  83 );
is( $ip->svalue(-1), 83 );
is( $ip->scount, 11 );
is( $ip->spop_gnirts, "String" );
is( $ip->scount, 4 );
$ip->spush_vec(Language::Befunge::Vector->new(2, 4, 5));
is( $ip->scount, 6);
is( $ip->spop, 5 );
is( $ip->spop, 4 );
$ip->spush(18, 74);
my ($x, $y) = $ip->spop_vec->get_all_components();
is( $x, 18 );
is( $y, 74 );
($x, $y) = $ip->spop_mult(2);
is( $x, 78 );
is( $y, 14 );
$ip->spush_args( "foo", 7, "bar" );
is( $ip->scount, 11 );
is( $ip->spop, 98 );
is( $ip->spop, 97 );
is( $ip->spop, 114 );
is( $ip->spop, 0 );
is( $ip->spop, 7 );
is( $ip->spop_gnirts, "foo" );
$ip->sclear;
is( $ip->scount, 0 );
BEGIN { $tests += 26 };

# Test stack stack.
# The following table gives the line number where the
# corresponding test is done.
#
# create = $ip->ss_create
# remove = $ip->ss_remove
# transfer = $ip->ss_transfer
#
# enough means there's enough values in the start stack to perform the
# action. not enough means there's not enough values in the start
# stack to perform the action (filled with zeroes).
#
#                   enough   not enough
# create   (<0)      106         X
# create   (=0)      136         X
# create   (>0)       96        141
# remove   (<0)      121         X
# remove   (=0)      156         X
# remove   (>0)      164        127
# transfer (<0)      161        110
# transfer (=0)      153         X
# transfer (>0)      102        146
$ip->sclear;
$ip->spush( 11, 12, 13, 14, 15, 16, 17, 18, 19 );
is( $ip->scount, 9 );             # toss = (11,12,13,14,15,16,17,18,19)
is( $ip->ss_count, 0 );
$ip->ss_create( 2 );              # create new toss, filled with values (enough).
is( $ip->scount, 2 );             # toss = (18,19)
is( $ip->soss_count, 7 );         # soss = (11,12,13,14,15,16,17)
is( $ip->ss_count, 1 );
is( $ip->spop, 19 );              # toss = (18)
is( $ip->soss_pop, 17 );          # soss = (11,12,13,14,15,16)
$ip->ss_transfer( 2 );            # move elems from soss to toss (enough).
is( $ip->scount, 3 );             # toss = (18,16,15)
is( $ip->soss_count, 4 );         # soss = (11,12,13,14)
is( $ip->spop, 15 );              # toss = (18,16)
$ip->ss_create( -3 );             # create new toss, filled with zeroes.
is( $ip->scount, 3 );             # toss = (0,0,0)
is( $ip->soss_count, 2 );         # soss = (18,16)
is( $ip->ss_count, 2 );
is( join("",$ip->ss_sizes), "324" );
is( $ip->spop, 0 );               # toss = (0,0)
$ip->ss_transfer( -10 );          # move elems from toss to soss (not enough).
is( $ip->scount, 0 );             # toss = ()
is( $ip->soss_count, 12 );        # soss = (18,17,0,0,0,0,0,0,0,0,0,0)
$ip->soss_push( 15 );             # soss = (18,17,0,0,0,0,0,0,0,0,0,0,15)
is( $ip->soss_pop, 15 );          # soss = (18,17,0,0,0,0,0,0,0,0,0,0)
$ip->soss_clear;                  # soss = ()
is( $ip->soss_pop, 0, "soss_pop returns a 0 on empty soss" );
is( $ip->soss_count, 0 );
$ip->spush( 16, 17 );             # toss = (16, 17)
$ip->soss_push( 13, 14, 15, 16 ); # soss = (13,14,15,16)
$ip->ss_remove( -1 );             # destroy toss, remove elems.
is( $ip->ss_count, 1 );
is( $ip->scount, 3 );             # toss = (13,14,15)
is( $ip->spop, 15 );              # toss = (13,14)
is( $ip->spop, 14 );              # toss = (13)
$ip->spush( 14, 15 );
$ip->ss_remove( 5 );              # destroy toss, push values (not enough).
is( $ip->ss_count, 0 );
is( $ip->scount, 9 );             # toss = (11,12,13,14,0,0,13,14,15)
is( $ip->spop, 15 );              # toss = (11,12,13,14,0,0,13,14)
is( $ip->spop, 14 );              # toss = (11,12,13,14,0,0,13)
is( $ip->spop, 13 );              # toss = (11,12,13,14,0,0)
is( $ip->spop, 0 );               # toss = (11,12,13,14,0)
is( $ip->spop, 0 );               # toss = (11,12,13,14)
is( $ip->spop, 14 );              # toss = (11,12,13)
$ip->ss_create( 0 );              # create new toss, no values filled.
is( $ip->scount, 0 );             # toss = ()
is( $ip->soss_count, 3 );         # soss = (11,12,13)
is( $ip->ss_count, 1 );
$ip->spush( 78 );                 # toss = (78)
$ip->ss_create( 3 );              # create new toss, filled with values (not enough).
is( $ip->scount, 3 );             # toss = (0,0,78)
is( $ip->soss_count, 0 );         # soss = ()
is( $ip->ss_count, 2 );
$ip->soss_push( 45 );             # soss = (45)
$ip->ss_transfer( 3 );            # move elems from soss to toss (not enough).
is( $ip->scount, 6 );             # toss = (0,0,78,45,0,0)
is( $ip->soss_count, 0 );         # soss = ()
is( $ip->spop, 0 );               # toss = (0,0,78,45,0)
is( $ip->spop, 0 );               # toss = (0,0,78,45)
is( $ip->spop, 45 );              # toss = (0,0,78)
$ip->soss_push( 12 );             # soss = (12)
$ip->ss_transfer( 0 );            # move 0 elems.
is( $ip->scount, 3 );
is( $ip->soss_count, 1 );
$ip->ss_remove( 0 );              # destroy toss, no values moved.
is( $ip->scount, 1 );             # toss = (12)
is( $ip->soss_count, 3 );         # soss = (11,12,13)
is( $ip->ss_count, 1 );
$ip->spush( 18 );                 # toss = (12,18)
$ip->ss_transfer( -1 );           # move elems from toss to soss (enough).
is( $ip->scount, 1 );             # toss = (12)
is( $ip->soss_count, 4 );         # soss = (11,12,13,18)
$ip->ss_remove( 1 );              # destroy toss, values filled (enough).
is( $ip->scount, 5 );             # toss = (11,12,13,18,12)
is( $ip->ss_count, 0 );
is( $ip->spop, 12 );              # toss = (11,12,13,18)
is( $ip->spop, 18 );              # toss = (11,12,13)
is( $ip->spop, 13 );              # toss = (11,12)
is( $ip->spop, 12 );              # toss = (11)
$ip->ss_create( 0 );              # toss = () soss = (11)
$ip->ss_remove( -3 );             # destroy toss, remove elems
is( $ip->scount, 0, "ss_remove can clear completely the soss-to-be-toss" );
BEGIN { $tests += 57 };

# Test cardinal directions.
$ip->dir_go_east();
is( $ip->get_delta->get_component(0), 1 );
is( $ip->get_delta->get_component(1), 0 );
$ip->dir_go_west();
is( $ip->get_delta->get_component(0), -1 );
is( $ip->get_delta->get_component(1), 0 );
$ip->dir_go_north();
is( $ip->get_delta->get_component(0), 0 );
is( $ip->get_delta->get_component(1), -1 );
$ip->dir_go_south();
is( $ip->get_delta->get_component(0), 0 );
is( $ip->get_delta->get_component(1), 1 );
BEGIN { $tests += 8 };

# Test random direction.
$ip->dir_go_away();
is( abs($ip->get_delta->get_component(0) + $ip->get_delta->get_component(1)), 1);
BEGIN { $tests += 1 };

# Test turn left.
$ip->dir_go_east();
$ip->dir_turn_left();
is( $ip->get_delta->get_component(0), 0);
is( $ip->get_delta->get_component(1), -1);
$ip->dir_turn_left();
is( $ip->get_delta->get_component(0), -1);
is( $ip->get_delta->get_component(1), 0);
$ip->dir_turn_left();
is( $ip->get_delta->get_component(0), 0);
is( $ip->get_delta->get_component(1), 1);
$ip->dir_turn_left();
is( $ip->get_delta->get_component(0), 1);
is( $ip->get_delta->get_component(1), 0);
BEGIN { $tests += 8 };
$ip->set_delta(Language::Befunge::Vector->new(2,3,2));
$ip->dir_turn_left();
is( $ip->get_delta->get_component(0), 2);
is( $ip->get_delta->get_component(1), -3);
$ip->dir_turn_left();
is( $ip->get_delta->get_component(0), -3);
is( $ip->get_delta->get_component(1), -2);
$ip->dir_turn_left();
is( $ip->get_delta->get_component(0), -2);
is( $ip->get_delta->get_component(1), 3);
$ip->dir_turn_left();
is( $ip->get_delta->get_component(0), 3);
is( $ip->get_delta->get_component(1), 2);
BEGIN { $tests += 8 };

# Test turn right.
$ip->dir_go_east();
$ip->dir_turn_right();
is( $ip->get_delta->get_component(0), 0);
is( $ip->get_delta->get_component(1), 1);
$ip->dir_turn_right();
is( $ip->get_delta->get_component(0), -1);
is( $ip->get_delta->get_component(1), 0);
$ip->dir_turn_right();
is( $ip->get_delta->get_component(0), 0);
is( $ip->get_delta->get_component(1), -1);
$ip->dir_turn_right();
is( $ip->get_delta->get_component(0), 1);
is( $ip->get_delta->get_component(1), 0);
BEGIN { $tests += 8 };
$ip->set_delta(Language::Befunge::Vector->new(2,3,2));
$ip->dir_turn_right();
is( $ip->get_delta->get_component(0), -2);
is( $ip->get_delta->get_component(1), 3);
$ip->dir_turn_right();
is( $ip->get_delta->get_component(0), -3);
is( $ip->get_delta->get_component(1), -2);
$ip->dir_turn_right();
is( $ip->get_delta->get_component(0), 2);
is( $ip->get_delta->get_component(1), -3);
$ip->dir_turn_right();
is( $ip->get_delta->get_component(0), 3);
is( $ip->get_delta->get_component(1), 2);
BEGIN { $tests += 8 };

# Test reverse.
$ip->dir_go_east();
$ip->dir_reverse();
is( $ip->get_delta->get_component(0), -1 );
is( $ip->get_delta->get_component(1), 0 );
$ip->dir_reverse();
is( $ip->get_delta->get_component(0), 1 );
is( $ip->get_delta->get_component(1), 0 );
$ip->set_delta(Language::Befunge::Vector->new(2, 2, -3));
$ip->dir_reverse();
is( $ip->get_delta->get_component(0), -2 );
is( $ip->get_delta->get_component(1), 3 );
$ip->dir_reverse();
is( $ip->get_delta->get_component(0), 2 );
is( $ip->get_delta->get_component(1), -3 );
BEGIN { $tests += 8 };

# Test cloning.
$ip = Language::Befunge::IP->new;
$ip->spush( 1, 5, 6 );
my $clone = $ip->clone;
is( $ip->get_id != $clone->get_id, 1 );
is( $ip->spop, 6 );
is( $clone->spop, 6 );
is( $clone->spop, 5 );
BEGIN { $tests += 4 };

# extension data.
$ip->extdata( "HELO", "foobar" );
is( $ip->extdata("HELO"), "foobar", "restore previously saved data" );
BEGIN { $tests += 1 };


BEGIN { plan tests => $tests };


