#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#--------------------------------------#
#          The Vector module.          #
#--------------------------------------#

use strict;
use Test::More;
use Language::Befunge::IP;
use Language::Befunge::Vector;
BEGIN { use_ok ('Test::Exception') };
my $test_exception_loaded = defined($Test::Exception::VERSION);

my $tests;
my $ip = Language::Befunge::IP->new;
BEGIN { $tests = 0 };


# CONSTRUCTORS
# ->new()
my $v1 = Language::Befunge::Vector->new(3, 2, 1, 0);
isa_ok( $v1,                         "Language::Befunge::Vector");
is($v1->get_dims,                  3,         "three dimensions");
is($v1->get_component(0),          2,         "X is correct");
is($v1->get_component(1),          1,         "Y is correct");
is($v1->get_component(2),          0,         "Z is correct");
is($v1->vector_as_string, '(2,1,0)', "stringifies back to (2,1,0)");
is("$v1",                 '(2,1,0)', "overloaded stringify back to (2,1,0)");
BEGIN { $tests += 7 };

# ->new_zeroes()
$v1 = Language::Befunge::Vector->new_zeroes(4);
isa_ok( $v1,              "Language::Befunge::Vector");
is($v1->get_dims, 4,      "four dimensions");
is("$v1",    '(0,0,0,0)', "all values are 0");
BEGIN { $tests += 3 };


# METHODS

# get_dims() has already been tested above...

# vector_invert
   $v1 = Language::Befunge::Vector->new(2, 5, 6);
my $v2 = -$v1;
my $v3 = $v1->vector_invert();
is($v1->get_component(0), 5,  "X hasn't changed in v1");
is($v1->get_component(1), 6,  "Y hasn't changed in v1");
is($v2->get_component(0), -5, "X is the inverse of v1's");
is($v2->get_component(1), -6, "Y is the inverse of v1's");
is($v3->get_component(0), -5, "X is the inverse of v1's");
is($v3->get_component(1), -6, "Y is the inverse of v1's");
BEGIN { $tests += 6 };

# vector_add
my $v4 = Language::Befunge::Vector->new(2, 1, 1);
$v2 = $v1 + $v4;
$v3 = $v1->vector_add($v4);
is($v1->get_component(0), 5, "X hasn't changed in v1");
is($v1->get_component(1), 6, "Y hasn't changed in v1");
is($v4->get_component(0), 1, "X hasn't changed in v4");
is($v4->get_component(1), 1, "Y hasn't changed in v4");
is($v2->get_component(0), 6, "X is v1's X plus v4's X");
is($v2->get_component(1), 7, "Y is v1's Y plus v4's Y");
is($v3->get_component(0), 6, "X is v1's X plus v4's X");
is($v3->get_component(1), 7, "Y is v1's Y plus v4's Y");
BEGIN { $tests += 8 };

# vector_add_inplace
$v2 = $v1->vector_copy();
$v1 += $v4;
$v2->vector_add_inplace($v4);
is($v1->get_component(0), 6, "X has had 1 added in v1");
is($v1->get_component(1), 7, "Y has had 1 added in v1");
is($v2->get_component(0), 6, "X has had 1 added in v2");
is($v2->get_component(1), 7, "Y has had 1 added in v2");
is($v4->get_component(0), 1, "X hasn't changed in v4");
is($v4->get_component(1), 1, "Y hasn't changed in v4");
BEGIN { $tests += 6 };

# vector_copy
$v2 = $v1->vector_copy();
$v3 = $v1;
is($v1->get_component(0), $v2->get_component(0), "X has been copied");
is($v1->get_component(1), $v2->get_component(1), "Y has been copied");
$v1 += $v4;
is($v1->get_component(0), 7, "X has had 1 added in v1");
is($v1->get_component(1), 8, "Y has had 1 added in v1");
is($v2->get_component(0), 6, "X hasn't changed in v2");
is($v2->get_component(1), 7, "Y hasn't changed in v2");
is($v3->get_component(0), 6, "X hasn't changed in v3");
is($v3->get_component(1), 7, "Y hasn't changed in v3");
BEGIN { $tests += 8 };

# setd
$v1->set_component(0,1);
$v1->set_component(1,2);
is($v1->get_component(0),          1, "X is now 1");
is($v1->get_component(1),          2, "Y is now 2");
is($v1->vector_as_string, "(1,2)", "setd works");
BEGIN { $tests += 3 };

# getd is tested all over this script.

# get_all_components
my @list = $v1->get_all_components;
is(scalar @list, 2, "get_all_components returned 2 elements");
is($list[0], 1, "X is 1");
is($list[1], 2, "Y is 2");
BEGIN { $tests += 3 };

# zero
$v1->zero();
is($v1->get_component(0), 0, "X is now 0");
is($v1->get_component(1), 0, "Y is now 0");
BEGIN { $tests += 2 };

# bounds_check
$v1 = Language::Befunge::Vector->new(2, -1, -1);
$v2 = Language::Befunge::Vector->new(2,  2,  2);
$v3 = Language::Befunge::Vector->new(2, -1, -2);
ok(!$v3->bounds_check($v1, $v2), "(-1,-2) is out of bounds");
$v3 = Language::Befunge::Vector->new(2,  0, -1);
ok( $v3->bounds_check($v1, $v2), "(0,-1) is within bounds");
$v3 = Language::Befunge::Vector->new(2,  2, 2);
ok( $v3->bounds_check($v1, $v2), "(2,2) is within bounds");
$v3 = Language::Befunge::Vector->new(2,  3, 2);
ok(!$v3->bounds_check($v1, $v2), "(3,2) is out of bounds");
$v3 = Language::Befunge::Vector->new(2,  -1, -1);
ok( $v3->bounds_check($v1, $v2), "(-1,-1) is within bounds");
$v3 = Language::Befunge::Vector->new(2,  23, 0);
ok(!$v3->bounds_check($v1, $v2), "(23,0) is out of bounds");
$v3 = Language::Befunge::Vector->new(2,  0, 23);
ok(!$v3->bounds_check($v1, $v2), "(0,23) is out of bounds");
BEGIN { $tests += 7 };

