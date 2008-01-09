#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#------------------------------------------------------------------#
#          The LaheySpace module (N-dimensional generic).          #
#------------------------------------------------------------------#

use strict;
use warnings;

use Test::More tests => 168;

use Language::Befunge::IP;
use Language::Befunge::LaheySpace::Generic;


my $tests;
my $ip = Language::Befunge::IP->new(4);
my $zerovec = Language::Befunge::Vector->new_zeroes(4);
my ($w,$h,$href);


# constructor.
my $ls = Language::Befunge::LaheySpace::Generic->new(4);
isa_ok( $ls, "Language::Befunge::LaheySpace::Generic");


# clear method.
$ls->clear;
ok( $ls->{min} == $zerovec, "clear resets min" );
ok( $ls->{max} == $zerovec, "clear resets max" );


# _enlarge/_enlarge methods.
$ls->clear;
$ls->_enlarge(Language::Befunge::Vector->new(4, -2, -3, 0, 0)); # _enlarge
is( $ls->{min}->get_component(0), -2, "_enlarge sets min[x]" );
is( $ls->{min}->get_component(1), -3, "_enlarge sets min[y]" );
is( $ls->{min}->get_component(2),  0, "_enlarge(0) doesn't change zmin" );
is( $ls->{min}->get_component(3),  0, "_enlarge(0) doesn't change 4min" );
$ls->_enlarge(Language::Befunge::Vector->new(4, -1, -1, 0, 0)); # can't shrink
is( $ls->{min}->get_component(0), -2, "_enlarge can't shrink min[x]" );
is( $ls->{min}->get_component(1), -3, "_enlarge can't shrink min[y]" );
$ls->_enlarge(Language::Befunge::Vector->new(4, 4, 5, 0, 0));   # _enlarge
is( $ls->{max}->get_component(0), 4, "_enlarge sets max[x]" );
is( $ls->{max}->get_component(1), 5, "_enlarge sets max[y]" );
$ls->_enlarge(Language::Befunge::Vector->new(4, 2, 3, 0, 0));   # can't shrink
is( $ls->{max}->get_component(0), 4, "_enlarge can't shrink max[x]" );
is( $ls->{max}->get_component(1), 5, "_enlarge can't shrink max[y]" );


# enlarge torus.
$ls->clear;
$ls->_enlarge(Language::Befunge::Vector->new(4, 0, 3, 0, 0) );
is( $ls->{min}->get_component(0), 0, "_enlarge_y >0 does not grow min[x]" );
is( $ls->{min}->get_component(1), 0, "_enlarge_y >0 does not grow min[y]" );
is( $ls->{max}->get_component(0), 0, "_enlarge_y >0 does not grow max[x]" );
is( $ls->{max}->get_component(1), 3, "_enlarge_y >0 does grow max[y]" );
$ls->_enlarge(Language::Befunge::Vector->new(4, 2, 0, 0, 0) );
is( $ls->{min}->get_component(0), 0, "_enlarge_x >0 does not grow min[x]" );
is( $ls->{min}->get_component(1), 0, "_enlarge_x >0 does not grow min[y]" );
is( $ls->{max}->get_component(0), 2, "_enlarge_x >0 does grow max[x]" );
is( $ls->{max}->get_component(1), 3, "_enlarge_x >0 does not grow max[y]" );
$ls->_enlarge(Language::Befunge::Vector->new(4, 0, -5, 0, 0) );
is( $ls->{min}->get_component(0), 0,  "_enlarge_y <0 does not grow min[x]" );
is( $ls->{min}->get_component(1), -5, "_enlarge_y <0 does grow min[y]" );
is( $ls->{max}->get_component(0), 2,  "_enlarge_y <0 does not grow max[x]" );
is( $ls->{max}->get_component(1), 3,  "_enlarge_y <0 does not grow max[y]" );
$ls->_enlarge(Language::Befunge::Vector->new(4, -4, 0, 0, 0) );
is( $ls->{min}->get_component(0), -4, "_enlarge_x <0 does grow min[x]" );
is( $ls->{min}->get_component(1), -5, "_enlarge_x <0 does not grow min[y]" );
is( $ls->{max}->get_component(0), 2,  "_enlarge_x <0 does not grow max[x]" );
is( $ls->{max}->get_component(1), 3,  "_enlarge_x <0 does not grow max[y]" );


