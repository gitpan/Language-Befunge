#-*- cperl -*-
# $Id: 03ip.t,v 1.9 2002/04/11 12:49:45 jquelin Exp $
#

#----------------------------------#
#          The IP module.          #
#----------------------------------#

use strict;
use Test;
use Language::Befunge::IP;

my $tests;
BEGIN { $tests = 0 };

# Constructor.
my $ip = new Language::Befunge::IP;
ok( ref($ip), "Language::Befunge::IP");
BEGIN { $tests += 1 };

# Unique ids.
ok( $ip->id, 0 );
$ip = new Language::Befunge::IP;
ok( $ip->id, 1 );
$ip = new Language::Befunge::IP;
ok( $ip->id, 2 );
ok( Language::Befunge::IP::get_new_id, 3 );
BEGIN { $tests += 4 };

# Test accessors.
$ip->curx(36);
ok( $ip->curx, 36 );
$ip->cury(27);
ok( $ip->cury, 27 );
$ip->set_pos(4, 6);
ok( $ip->curx, 4 );
ok( $ip->cury, 6 );
$ip->dx(15);
ok( $ip->dx, 15 );
$ip->dy(-4);
ok( $ip->dy, -4 );
$ip->storx( -5 );
ok( $ip->storx, -5 );
$ip->storx( 16 );
ok( $ip->storx, 16 );
$ip->string_mode( 1 );
ok( $ip->string_mode, 1 );
$ip->space_pushed( 1 );
ok( $ip->space_pushed, 1 );
$ip->input( "gnirts" );
ok( $ip->input, "gnirts" );
BEGIN { $tests += 11 };

# Test stack operations.
ok( $ip->spop, 0); # empty stack should return a 0.
$ip->spush( 45 );
ok( $ip->spop, 45);
$ip->spush( 65, 32, 78, 14, 0, 103, 110, 105, 114, 116, 83 );
ok( $ip->svalue(2),  116 );
ok( $ip->svalue(-2), 116 );
ok( $ip->svalue(1),  83 );
ok( $ip->svalue(-1), 83 );
ok( $ip->scount, 11 );
ok( $ip->spop_gnirts, "String" );
ok( $ip->scount, 4 );
$ip->sclear;
ok( $ip->scount, 0 );
BEGIN { $tests += 10 };

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
# create   (<0)       102        X
# create   (=0)       131        X
# create   (>0)       92        136
# remove   (<0)       117        X
# remove   (=0)       151        X
# remove   (>0)       122       159
# transfer (<0)       156       108
# transfer (=0)       148        X
# transfer (>0)       98        141
$ip->sclear;
$ip->spush( 11, 12, 13, 14, 15, 16, 17, 18, 19 );
ok( $ip->scount, 9 );             # toss = (11,12,13,14,15,16,17,18,19)
ok( $ip->ss_count, 0 );
$ip->ss_create( 2 );              # create new toss, filled with values (enough).
ok( $ip->scount, 2 );             # toss = (18,19)
ok( $ip->soss_count, 7 );         # soss = (11,12,13,14,15,16,17)
ok( $ip->ss_count, 1 );
ok( $ip->spop, 19 );              # toss = (18)
ok( $ip->soss_pop, 17 );          # soss = (11,12,13,14,15,16)
$ip->ss_transfer( 2 );            # move elems from soss to toss (enough).
ok( $ip->scount, 3 );             # toss = (18,16,15)
ok( $ip->soss_count, 4 );         # soss = (11,12,13,14)
ok( $ip->spop, 15 );              # toss = (18,16)
$ip->ss_create( -3 );             # create new toss, filled with zeroes.
ok( $ip->scount, 3 );             # toss = (0,0,0)
ok( $ip->soss_count, 2 );         # soss = (18,16)
ok( $ip->ss_count, 2 );
ok( join("",$ip->ss_sizes), "324" );
ok( $ip->spop, 0 );               # toss = (0,0)
$ip->ss_transfer( -10 );          # move elems from toss to soss (not enough).
ok( $ip->scount, 0 );             # toss = ()
ok( $ip->soss_count, 12 );        # soss = (18,17,0,0,0,0,0,0,0,0,0,0)
$ip->soss_push( 15 );             # soss = (18,17,0,0,0,0,0,0,0,0,0,0,15)
ok( $ip->soss_pop, 15 );          # soss = (18,17,0,0,0,0,0,0,0,0,0,0)
$ip->soss_clear;                  # soss = ()
ok( $ip->soss_count, 0 );
$ip->spush( 16, 17 );             # toss = (16, 17)
$ip->soss_push( 13, 14, 15, 16 ); # soss = (13,14,15,16)
$ip->ss_remove( -1 );             # destroy toss, push zeroes.
ok( $ip->ss_count, 1 );
ok( $ip->scount, 5 );             # toss = (13,14,15,16,0)
ok( $ip->spop, 0 );               # toss = (13,14,15,16)
ok( $ip->spop, 16 );              # toss = (13,14,15)
$ip->ss_remove( 5 );              # destroy toss, push values (not enough).
ok( $ip->ss_count, 0 );
ok( $ip->scount, 9 );             # toss = (11,12,13,14,0,0,13,14,15)
ok( $ip->spop, 15 );              # toss = (11,12,13,14,0,0,13,14)
ok( $ip->spop, 14 );              # toss = (11,12,13,14,0,0,13)
ok( $ip->spop, 13 );              # toss = (11,12,13,14,0,0)
ok( $ip->spop, 0 );               # toss = (11,12,13,14,0)
ok( $ip->spop, 0 );               # toss = (11,12,13,14)
ok( $ip->spop, 14 );              # toss = (11,12,13)
$ip->ss_create( 0 );              # create new toss, no values filled.
ok( $ip->scount, 0 );             # toss = ()
ok( $ip->soss_count, 3 );         # soss = (11,12,13)
ok( $ip->ss_count, 1 );
$ip->spush( 78 );                 # toss = (78)
$ip->ss_create( 3 );              # create new toss, filled with values (not enough).
ok( $ip->scount, 3 );             # toss = (0,0,78)
ok( $ip->soss_count, 0 );         # soss = ()
ok( $ip->ss_count, 2 );
$ip->soss_push( 45 );             # soss = (45)
$ip->ss_transfer( 3 );            # move elems from soss to toss (not enough).
ok( $ip->scount, 6 );             # toss = (0,0,78,45,0,0)
ok( $ip->soss_count, 0 );         # soss = ()
ok( $ip->spop, 0 );               # toss = (0,0,78,45,0)
ok( $ip->spop, 0 );               # toss = (0,0,78,45)
ok( $ip->spop, 45 );              # toss = (0,0,78)
$ip->soss_push( 12 );             # soss = (12)
$ip->ss_transfer( 0 );            # move 0 elems.
ok( $ip->scount, 3 );
ok( $ip->soss_count, 1 );
$ip->ss_remove( 0 );              # destroy toss, no values moved.
ok( $ip->scount, 1 );             # toss = (12)
ok( $ip->soss_count, 3 );         # soss = (11,12,13)
ok( $ip->ss_count, 1 );
$ip->spush( 18 );                 # toss = (12,18)
$ip->ss_transfer( -1 );           # move elems from toss to soss (enough).
ok( $ip->scount, 1 );             # toss = (12)
ok( $ip->soss_count, 4 );         # soss = (11,12,13,18)
$ip->ss_remove( 3 );              # destroy toss, values filled (not enough).
ok( $ip->scount, 7 );             # toss = (11,12,13,18,0,0,12)
ok( $ip->ss_count, 0 );
ok( $ip->spop, 12 );              # toss = (11,12,13,18,0,0)
ok( $ip->spop, 0 );               # toss = (11,12,13,18,0)
ok( $ip->spop, 0 );               # toss = (11,12,13,18)
ok( $ip->spop, 18 );              # toss = (11,12,13)
BEGIN { $tests += 55 };

