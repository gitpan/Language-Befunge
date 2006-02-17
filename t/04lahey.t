#-*- cperl -*-
# $Id: 04lahey.t,v 1.6 2006/02/14 15:44:47 jquelin Exp $
#

#------------------------------------------#
#          The LaheySpace module.          #
#------------------------------------------#

use strict;
use Test;
use Language::Befunge::IP;
use Language::Befunge::LaheySpace;

my $tests;
my $ip = new Language::Befunge::IP;
my $href;
BEGIN { $tests = 0 };

# Constructor.
my $ls = new Language::Befunge::LaheySpace;
ok( ref($ls), "Language::Befunge::LaheySpace");
BEGIN { $tests += 1 };


# Clear method.
$ls->clear;
ok( $ls->{xmin}, 0 );
ok( $ls->{ymin}, 0 );
ok( $ls->{xmax}, 0 );
ok( $ls->{ymax}, 0 );
BEGIN { $tests += 4; }

# set_min/set_max methods.
$ls->clear;
$ls->set_min( -2, -3 );
ok( $ls->{xmin}, -2 );
ok( $ls->{ymin}, -3 );
$ls->set_min( -1, -1 ); # Can't shrink.
ok( $ls->{xmin}, -2 );
ok( $ls->{ymin}, -3 );
$ls->set_max( 4, 5 );
ok( $ls->{xmax}, 4 );
ok( $ls->{ymax}, 5 );
$ls->set_min( 2, 3 ); # Can't shrink.
ok( $ls->{xmax}, 4 );
ok( $ls->{ymax}, 5 );
BEGIN{ $tests += 8; }

# out_of_bounds method.
ok($ls->out_of_bounds(-5, -5), 1);
ok($ls->out_of_bounds( 5, -5), 1);
ok($ls->out_of_bounds(-5,  5), 1);
ok($ls->out_of_bounds( 5,  5), 1);
ok($ls->out_of_bounds( 0,  0), 0);
BEGIN{ $tests += 5; }

# Enlarge torus.
$ls->clear;
$ls->enlarge_y( 3 );
ok( $ls->{xmin}, 0 );
ok( $ls->{ymin}, 0 );
ok( $ls->{xmax}, 0 );
ok( $ls->{ymax}, 3 );
$ls->enlarge_x( 2 );
ok( $ls->{xmin}, 0 );
ok( $ls->{ymin}, 0 );
ok( $ls->{xmax}, 2 );
ok( $ls->{ymax}, 3 );
$ls->enlarge_y( -5 );
ok( $ls->{xmin}, 0 );
ok( $ls->{ymin}, -5 );
ok( $ls->{xmax}, 2 );
ok( $ls->{ymax}, 3 );
$ls->enlarge_x( -4 );
ok( $ls->{xmin}, -4 );
ok( $ls->{ymin}, -5 );
ok( $ls->{xmax}, 2 );
ok( $ls->{ymax}, 3 );
BEGIN { $tests += 16; }

# Get/Set value.
$ls->clear;
$ls->set_value( 10, 5, 65 );
ok( $ls->{xmin}, 0 );
ok( $ls->{ymin}, 0 );
ok( $ls->{xmax}, 10 );
ok( $ls->{ymax}, 5 );
ok( $ls->get_value( 10, 5 ), 65 );
ok( $ls->get_value( 1, 1),   32 ); # default to space.
ok( $ls->get_value( 20, 20), 32 ); # out of bounds.
BEGIN { $tests += 7; }