# get/set value.
$ls->clear;
$ls->set_value(Language::Befunge::Vector->new(4, 10, 5, 0, 0), 65 );
is( $ls->{max}->get_component(0), 10, "set_value grows max[x] if needed" );
is( $ls->{max}->get_component(1), 5,  "set_value grows max[y] if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  10, 5, 0, 0)), 65, "get_value returns correct value" );
$ls->set_value(Language::Befunge::Vector->new(4,  -10, -5, 0, 0), 65 );
is( $ls->{min}->get_component(0), -10, "set_value grows min[x] if needed" );
is( $ls->{min}->get_component(1), -5,  "set_value grows min[y] if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  -10, -5, 0, 0)), 65, "get_value returns correct value" );

is( $ls->get_value(Language::Befunge::Vector->new(4,  1, 1, 0, 0)),    32, "get_value defaults to space" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  20, 20, 0, 0)),  32, "get_value out of bounds defaults to space" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  -20, -20, 0, 0)),32, "get_value out of bounds defaults to space" );

$ls->clear;
$ls->_enlarge(Language::Befunge::Vector->new(4, 0, 3, 0, 0) ); # corner cases, should not happen - but anyway.
is( $ls->get_value(Language::Befunge::Vector->new(4,  -4, 0, 0, 0)), 32, "get_value defaults to space" );
is( $ls->get_value(Language::Befunge::Vector->new(4,   4, 0, 0, 0)), 32, "get_value defaults to space" );


# input checking: make sure get_char() returns ASCII.
$ls->set_value(Language::Befunge::Vector->new(4, 0, 0, 0, 0), -1);
$ls->set_value(Language::Befunge::Vector->new(4, 1, 0, 0, 0),  0);
$ls->set_value(Language::Befunge::Vector->new(4, 0, 2, 0, 0),255);
$ls->set_value(Language::Befunge::Vector->new(4, 0, 0, 3, 0),256);
is( $ls->get_value(Language::Befunge::Vector->new(4, 0, 0, 0, 0)), -1, "set_value works");
is( $ls->get_value(Language::Befunge::Vector->new(4, 1, 0, 0, 0)),  0, "set_value works");
is( $ls->get_value(Language::Befunge::Vector->new(4, 0, 2, 0, 0)),255, "set_value works");
is( $ls->get_value(Language::Befunge::Vector->new(4, 0, 0, 3, 0)),256, "set_value works");
is( $ls->get_char(Language::Befunge::Vector->new(4, 0, 0, 0, 0)), sprintf("<np-0x%x>", -1), "get_char always returns ascii" );
is( $ls->get_char(Language::Befunge::Vector->new(4, 1, 0, 0, 0)), chr(0),       "get_chars always returns ascii" );
is( $ls->get_char(Language::Befunge::Vector->new(4, 0, 2, 0, 0)), chr(0xff),    "get_chars always returns ascii" );
is( $ls->get_char(Language::Befunge::Vector->new(4, 0, 0, 3, 0)), '<np-0x100>', "get_chars always returns ascii" );