# vector_as_string is already tested, above

# vector_equality
$v1 = Language::Befunge::Vector->new(2, 1, 1);
$v2 = Language::Befunge::Vector->new(2, 1, 1);
$v3 = Language::Befunge::Vector->new(2, 1, 2);
ok(  $v1 == $v2 , "v1 == v2");
ok(  $v2 == $v1 , "v2 == v1");
ok(  $v1 == $v1 , "v1 == v1");
ok(!($v1 == $v3), "!(v1 == v3)");
ok(!($v2 == $v3), "!(v2 == v3)");
ok(  $v1->vector_equality($v2) , "v1 == v2");
ok(  $v2->vector_equality($v1) , "v2 == v1");
ok(  $v1->vector_equality($v1) , "v1 == v1");
ok(!($v1->vector_equality($v3)), "!(v1 == v3)");
ok(!($v2->vector_equality($v3)), "!(v2 == v3)");
BEGIN { $tests += 10 };

# vector_inequality
$v1 = Language::Befunge::Vector->new(2, 1, 1);
$v2 = Language::Befunge::Vector->new(2, 1, 1);
$v3 = Language::Befunge::Vector->new(2, 1, 2);
ok(!($v1 != $v2), "!(v1 != v2)");
ok(!($v2 != $v1), "!(v2 != v1)");
ok(!($v1 != $v1), "!(v1 != v1)");
ok( ($v1 != $v3), "v1 != v3");
ok( ($v2 != $v3), "v2 != v3");
ok(!($v1->vector_inequality($v2)), "!(v1 != v2)");
ok(!($v2->vector_inequality($v1)), "!(v2 != v1)");
ok(!($v1->vector_inequality($v1)), "!(v1 != v1)");
ok( ($v1->vector_inequality($v3)), "v1 != v3");
ok( ($v2->vector_inequality($v3)), "v2 != v3");
BEGIN { $tests += 10 };

# finally, test all the possible ways to die
SKIP: {
	skip 'need Test::Exception', 18 unless $test_exception_loaded;
	# new
	throws_ok(sub { Language::Befunge::Vector->new() },
		qr/Usage/, "Vector->new needs a defined 'dimensions' argument");
	throws_ok(sub { Language::Befunge::Vector->new(0) },
		qr/Usage/, "Vector->new needs a non-zero 'dimensions' argument");
	throws_ok(sub { Language::Befunge::Vector->new(1) },
		qr/Usage/, "Vector->new checks the number of args it got");
	throws_ok(sub { Language::Befunge::Vector->new(1, 2, 3) },
		qr/Usage/, "Vector->new checks the number of args it got");
	# new_zeroes
	throws_ok(sub { Language::Befunge::Vector->new_zeroes() },
		qr/Usage/, "Vector->new_zeroes needs a defined 'dimensions' argument");
	throws_ok(sub { Language::Befunge::Vector->new_zeroes(0) },
		qr/Usage/, "Vector->new_zeroes needs a non-zero 'dimensions' argument");
	my $tref_v = Language::Befunge::Vector->new(3, 4, 5, 6);
	my  $bef_v = Language::Befunge::Vector->new(2, 3, 4);
	# vector_subtract
	throws_ok(sub { my $blah = $tref_v - $bef_v },
		qr/uneven dimensions/, "misaligned vector arithmetic (-)");
	# vector_add
	throws_ok(sub { my $blah = $tref_v + $bef_v },
		qr/uneven dimensions/, "misaligned vector arithmetic (+)");
	# vector_add_inplace
	throws_ok(sub { $tref_v += $bef_v },
		qr/uneven dimensions/, "misaligned vector arithmetic (+=)");
	# setd
	throws_ok(sub { $tref_v->set_component(3, 0) },
		qr/No such dimension/, "setd takes dimension range 0..2 for 3d");
	throws_ok(sub { $bef_v->set_component(-1, 0) },
		qr/No such dimension/, "setd takes dimension range 0..1 for 2d");
	# getd
	throws_ok(sub { $tref_v->get_component(3) },
		qr/No such dimension/, "getd takes dimension range 0..2 for 3d");
	throws_ok(sub { $bef_v->get_component(-1) },
		qr/No such dimension/, "getd takes dimension range 0..1 for 2d");
	# bounds_check
	throws_ok(sub { $tref_v->bounds_check($v1, $v2) },
		qr/uneven dimensions/, "bounds check catches wrong dimension in first arg");
	throws_ok(sub { $v1->bounds_check($tref_v, $v2) },
		qr/uneven dimensions/, "bounds check catches wrong dimension in second arg");
	throws_ok(sub { $v1->bounds_check($v2, $tref_v) },
		qr/uneven dimensions/, "bounds check catches wrong dimension in third arg");
	# vector_equality
	throws_ok(sub { $tref_v == $bef_v },
		qr/uneven dimensions/, "misaligned vector arithmetic (==)");
	# vector_inequality
	throws_ok(sub { $tref_v != $bef_v },
		qr/uneven dimensions/, "misaligned vector arithmetic (!=)");
}
BEGIN { $tests += 18 };





BEGIN { plan tests => $tests };
