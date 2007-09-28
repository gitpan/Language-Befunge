#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#------------------------------------------#
#          The LaheySpace module.          #
#------------------------------------------#

use strict;
use Test::More;
use Language::Befunge::IP;
use Language::Befunge::LaheySpace;

my $tests;
my $ip = Language::Befunge::IP->new;
my ($w,$h,$href);
BEGIN { $tests = 0 };


# constructor.
my $ls = Language::Befunge::LaheySpace->new;
isa_ok( $ls, "Language::Befunge::LaheySpace");
BEGIN { $tests += 1 };


# clear method.
$ls->clear;
is( $ls->{xmin}, 0, "clear resets xmin" );
is( $ls->{ymin}, 0, "clear resets ymin" );
is( $ls->{xmax}, 0, "clear resets xmax" );
is( $ls->{ymax}, 0, "clear resets ymax" );
BEGIN { $tests += 4; }


# _set_min/_set_max methods.
$ls->clear;
$ls->_set_min( -2, -3 ); # _set_min
is( $ls->{xmin}, -2, "_set_min sets xmin" );
is( $ls->{ymin}, -3, "_set_min sets ymin" );
$ls->_set_min( -1, -1 ); # can't shrink
is( $ls->{xmin}, -2, "_set_min can't shrink xmin" );
is( $ls->{ymin}, -3, "_set_min can't shrink ymin" );
$ls->_set_max( 4, 5 );   # _set_max
is( $ls->{xmax}, 4, "_set_max sets xmax" );
is( $ls->{ymax}, 5, "_set_max sets ymax" );
$ls->_set_max( 2, 3 );   # can't shrink
is( $ls->{xmax}, 4, "_set_max can't shrink xmax" );
is( $ls->{ymax}, 5, "_set_max can't shrink ymax" );
BEGIN{ $tests += 8; }


# _out_of_bounds method.
is( $ls->_out_of_bounds(Language::Befunge::Vector->new(2,-6,  0)), 1, "_out_of_bounds < xmin" );
is( $ls->_out_of_bounds(Language::Befunge::Vector->new(2, 0, -6)), 1, "_out_of_bounds < ymin" );
is( $ls->_out_of_bounds(Language::Befunge::Vector->new(2, 0,  6)), 1, "_out_of_bounds > xmax" );
is( $ls->_out_of_bounds(Language::Befunge::Vector->new(2, 6,  0)), 1, "_out_of_bounds > ymax" );
is( $ls->_out_of_bounds(Language::Befunge::Vector->new(2, 0,  0)), 0, "_out_of_bounds in torus" );
BEGIN{ $tests += 5; }


# enlarge torus.
$ls->clear;
$ls->_enlarge_y( 3 );
is( $ls->{xmin}, 0, "_enlarge_y >0 does not grow xmin" );
is( $ls->{ymin}, 0, "_enlarge_y >0 does not grow ymin" );
is( $ls->{xmax}, 0, "_enlarge_y >0 does not grow xmax" );
is( $ls->{ymax}, 3, "_enlarge_y >0 does grow ymax" );
$ls->_enlarge_x( 2 );
is( $ls->{xmin}, 0, "_enlarge_x >0 does not grow xmin" );
is( $ls->{ymin}, 0, "_enlarge_x >0 does not grow ymin" );
is( $ls->{xmax}, 2, "_enlarge_x >0 does grow xmax" );
is( $ls->{ymax}, 3, "_enlarge_x >0 does not grow ymax" );
$ls->_enlarge_y( -5 );
is( $ls->{xmin}, 0,  "_enlarge_y <0 does not grow xmin" );
is( $ls->{ymin}, -5, "_enlarge_y <0 does grow ymin" );
is( $ls->{xmax}, 2,  "_enlarge_y <0 does not grow xmax" );
is( $ls->{ymax}, 3,  "_enlarge_y <0 does not grow ymax" );
$ls->_enlarge_x( -4 );
is( $ls->{xmin}, -4, "_enlarge_x <0 does grow xmin" );
is( $ls->{ymin}, -5, "_enlarge_x <0 does not grow ymin" );
is( $ls->{xmax}, 2,  "_enlarge_x <0 does not grow xmax" );
is( $ls->{ymax}, 3,  "_enlarge_x <0 does not grow ymax" );
BEGIN { $tests += 16; }