# Store method.
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
ok( $ls->{xmin}, 0 );
ok( $ls->{ymin}, 0 );
ok( $ls->{xmax}, 16 );
ok( $ls->{ymax}, 1 );
ok( $ls->get_value( 0, 0),  70 );
ok( $ls->get_value( 12, 0), 32 ); # default to space.
ok( $ls->get_value( 1, 5),  32 ); # out of bounds.
BEGIN { $tests += 7; }
$ls->store( <<'EOF', 4, 1 );
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
ok( $ls->{xmin}, 0 );
ok( $ls->{ymin}, 0 );
ok( $ls->{xmax}, 20 );
ok( $ls->{ymax}, 2 );
ok( $ls->get_value( 0, 0),  70  ); # old values.
ok( $ls->get_value( 4, 1),  70  ); # overwritten.
ok( $ls->get_value( 20, 2), 121 ); # last value.
BEGIN { $tests += 7; }
my ($w, $h) = $ls->store( <<'EOF', -2, -1 );
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
ok( $w, 17 );
ok( $h, 2 );
ok( $ls->{xmin}, -2 );
ok( $ls->{ymin}, -1 );
ok( $ls->{xmax}, 20 );
ok( $ls->{ymax}, 2 );
ok( $ls->get_value( -2, -1), 70  ); # new values.
ok( $ls->get_value( 0, 0 ),  109 ); # overwritten.
ok( $ls->get_value( 4, 1 ),  70  ); # old value.
BEGIN { $tests += 9; }
$ls->store( <<'EOF', -2, 0 );
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
ok( $ls->{xmin}, -2 );
ok( $ls->{ymin}, -1 );
ok( $ls->{xmax}, 20 );
ok( $ls->{ymax}, 2 );
ok( $ls->get_value( -2, 0), 70  ); # new values.
ok( $ls->get_value( 12, 0 ), 32 ); # overwritten space.
BEGIN { $tests += 6; }

# Rectangle.
ok( $ls->rectangle(-2,-1,3,2), "Foo\nFoo\n" );
ok( $ls->rectangle(-3,4,1,1), " \n" );
ok( $ls->rectangle(19,-2,2,6), "  \n  \n  \n  \nfy\n  \n" );
BEGIN { $tests += 3; }


# Move IP.
$ls->clear;   # "positive" playfield.
$ls->set_max(5, 10);
$ip->set_pos( 4, 3 );
$ip->dx( 1 );
$ip->dy( 0 );
$ls->move_ip_forward( $ip );
ok( $ip->curx, 5 );
$ls->move_ip_forward( $ip ); # wrap xmax
ok( $ip->curx, 0 );
$ip->set_pos( 4, 3 );
$ip->dx( 7 );                # apply delta that overflows torus width
$ip->dy( 0 );
$ls->move_ip_forward( $ip );
ok( $ip->curx, 4 );
$ls->move_ip_forward( $ip ); # wrap xmax harder
ok( $ip->curx, 4 );
$ip->set_pos( 0, 4 );
$ip->dx( -1 );
$ip->dy( 0 );
$ls->move_ip_forward( $ip ); # wrap xmin
ok( $ip->curx, 5 );
$ip->set_pos( 2, 9 );
$ip->dx( 0 );
$ip->dy( 1 );
$ls->move_ip_forward( $ip );
ok( $ip->cury, 10 );
$ls->move_ip_forward( $ip ); # wrap ymax
ok( $ip->cury, 0 );
$ip->set_pos( 2, 9 );
$ip->dx( 0 );
$ip->dy( 12 );               # apply delta that overflows torus height
$ls->move_ip_forward( $ip );
ok( $ip->cury, 9 );
$ls->move_ip_forward( $ip ); # wrap ymax harder
ok( $ip->cury, 9 );
$ip->set_pos( 1, 0 );
$ip->dx( 0 );
$ip->dy( -1 );
$ls->move_ip_forward( $ip ); # wrap ymin
ok( $ip->cury, 10 );
BEGIN { $tests += 10 }
$ls->clear;   # "negative" playfield.
$ls->set_min(-1, -3);
$ls->set_max(5, 10);
$ip->set_pos( 4, 3 );
$ip->dx( 1 );
$ip->dy( 0 );
$ls->move_ip_forward( $ip );
ok( $ip->curx, 5 );
$ls->move_ip_forward( $ip ); # wrap xmax
ok( $ip->curx, -1 );
$ip->set_pos( -1, 4 );
$ip->dx( -1 );
$ip->dy( 0 );
$ls->move_ip_forward( $ip ); # wrap xmin
ok( $ip->curx, 5 );
$ip->set_pos( 2, 9 );
$ip->dx( 0 );
$ip->dy( 1 );
$ls->move_ip_forward( $ip );
ok( $ip->cury, 10 );
$ls->move_ip_forward( $ip ); # wrap ymax
ok( $ip->cury, -3 );
$ip->set_pos( 1, -3 );
$ip->dx( 0 );
$ip->dy( -1 );
$ls->move_ip_forward( $ip ); # wrap ymin
ok( $ip->cury, 10 );
BEGIN { $tests += 6; }
$ls->clear;   # diagonals.
$ls->set_min(-1, -2);
$ls->set_max(6, 5);
$ip->set_pos(0, 0);
$ip->dx(-2);
$ip->dy(-3);
$ls->move_ip_forward( $ip );
ok( $ip->curx, 2 );
ok( $ip->cury, 3 );
BEGIN { $tests += 2; }