# multi-dimensional store method.
$ls->clear;
$ls->store( <<"EOF" );
aaa
bbb
ccc
\fddd
eee
fff
\fggg
hhh
iii
\0jjj
kkk
lll
\fmmm
nnn
ooo
\fppp
qqq
rrr
\0sss
ttt
uuu
\fvvv
www
xxx
\fyyy
zzz
AAA
EOF
is( $$ls{nd}, 4, "LS::Generic has right number of dimensions");
is( $ls->get_char(Language::Befunge::Vector->new(4,  0, 0, 0, 0)), 'a', "store begins at 0" );
is( $ls->get_char(Language::Befunge::Vector->new(4,  1, 1, 1, 1)), 'n', "store handles multidim properly" );
is( $ls->get_char(Language::Befunge::Vector->new(4,  2, 2, 2, 2)), 'A', "store still handles multidim properly" );


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
is( $ls->{min}->get_component(0), 0,  "store does not grow min[x] if not needed" );
is( $ls->{min}->get_component(1), 0,  "store does not grow max[y] if not needed" );
is( $ls->{max}->get_component(0), 16, "store grows max[x] if needed" );
is( $ls->{max}->get_component(1), 1,  "store grows max[y] if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  0, 0, 0, 0)), 70, "store stores everything" );
is( $ls->get_value(Language::Befunge::Vector->new(4, 12, 0, 0, 0)), 32, "store defaults to space" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  1, 5, 0, 0)), 32, "store does not store outside of its bounds" );

$ls->store( <<'EOF', Language::Befunge::Vector->new(4, 4, 1, 0, 0) );
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
is( $ls->{min}->get_component(0), 0,  "store does not grow min[x] if not needed" );
is( $ls->{min}->get_component(1), 0,  "store does not grow min[y] if not needed" );
is( $ls->{max}->get_component(0), 20, "store grows max[x] if needed" );
is( $ls->{max}->get_component(1), 2,  "store grows max[y] if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  0, 0, 0, 0)),  70,  "store respects specified origin" ); # old values.
is( $ls->get_value(Language::Befunge::Vector->new(4,  4, 1, 0, 0)),  70,  "store overwrites if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  20, 2, 0, 0)), 121, "store stores everything" ); # last value.

($w, $h) = $ls->store( <<'EOF', Language::Befunge::Vector->new(4, -2, -1, 0, 0 ))->get_all_components;
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
is( $ls->{min}->get_component(0), -2, "store grows min[x] if needed" );
is( $ls->{min}->get_component(1), -1, "store grows min[y] if needed" );
is( $ls->{max}->get_component(0), 20, "store does not grow max[x] if not needed" );
is( $ls->{max}->get_component(1), 2,  "store does not grow max[y] if not needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  -2, -1, 0, 0)), 70,  "store stores value in negative indices" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  0, 0, 0, 0 )),  109, "store overwrites if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  4, 1, 0, 0 )),  70,  "store does not overwrite outside its rectangle" );

$ls->store( <<'EOF', Language::Befunge::Vector->new(4, -2, 0, 0, 0 ));
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
is( $ls->{min}->get_component(0), -2, "store does not grow min[x] if not needed" );
is( $ls->{min}->get_component(1), -1, "store does not grow min[y] if not needed" );
is( $ls->{max}->get_component(0), 20, "store does not grow max[x] if not needed" );
is( $ls->{max}->get_component(1), 2,  "store does not grow max[y] if not needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  -2, 0, 0, 0)), 70,  "store overwrites if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  12, 0, 0, 0 )), 32, "store overwrites with spaces if needed" );


# rectangle.
is( $ls->rectangle(Language::Befunge::Vector->new(4, -3, 4, 0, 0),Language::Befunge::Vector->new(4, 1,1, 0, 0)), " \n\f\0", "rectangle returns lines ending with \\n" );
is( $ls->rectangle(Language::Befunge::Vector->new(4, -2,-1, 0, 0),Language::Befunge::Vector->new(4, 3,2, 0, 0)), "Foo\nFoo\n\f\0", "rectangle works with multiple lines" );
is( $ls->rectangle(Language::Befunge::Vector->new(4, 19,-2, 0, 0),Language::Befunge::Vector->new(4, 2,6, 0, 0)), "  \n  \n  \n  \nfy\n  \n\f\0", "rectangle works accross origin" );


# store_binary method
$ls->clear;
my $size = $ls->store_binary( <<'EOF' );
abcde
 fghij