# get/set value.
$ls->clear;
$ls->set_value(Language::Befunge::Vector->new(2, 10, 5), 65 );
is( $ls->{xmax}, 10, "set_value grows xmax if needed" );
is( $ls->{ymax}, 5,  "set_value grows ymax if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  10, 5 )), 65, "get_value returns correct value" );
$ls->set_value(Language::Befunge::Vector->new(2,  -10, -5), 65 );
is( $ls->{xmin}, -10, "set_value grows xmin if needed" );
is( $ls->{ymin}, -5,  "set_value grows ymin if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  -10, -5 )), 65, "get_value returns correct value" );

is( $ls->get_value(Language::Befunge::Vector->new(2,  1, 1)),     32, "get_value defaults to space" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  20, 20)),   32, "get_value out of bounds defaults to space" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  -20, -20)), 32, "get_value out of bounds defaults to space" );

$ls->clear;
$ls->_enlarge_y(3); # corner cases, should not happen - but anyway.
is( $ls->get_value(Language::Befunge::Vector->new(2,  -4, 0)), 32, "get_value defaults to space" );
is( $ls->get_value(Language::Befunge::Vector->new(2,   4, 0)), 32, "get_value defaults to space" );
$ls->{ymax} = 20; # corner case, should not happen - but anyway.
is( $ls->get_value(Language::Befunge::Vector->new(2,   0, 10)), 32, "get_value defaults to space" );
$ls->{xmin} = -20; # corner case, should not happen - but anyway.
is( $ls->get_value(Language::Befunge::Vector->new(2,   0, 0)), 32, "get_value defaults to space" );
BEGIN { $tests += 13; }


# input checking: make sure get_char() returns ASCII.
$ls->set_value(Language::Befunge::Vector->new(2, 0,0), -1);
$ls->set_value(Language::Befunge::Vector->new(2, 1,0),  0);
$ls->set_value(Language::Befunge::Vector->new(2, 2,0),255);
$ls->set_value(Language::Befunge::Vector->new(2, 3,0),256);
is( $ls->get_char(Language::Befunge::Vector->new(2, 0,0)), sprintf("<np-0x%x>", -1), "get_char always returns ascii" );
is( $ls->get_char(Language::Befunge::Vector->new(2, 1,0)), chr(0),       "get_chars always returns ascii" );
is( $ls->get_char(Language::Befunge::Vector->new(2, 2,0)), chr(0xff),    "get_chars always returns ascii" );
is( $ls->get_char(Language::Befunge::Vector->new(2, 3,0)), '<np-0x100>', "get_chars always returns ascii" );
BEGIN { $tests += 4 };


# store method.
$ls->clear;
$ls->store( <<'EOF' );
Foo bar baz
camel llama buffy
EOF
#   5432101234567890123456789012345678
#  2
#  1
#  0     Foo bar baz
#  1     camel llama buffy
#  2
#  3
#  4
is( $ls->{xmin}, 0,  "store does not grow xmin if not needed" );
is( $ls->{ymin}, 0,  "store does not grow ymax if not needed" );
is( $ls->{xmax}, 16, "store grows xmax if needed" );
is( $ls->{ymax}, 1,  "store grows ymax if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  0, 0)),  70, "store stores everything" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  12, 0)), 32, "store defaults to space" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  1, 5)),  32, "store does not store outside of its bounds" );
BEGIN { $tests += 7; }
$ls->store( <<'EOF', Language::Befunge::Vector->new(2, 4, 1) );
Foo bar baz
camel llama buffy
EOF
#   5432101234567890123456789012345678
#  2
#  1
#  0     Foo bar baz
#  1     cameFoo bar baz
#  2         camel llama buffy
#  3
#  4
is( $ls->{xmin}, 0,  "store does not grow xmin if not needed" );
is( $ls->{ymin}, 0,  "store does not grow ymin if not needed" );
is( $ls->{xmax}, 20, "store grows xmax if needed" );
is( $ls->{ymax}, 2,  "store grows ymax if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  0, 0)),  70,  "store respects specified origin" ); # old values.
is( $ls->get_value(Language::Befunge::Vector->new(2,  4, 1)),  70,  "store overwrites if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  20, 2)), 121, "store stores everything" ); # last value.
BEGIN { $tests += 7; }
($w, $h) = $ls->store( <<'EOF', Language::Befunge::Vector->new(2, -2, -1 ))->get_all_components;
Foo bar baz
camel llama buffy
EOF
#   5432101234567890123456789012345678
#  2
#  1   Foo bar baz
#  0   camel llama buffy
#  1     cameFoo bar baz
#  2         camel llama buffy
#  3
#  4
is( $w, 17, "store returns correct inserted width" );
is( $h, 2,  "store returns correct inserted height" );
is( $ls->{xmin}, -2, "store grows xmin if needed" );
is( $ls->{ymin}, -1, "store grows ymin if needed" );
is( $ls->{xmax}, 20, "store does not grow xmax if not needed" );
is( $ls->{ymax}, 2,  "store does not grow ymax if not needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  -2, -1)), 70,  "store stores value in negative indices" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  0, 0 )),  109, "store overwrites if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  4, 1 )),  70,  "store does not overwrite outside its rectangle" );
BEGIN { $tests += 9; }
$ls->store( <<'EOF', Language::Befunge::Vector->new(2, -2, 0 ));
Foo bar baz
camel llama buffy
EOF
#   5432101234567890123456789012345678
#  2
#  1   Foo bar baz
#  0   Foo bar baz
#  1   camel llama buffy
#  2         camel llama buffy
#  3
#  4
is( $ls->{xmin}, -2, "store does not grow xmin if not needed" );
is( $ls->{ymin}, -1, "store does not grow ymin if not needed" );
is( $ls->{xmax}, 20, "store does not grow xmax if not needed" );
is( $ls->{ymax}, 2,  "store does not grow ymax if not needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  -2, 0)), 70,  "store overwrites if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  12, 0 )), 32, "store overwrites with spaces if needed" );
BEGIN { $tests += 6; }