# Label lookup
# four directions.
$ls->clear;
$ls->store( <<'EOF', -2, -1 );
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
ok( scalar(keys(%$href)), 4 );
ok( $href->{foo}[0], 10 );
ok( $href->{foo}[1], 5 );
ok( $href->{foo}[2], 1 );
ok( $href->{foo}[3], 0 );
ok( $href->{bar}[0], -2 );
ok( $href->{bar}[1], 5 );
ok( $href->{bar}[2], -1 );
ok( $href->{bar}[3], 0 );
ok( $href->{baz}[0], 4 );
ok( $href->{baz}[1], -1 );
ok( $href->{baz}[2], 0 );
ok( $href->{baz}[3], -1 );
ok( $href->{blah}[0], 4 );
ok( $href->{blah}[1], 12 );
ok( $href->{blah}[2], 0 );
ok( $href->{blah}[3], 1 );
BEGIN { $tests += 17 };
# wrapping...
$ls->clear;
$ls->store( <<'EOF', -2, -1 );
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
ok( scalar(keys(%$href)), 4 );
ok( $href->{foo}[0], -1 );
ok( $href->{foo}[1], -1 );
ok( $href->{foo}[2], 1 );
ok( $href->{foo}[3], 0 );
ok( $href->{bar}[0], 16 );
ok( $href->{bar}[1], 0 );
ok( $href->{bar}[2], -1 );
ok( $href->{bar}[3], 0 );
ok( $href->{baz}[0], 6 );
ok( $href->{baz}[1], 6 );
ok( $href->{baz}[2], 0 );
ok( $href->{baz}[3], -1 );
ok( $href->{blah}[0], 9 );
ok( $href->{blah}[1], 0 );
ok( $href->{blah}[2], 0 );
ok( $href->{blah}[3], 1 );
BEGIN { $tests += 17 };
# garbage...
$ls->clear;
$ls->store( <<'EOF', -2, -1 );
   ;:foo is foo;1  
     ;not a label;
EOF
$href = $ls->labels_lookup;
ok( scalar(keys(%$href)), 1 );
ok( $href->{foo}[0], 14 );
ok( $href->{foo}[1], -1 );
ok( $href->{foo}[2], 1 );
ok( $href->{foo}[3], 0 );
BEGIN { $tests += 5 };
# double define...
$ls->clear;
$ls->store( <<'EOF', -2, -1 );
   ;:foo is foo;1  
   2;another oof:;
EOF
eval { $href = $ls->labels_lookup; };
ok( $@, qr/^Help! I found two labels 'foo' in the funge space/ );
BEGIN { $tests += 1 };

# input checking: make sure get_char() returns ASCII.
$ls->set_value(0,0, -1);
$ls->set_value(1,0,  0);
$ls->set_value(2,0,255);
$ls->set_value(3,0,256);
ok ( $ls->get_char(0,0), sprintf("<np-0x%x>", -1) );
ok ( $ls->get_char(1,0), chr(0) );
ok ( $ls->get_char(2,0), chr(0xff) );
ok ( $ls->get_char(3,0), '<np-0x100>' );
BEGIN { $tests += 4 };

BEGIN { plan tests => $tests };