# Test cardinal directions.
$ip->dir_go_east();
ok( $ip->dx, 1 );
ok( $ip->dy, 0 );
$ip->dir_go_west();
ok( $ip->dx, -1 );
ok( $ip->dy, 0 );
$ip->dir_go_north();
ok( $ip->dx, 0 );
ok( $ip->dy, -1 );
$ip->dir_go_south();
ok( $ip->dx, 0 );
ok( $ip->dy, 1 );
BEGIN { $tests += 8 };

# Test random direction.
$ip->dir_go_away();
ok( abs($ip->dx + $ip->dy), 1);
BEGIN { $tests += 1 };

# Test turn left.
$ip->dir_go_east();
$ip->dir_turn_left();
ok( $ip->dx, 0);
ok( $ip->dy, -1);
$ip->dir_turn_left();
ok( $ip->dx, -1);
ok( $ip->dy, 0);
$ip->dir_turn_left();
ok( $ip->dx, 0);
ok( $ip->dy, 1);
$ip->dir_turn_left();
ok( $ip->dx, 1);
ok( $ip->dy, 0);
BEGIN { $tests += 8 };
$ip->set_delta(3,2);
$ip->dir_turn_left();
ok( $ip->dx, 2);
ok( $ip->dy, -3);
$ip->dir_turn_left();
ok( $ip->dx, -3);
ok( $ip->dy, -2);
$ip->dir_turn_left();
ok( $ip->dx, -2);
ok( $ip->dy, 3);
$ip->dir_turn_left();
ok( $ip->dx, 3);
ok( $ip->dy, 2);
BEGIN { $tests += 8 };

# Test turn right.
$ip->dir_go_east();
$ip->dir_turn_right();
ok( $ip->dx, 0);
ok( $ip->dy, 1);
$ip->dir_turn_right();
ok( $ip->dx, -1);
ok( $ip->dy, 0);
$ip->dir_turn_right();
ok( $ip->dx, 0);
ok( $ip->dy, -1);
$ip->dir_turn_right();
ok( $ip->dx, 1);
ok( $ip->dy, 0);
BEGIN { $tests += 8 };
$ip->set_delta(3,2);
$ip->dir_turn_right();
ok( $ip->dx, -2);
ok( $ip->dy, 3);
$ip->dir_turn_right();
ok( $ip->dx, -3);
ok( $ip->dy, -2);
$ip->dir_turn_right();
ok( $ip->dx, 2);
ok( $ip->dy, -3);
$ip->dir_turn_right();
ok( $ip->dx, 3);
ok( $ip->dy, 2);
BEGIN { $tests += 8 };

# Test reverse.
$ip->dir_go_east();
$ip->dir_reverse();
ok( $ip->dx, -1 );
ok( $ip->dy, 0 );
$ip->dir_reverse();
ok( $ip->dx, 1 );
ok( $ip->dy, 0 );
$ip->set_delta( 2, -3);
$ip->dir_reverse();
ok( $ip->dx, -2 );
ok( $ip->dy, 3 );
$ip->dir_reverse();
ok( $ip->dx, 2 );
ok( $ip->dy, -3 );
BEGIN { $tests += 8 };

# Test cloning.
$ip = new Language::Befunge::IP;
$ip->spush( 1, 5, 6 );
my $clone = $ip->clone;
ok( $ip->id != $clone->id, 1 );
ok( $ip->spop, 6 );
ok( $clone->spop, 6 );
ok( $clone->spop, 5 );
BEGIN { $tests += 4 };

BEGIN { plan tests => $tests };