EOF
#   5432101234567890123456789012345678901234
#  2
#  1
#  0     abcde@ fghij
#  1
#  2
is( $ls->{min}->get_component(0), 0,  "store_binary does not grow min[x]" );
is( $ls->{min}->get_component(1), 0,  "store_binary does not grow min[y]" );
is( $ls->{max}->get_component(0), 12, "store_binary grows max[x] as needed" );
is( $ls->{max}->get_component(1), 0,  "store_binary does not grow max[y]" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  0, 0, 0, 0)),  97, "store_binary stores everything" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  0, 35,0, 0)), 32,  "store_binary does not store outside of its bounds" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  4, 0, 0, 0)), 101, "store_binary stores binary" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  5, 0, 0, 0)), 10,  "store_binary stores binary" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  6, 0, 0, 0)), 32,  "store_binary stores binary" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  7, 0, 0, 0)), 102, "store_binary stores binary" );
is( $size->get_component(0), 13, "store_binary flattens input" );
is( $size->get_component(1), 1,  "store_binary flattens input" );

$ls->store_binary( <<'EOF', Language::Befunge::Vector->new(4, 4, 1, 0, 0 ));
klmno
  pqrst
EOF
#   5432101234567890123456789012345678901234
#  2
#  1
#  0     abcde@ fghij
#  1         klmno@  pqrst
#  2
is( $ls->{min}->get_component(0), 0,  "store_binary does not grow min[x] if not needed" );
is( $ls->{min}->get_component(1), 0,  "store_binary does not grow min[y] if not needed" );
is( $ls->{max}->get_component(0), 17, "store_binary grows max[x] if needed" );
is( $ls->{max}->get_component(1), 1,  "store_binary grows max[y] if needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  0, 0, 0, 0)), 97, "store_binary respects specified origin" ); # old values.
is( $ls->get_value(Language::Befunge::Vector->new(4,  4, 1, 0, 0)), 107,"store_binary stores everything" );

$ls->store_binary( <<'EOF', Language::Befunge::Vector->new(4, -2, -1, 0, 0 ));
Foo bar baz
camel llama buffy
EOF
#   5432101234567890123456789012345678901234
#  2
#  1    Foo bar baz@camel llama buffy
#  0     abcde@ fghij
#  1         klmno@ pqrst
#  2
is( $ls->{min}->get_component(0), -2, "store_binary grows min[x] if needed" );
is( $ls->{min}->get_component(1), -1, "store_binary grows min[y] if needed" );
is( $ls->{max}->get_component(0), 27, "store_binary does not grow max[x] if not needed" );
is( $ls->{max}->get_component(1), 1,  "store_binary does not grow max[y] if not needed" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  -2, -1, 0, 0)), 70,  "store_binary stores value in negative indices" );

$ls->store_binary( <<'EOF', Language::Befunge::Vector->new(4, 0, 2, 0, 0 ));
Foo bar baz
camel llama buffy
EOF
#   5432101234567890123456789012345678901234
#  2
#  1    Foo bar baz@camel llama buffy
#  0     abFoo bar baz@camel llama buffy
#  1         klmno@ pqrst
#  2
is( $ls->get_value(Language::Befunge::Vector->new(4,  0, 0, 0, 0)), 97, "store_binary doesn't overwrite stuff to the left on the same line" );
is( $ls->get_value(Language::Befunge::Vector->new(4,  0, 2, 0, 0)), 70, "store_binary overwrites if needed" );


# move ip.
$ls->clear;   # "positive" playfield.
$ls->_enlarge(Language::Befunge::Vector->new(4, 5, 10, 1, 2));
$ip->set_position(Language::Befunge::Vector->new(4,  4, 3, 0, 0 ));
$ip->get_delta->set_component(0, 1);
$ip->get_delta->set_component(1, 0);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 5, "move_ip_forward respects dx" );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 0, "move_ip_forward wraps max[x]" );
$ip->set_position(Language::Befunge::Vector->new(4,  4, 3, 0, 0 ));
$ip->get_delta->set_component(0, 7);
$ip->get_delta->set_component(1, 0);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 4, "move_ip_forward deals with delta overflowing torus width" );
$ls->move_ip_forward( $ip ); # wrap max[x] harder
is( $ip->get_position->get_component(0), 4, "move_ip_forward deals with delta overflowing torus width" );
$ip->set_position(Language::Befunge::Vector->new(4,  0, 4, 0, 0 ));
$ip->get_delta->set_component(0, -1);
$ip->get_delta->set_component(1, 0);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 5, "move_ip_forward wraps min[x]" );

