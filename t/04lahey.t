#-*- cperl -*-
# $Id: 04lahey.t,v 1.6 2002/04/11 12:50:06 jquelin Exp $
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
BEGIN { $tests = 0 };

# Constructor.
my $ls = new Language::Befunge::LaheySpace;
ok( ref($ls), "Language::Befunge::LaheySpace");
BEGIN { $tests += 1 };


# Test accessors.
$ls->xmin( -1 );
$ls->ymin( -2 );
ok( $ls->xmin, -1 );
ok( $ls->ymin, -2 );
$ls->xmax( 10 );
$ls->ymax( 20 );
ok( $ls->xmax, 10 );
ok( $ls->ymax, 20 );
BEGIN { $tests += 4; }

# Clear method.
$ls->clear;
ok( $ls->xmin, 0 );
ok( $ls->ymin, 0 );
ok( $ls->xmax, 0 );
ok( $ls->ymax, 0 );
BEGIN { $tests += 4; }

# set_min/set_max methods.
$ls->clear;
$ls->set_min( -2, -3 );
ok( $ls->xmin, -2 );
ok( $ls->ymin, -3 );
$ls->set_min( -1, -1 ); # Can't shrink.
ok( $ls->xmin, -2 );
ok( $ls->ymin, -3 );
$ls->set_max( 4, 5 );
ok( $ls->xmax, 4 );
ok( $ls->ymax, 5 );
$ls->set_min( 2, 3 ); # Can't shrink.
ok( $ls->xmax, 4 );
ok( $ls->ymax, 5 );
BEGIN{ $tests += 8; }


# Enlarge torus.
$ls->clear;
$ls->enlarge_y( 3 );
ok( $ls->xmin, 0 );
ok( $ls->ymin, 0 );
ok( $ls->xmax, 0 );
ok( $ls->ymax, 3 );
$ls->enlarge_x( 2 );
ok( $ls->xmin, 0 );
ok( $ls->ymin, 0 );
ok( $ls->xmax, 2 );
ok( $ls->ymax, 3 );
$ls->enlarge_y( -5 );
ok( $ls->xmin, 0 );
ok( $ls->ymin, -5 );
ok( $ls->xmax, 2 );
ok( $ls->ymax, 3 );
$ls->enlarge_x( -4 );
ok( $ls->xmin, -4 );
ok( $ls->ymin, -5 );
ok( $ls->xmax, 2 );
ok( $ls->ymax, 3 );
BEGIN { $tests += 16; }

# Get/Set value.
$ls->clear;
$ls->set_value( 10, 5, 65 );
ok( $ls->xmin, 0 );
ok( $ls->ymin, 0 );
ok( $ls->xmax, 10 );
ok( $ls->ymax, 5 );
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
ok( $ls->xmin, 0 );
ok( $ls->ymin, 0 );
ok( $ls->xmax, 16 );
ok( $ls->ymax, 1 );
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
ok( $ls->xmin, 0 );
ok( $ls->ymin, 0 );
ok( $ls->xmax, 20 );
ok( $ls->ymax, 2 );
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
ok( $ls->xmin, -2 );
ok( $ls->ymin, -1 );
ok( $ls->xmax, 20 );
ok( $ls->ymax, 2 );
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
ok( $ls->xmin, -2 );
ok( $ls->ymin, -1 );
ok( $ls->xmax, 20 );
ok( $ls->ymax, 2 );
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
$ip->set_pos( 1, 0 );
$ip->dx( 0 );
$ip->dy( -1 );
$ls->move_ip_forward( $ip ); # wrap ymin
ok( $ip->cury, 10 );
BEGIN { $tests += 6 }
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
ok( $ip->curx, 6 );
ok( $ip->cury, 5 );
BEGIN { $tests += 2; }

BEGIN { plan tests => $tests };