# rectangle.
is( $ls->rectangle(Language::Befunge::Vector->new(2, -3,4),Language::Befunge::Vector->new(2, 1,1)), " \n", "rectangle returns lines ending with \\n" );
is( $ls->rectangle(Language::Befunge::Vector->new(2, -2,-1),Language::Befunge::Vector->new(2, 3,2)), "Foo\nFoo\n", "rectangle works with multiple lines" );
is( $ls->rectangle(Language::Befunge::Vector->new(2, 19,-2),Language::Befunge::Vector->new(2, 2,6)), "  \n  \n  \n  \nfy\n  \n", "rectangle works accross origin" );
BEGIN { $tests += 3; }


# store_binary method
$ls->clear;
($w,$h)=$ls->store_binary( <<'EOF' )->get_all_components;
Foo bar baz
camel llama buffy
EOF
#   5432101234567890123456789012345678901234
#  2
#  1
#  0     Foo bar baz@camel llama buffy
#  1
#  2
is( $ls->{xmin}, 0,  "store_binary does not grow xmin if not needed" );
is( $ls->{ymin}, 0,  "store_binary does not grow ymax if not needed" );
is( $ls->{xmax}, 29, "store_binary grows xmax if needed" );
is( $ls->{ymax}, 0,  "store_binary does not grow ymax if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  0, 0)),  70, "store_binary stores everything" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  0, 35)), 32, "store_binary does not store outside of its bounds" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  10, 0)), 122, "store_binary stores binary" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  11, 0)), 10,  "store_binary stores binary" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  12, 0)), 99,  "store_binary stores binary" );
is( $w, 30, "store_binary flattens input" );
is( $h, 1,  "store_binary flattens input" );
BEGIN { $tests += 11; }
$ls->store_binary( <<'EOF', Language::Befunge::Vector->new(2, 4, 1 ));
Foo bar baz
camel llama buffy
EOF
#   5432101234567890123456789012345678901234
#  2
#  1
#  0     Foo bar baz@camel llama buffy
#  1         Foo bar baz@camel llama buffy
#  2
is( $ls->{xmin}, 0,  "store_binary does not grow xmin if not needed" );
is( $ls->{ymin}, 0,  "store_binary does not grow ymin if not needed" );
is( $ls->{xmax}, 33, "store_binary grows xmax if needed" );
is( $ls->{ymax}, 1,  "store_binary grows ymax if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  0, 0)), 70, "store_binary respects specified origin" ); # old values.
is( $ls->get_value(Language::Befunge::Vector->new(2,  4, 1)), 70, "store_binary stores everything" );
BEGIN { $tests += 6; }
$ls->store_binary( <<'EOF', Language::Befunge::Vector->new(2, -2, -1 ));
Foo bar baz
camel llama buffy
EOF
#   5432101234567890123456789012345678901234
#  2
#  1    Foo bar baz@camel llama buffy
#  0     Foo bar baz@camel llama buffy
#  1         Foo bar baz@camel llama buffy
#  2
is( $ls->{xmin}, -2, "store_binary grows xmin if needed" );
is( $ls->{ymin}, -1, "store_binary grows ymin if needed" );
is( $ls->{xmax}, 33, "store_binary does not grow xmax if not needed" );
is( $ls->{ymax}, 1,  "store_binary does not grow ymax if not needed" );
is( $ls->get_value(Language::Befunge::Vector->new(2,  -2, -1)), 70,  "store_binary stores value in negative indices" );
BEGIN { $tests += 5; }
$ls->store_binary( <<'EOF', Language::Befunge::Vector->new(2, 0, 2 ));
Foo bar baz
camel llama buffy
EOF
#   5432101234567890123456789012345678901234
#  2
#  1    Foo bar baz@camel llama buffy
#  0     FoFoo bar baz@camel llama buffy
#  1         Foo bar baz@camel llama buffy
#  2
is( $ls->get_value(Language::Befunge::Vector->new(2,  0, 2)), 70, "store_binary overwrites if needed" );
BEGIN { $tests += 1; }


# move ip.
$ls->clear;   # "positive" playfield.
$ls->_set_max(5, 10);
$ip->set_position(Language::Befunge::Vector->new(2,  4, 3 ));
$ip->get_delta->set_component(0, 1 );
$ip->get_delta->set_component(1, 0 );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 5, "move_ip_forward respects dx" );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 0, "move_ip_forward wraps xmax" );
$ip->set_position(Language::Befunge::Vector->new(2,  4, 3 ));
$ip->get_delta->set_component(0, 7 );
$ip->get_delta->set_component(1, 0 );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 4, "move_ip_forward deals with delta overflowing torus width" );
$ls->move_ip_forward( $ip ); # wrap xmax harder
is( $ip->get_position->get_component(0), 4, "move_ip_forward deals with delta overflowing torus width" );
$ip->set_position(Language::Befunge::Vector->new(2,  0, 4 ));
$ip->get_delta->set_component(0, -1 );
$ip->get_delta->set_component(1, 0 );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 5, "move_ip_forward wraps xmin" );