$ip->set_position(Language::Befunge::Vector->new(4,  2, 9, 0, 0 ));
$ip->get_delta->set_component(0, 0);
$ip->get_delta->set_component(1, 1);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 10, "move_ip_forward respects dy" );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 0,  "move_ip_forward wraps max[y]" );
$ip->set_position(Language::Befunge::Vector->new(4,  2, 9, 0, 0 ));
$ip->get_delta->set_component(0, 0);
$ip->get_delta->set_component(1, 12);               # apply delta that overflows torus height
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 9, "move_ip_forward deals with delta overflowing torus heigth" );
$ls->move_ip_forward( $ip ); # wrap max[y] harder
is( $ip->get_position->get_component(1), 9, "move_ip_forward deals with delta overflowing torus heigth" );
$ip->set_position(Language::Befunge::Vector->new(4,  1, 0, 0, 0 ));
$ip->get_delta->set_component(0, 0);
$ip->get_delta->set_component(1, -1);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 10, "move_ip_forward wraps min[y]" );


$ls->clear;   # "negative" playfield.
$ls->_enlarge(Language::Befunge::Vector->new(4, -1, -3, -5, -2));
$ls->_enlarge(Language::Befunge::Vector->new(4,  5, 10,  5,  2));
$ip->set_position(Language::Befunge::Vector->new(4,  4, 3, 0, 0 ));
$ip->get_delta->set_component(0, 1);
$ip->get_delta->set_component(1, 0);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 5, "move_ip_forward respects dx" );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), -1, "move_ip_forward wraps max[x]" );
$ip->set_position(Language::Befunge::Vector->new(4,  -1, 4, 0, 0 ));
$ip->get_delta->set_component(0, -1);
$ip->get_delta->set_component(1, 0);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 5, "move_ip_forward wraps min[x]" );
$ip->set_position(Language::Befunge::Vector->new(4,  2, 9, 0, 0 ));
$ip->get_delta->set_component(0, 0);
$ip->get_delta->set_component(1, 1);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 10, "move_ip_forward respects dy" );
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), -3, "move_ip_forward wraps max[y]" );
$ip->set_position(Language::Befunge::Vector->new(4,  1, -3, 0, 0 ));
$ip->get_delta->set_component(0, 0);
$ip->get_delta->set_component(1, -1);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(1), 10, "move_ip_forward wraps min[y]" );

$ls->clear;   # diagonals.
$ls->_enlarge(Language::Befunge::Vector->new(4, -1, -2, 0, 0));
$ls->_enlarge(Language::Befunge::Vector->new(4,  6,  5, 0, 0));
$ip->set_position(Language::Befunge::Vector->new(4, 0, 0, 0, 0));
$ip->get_delta->set_component(0,-2);
$ip->get_delta->set_component(1,-3);
$ls->move_ip_forward( $ip );
is( $ip->get_position->get_component(0), 2, "move_ip_forward deals with diagonals" );
is( $ip->get_position->get_component(1), 3, "move_ip_forward deals with diagonals" );