$ip->set_position(Language::Befunge::Vector->new(2,  2, 9 ));
$ip->get_delta->set_component(0, 0 );
$ip->get_delta->set_component(1, 1 );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 10, "move_ip_forward respects dy" );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 0,  "move_ip_forward wraps ymax" );
$ip->set_position(Language::Befunge::Vector->new(2,  2, 9 ));
$ip->get_delta->set_component(0, 0 );
$ip->get_delta->set_component(1, 12 );               # apply delta that overflows torus height
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 9, "move_ip_forward deals with delta overflowing torus heigth" );
$ls->move_ip_forward( $ip ); # wrap ymax harder
is( $ip->get_position->get_component(1), 9, "move_ip_forward deals with delta overflowing torus heigth" );
$ip->set_position(Language::Befunge::Vector->new(2,  1, 0 ));
$ip->get_delta->set_component(0, 0 );
$ip->get_delta->set_component(1, -1 );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 10, "move_ip_forward wraps ymin" );
BEGIN { $tests += 10 }

$ls->clear;   # "negative" playfield.
$ls->_set_min(-1, -3);
$ls->_set_max(5, 10);
$ip->set_position(Language::Befunge::Vector->new(2,  4, 3 ));
$ip->get_delta->set_component(0, 1 );
$ip->get_delta->set_component(1, 0 );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 5, "move_ip_forward respects dx" );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), -1, "move_ip_forward wraps xmax" );
$ip->set_position(Language::Befunge::Vector->new(2,  -1, 4 ));
$ip->get_delta->set_component(0, -1 );
$ip->get_delta->set_component(1, 0 );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 5, "move_ip_forward wraps xmin" );
$ip->set_position(Language::Befunge::Vector->new(2,  2, 9 ));
$ip->get_delta->set_component(0, 0 );
$ip->get_delta->set_component(1, 1 );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 10, "move_ip_forward respects dy" );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), -3, "move_ip_forward wraps ymax" );
$ip->set_position(Language::Befunge::Vector->new(2,  1, -3 ));
$ip->get_delta->set_component(0, 0 );
$ip->get_delta->set_component(1, -1 );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 10, "move_ip_forward wraps ymin" );
BEGIN { $tests += 6; }

$ls->clear;   # diagonals.
$ls->_set_min(-1, -2);
$ls->_set_max(6, 5);
$ip->set_position(Language::Befunge::Vector->new(2, 0, 0));
$ip->get_delta->set_component(0,-2);
$ip->get_delta->set_component(1,-3);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 2, "move_ip_forward deals with diagonals" );
is( $ip->get_position->get_component(1), 3, "move_ip_forward deals with diagonals" );
BEGIN { $tests += 2; }


# label lookup
# four directions.
$ls->clear;
$ls->store( <<'EOF', Language::Befunge::Vector->new(2, -2, -1 ));
      3
      ;
      z
      a
      b
      :
2;rab:;:foo;1
      :
      b
      l
      a
      h
      ;
      4
EOF
$href = $ls->labels_lookup;
isa_ok( $href, "HASH" );
is( scalar(keys(%$href)), 4, "labels_lookup finds everything" );
is( $href->{foo}[0], 10,  "labels_lookup finds left-right" );
is( $href->{foo}[1], 5,   "labels_lookup finds left-right" );
is( $href->{foo}[2], 1,   "labels_lookup deals with left-right" );
is( $href->{foo}[3], 0,   "labels_lookup deals with left-right" );
is( $href->{bar}[0], -2,  "labels_lookup finds right-left" );
is( $href->{bar}[1], 5,   "labels_lookup finds right-left" );
is( $href->{bar}[2], -1,  "labels_lookup deals with right-left" );
is( $href->{bar}[3], 0,   "labels_lookup deals with right-left" );
is( $href->{baz}[0], 4,   "labels_lookup finds bottom-top" );
is( $href->{baz}[1], -1,  "labels_lookup finds bottom-top" );
is( $href->{baz}[2], 0,   "labels_lookup deals with bottom-top" );
is( $href->{baz}[3], -1,  "labels_lookup deals with bottom-top" );
is( $href->{blah}[0], 4,  "labels_lookup finds top-bottom" );
is( $href->{blah}[1], 12, "labels_lookup finds top-bottom" );
is( $href->{blah}[2], 0,  "labels_lookup deals with top-bottom" );
is( $href->{blah}[3], 1,  "labels_lookup deals with top-bottom" );
BEGIN { $tests += 18};

# wrapping...
$ls->clear;
$ls->store( <<'EOF', Language::Befunge::Vector->new(2, -2, -1 ));
;1      z  ;   ;:foo
rab:;   a  4      2;
        b
        :  ;
        ;  :
           b
           l
        3  a
        ;  h
EOF
$href = $ls->labels_lookup;
is( scalar(keys(%$href)), 4, "labels_lookup finds everything, even wrapping" );
is( $href->{foo}[0], -1, "labels_lookup finds left-right" );
is( $href->{foo}[1], -1, "labels_lookup finds left-right" );
is( $href->{foo}[2], 1,  "labels_lookup deals with left-right" );
is( $href->{foo}[3], 0,  "labels_lookup deals with left-right" );
is( $href->{bar}[0], 16, "labels_lookup finds right-left" );
is( $href->{bar}[1], 0,  "labels_lookup finds right-left" );
is( $href->{bar}[2], -1, "labels_lookup deals with right-left" );
is( $href->{bar}[3], 0,  "labels_lookup deals with right-left" );
is( $href->{baz}[0], 6,  "labels_lookup finds bottom-top" );
is( $href->{baz}[1], 6,  "labels_lookup finds bottom-top" );
is( $href->{baz}[2], 0,  "labels_lookup deals with bottom-top" );
is( $href->{baz}[3], -1, "labels_lookup deals with bottom-top" );
is( $href->{blah}[0], 9, "labels_lookup finds top-bottom" );
is( $href->{blah}[1], 0, "labels_lookup finds top-bottom" );
is( $href->{blah}[2], 0, "labels_lookup deals with top-bottom" );
is( $href->{blah}[3], 1, "labels_lookup deals with top-bottom" );
BEGIN { $tests += 17 };

# garbage...
$ls->clear;
$ls->store( <<'EOF', Language::Befunge::Vector->new(2, -2, -1 ));
   ;:foo is foo;1
     ;not a label;
EOF
$href = $ls->labels_lookup;
is( scalar(keys(%$href)), 1, "labels_lookup does not looks-alike non-labels" );
is( $href->{foo}[0], 14, "labels_lookup discards comments" );
is( $href->{foo}[1], -1, "labels_lookup discards comments" );
is( $href->{foo}[2], 1,  "labels_lookup discards comments" );
is( $href->{foo}[3], 0,  "labels_lookup discards comments" );
BEGIN { $tests += 5 };

# double define...
$ls->clear;
$ls->store( <<'EOF', Language::Befunge::Vector->new(2, -2, -1 ));
   ;:foo is foo;1
   2;another oof:;
EOF
eval { $href = $ls->labels_lookup; };
like( $@, qr/^Help! I found two labels 'foo' in the funge space/,
      "labels_lookup chokes on double-defined labels" );
BEGIN { $tests += 1 };



BEGIN { plan tests => $tests };