# label lookup
# four directions.
$ls->clear;
$ls->store( <<'EOF', Language::Befunge::Vector->new(4, -2, -1, 0, 0 ));
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
is( $href->{foo}[0]->get_component(0), 10,  "labels_lookup finds left-right" );
is( $href->{foo}[0]->get_component(1), 5,   "labels_lookup finds left-right" );
is( $href->{foo}[1]->get_component(0), 1,   "labels_lookup deals with left-right" );
is( $href->{foo}[1]->get_component(1), 0,   "labels_lookup deals with left-right" );
is( $href->{bar}[0]->get_component(0), -2,  "labels_lookup finds right-left" );
is( $href->{bar}[0]->get_component(1), 5,   "labels_lookup finds right-left" );
is( $href->{bar}[1]->get_component(0), -1,  "labels_lookup deals with right-left" );
is( $href->{bar}[1]->get_component(1), 0,   "labels_lookup deals with right-left" );
is( $href->{baz}[0]->get_component(0), 4,   "labels_lookup finds bottom-top" );
is( $href->{baz}[0]->get_component(1), -1,  "labels_lookup finds bottom-top" );
is( $href->{baz}[1]->get_component(0), 0,   "labels_lookup deals with bottom-top" );
is( $href->{baz}[1]->get_component(1), -1,  "labels_lookup deals with bottom-top" );
is( $href->{blah}[0]->get_component(0), 4,  "labels_lookup finds top-bottom" );
is( $href->{blah}[0]->get_component(1), 12, "labels_lookup finds top-bottom" );
is( $href->{blah}[1]->get_component(0), 0,  "labels_lookup deals with top-bottom" );
is( $href->{blah}[1]->get_component(1), 1,  "labels_lookup deals with top-bottom" );


# wrapping...
$ls->clear;
$ls->store( <<'EOF', Language::Befunge::Vector->new(4, -2, -1, 0, 0 ));
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
is( $href->{foo}[0]->get_component(0), -1, "labels_lookup finds left-right" );
is( $href->{foo}[0]->get_component(1), -1, "labels_lookup finds left-right" );
is( $href->{foo}[1]->get_component(0), 1,  "labels_lookup deals with left-right" );
is( $href->{foo}[1]->get_component(1), 0,  "labels_lookup deals with left-right" );
is( $href->{bar}[0]->get_component(0), 16, "labels_lookup finds right-left" );
is( $href->{bar}[0]->get_component(1), 0,  "labels_lookup finds right-left" );
is( $href->{bar}[1]->get_component(0), -1, "labels_lookup deals with right-left" );
is( $href->{bar}[1]->get_component(1), 0,  "labels_lookup deals with right-left" );
is( $href->{baz}[0]->get_component(0), 6,  "labels_lookup finds bottom-top" );
is( $href->{baz}[0]->get_component(1), 6,  "labels_lookup finds bottom-top" );
is( $href->{baz}[1]->get_component(0), 0,  "labels_lookup deals with bottom-top" );
is( $href->{baz}[1]->get_component(1), -1, "labels_lookup deals with bottom-top" );
is( $href->{blah}[0]->get_component(0), 9, "labels_lookup finds top-bottom" );
is( $href->{blah}[0]->get_component(1), 0, "labels_lookup finds top-bottom" );
is( $href->{blah}[1]->get_component(0), 0, "labels_lookup deals with top-bottom" );
is( $href->{blah}[1]->get_component(1), 1, "labels_lookup deals with top-bottom" );


# garbage...
$ls->clear;
$ls->store( <<'EOF', Language::Befunge::Vector->new(4, -2, -1, 0, 0 ));
   ;:foo is foo;1
     ;not a label;
EOF
$href = $ls->labels_lookup;
is( scalar(keys(%$href)), 1, "labels_lookup does not looks-alike non-labels" );
is( $href->{foo}[0]->get_component(0), 14, "labels_lookup discards comments" );
is( $href->{foo}[0]->get_component(1), -1, "labels_lookup discards comments" );
is( $href->{foo}[1]->get_component(0), 1,  "labels_lookup discards comments" );
is( $href->{foo}[1]->get_component(1), 0,  "labels_lookup discards comments" );


# double define...
$ls->clear;
$ls->store( <<'EOF', Language::Befunge::Vector->new(4, -2, -1, 0, 0 ));
   ;:foo is foo;1
   2;another oof:;
EOF
eval { $href = $ls->labels_lookup; };
like( $@, qr/^Help! I found two labels 'foo' in the funge space/,
      "labels_lookup chokes on double-defined labels" );

