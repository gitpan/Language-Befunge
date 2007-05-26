#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#--------------------------------#
#          The numbers.          #
#--------------------------------#

use strict;
use Language::Befunge;
use POSIX qw! tmpnam !;
use Test;

# Vars.
my $file;
my $fh;
my $tests;
my $out;
my $bef = Language::Befunge->new;
BEGIN { $tests = 0 };

# In order to see what happens...
sub sel () {
    $file = tmpnam();
    open OUT, ">$file" or die $!;
    $fh = select OUT;
}
sub slurp () {
    select $fh;
    close OUT;
    open OUT, "<$file" or die $!;
    my $content;
    {
        local $/;
        $content = <OUT>;
    }
    close OUT;
    unlink $file;
    return $content;
}

# empty stack.
sel;
$bef->store_code( <<'END_OF_CODE' );
,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(0) );
sel;
$bef->store_code( <<'END_OF_CODE' );
.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
BEGIN { $tests += 2 };

# zero.
sel;
$bef->store_code( <<'END_OF_CODE' );
0,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(0) );
sel;
$bef->store_code( <<'END_OF_CODE' );
0.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
BEGIN { $tests += 2 };

# one.
sel;
$bef->store_code( <<'END_OF_CODE' );
1,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(1) );
sel;
$bef->store_code( <<'END_OF_CODE' );
1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 2 };

# two.
sel;
$bef->store_code( <<'END_OF_CODE' );
2,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(2) );
sel;
$bef->store_code( <<'END_OF_CODE' );
2.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "2 " );
BEGIN { $tests += 2 };

# three.
sel;
$bef->store_code( <<'END_OF_CODE' );
3,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(3) );
sel;
$bef->store_code( <<'END_OF_CODE' );
3.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 " );
BEGIN { $tests += 2 };

# four.
sel;
$bef->store_code( <<'END_OF_CODE' );
4,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(4) );
sel;
$bef->store_code( <<'END_OF_CODE' );
4.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "4 " );
BEGIN { $tests += 2 };

# five.
sel;
$bef->store_code( <<'END_OF_CODE' );
5,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(5) );
sel;
$bef->store_code( <<'END_OF_CODE' );
5.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "5 " );
BEGIN { $tests += 2 };

# six.
sel;
$bef->store_code( <<'END_OF_CODE' );
6,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(6) );
sel;
$bef->store_code( <<'END_OF_CODE' );
6.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "6 " );
BEGIN { $tests += 2 };

# seven.
sel;
$bef->store_code( <<'END_OF_CODE' );
7,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(7) );
sel;
$bef->store_code( <<'END_OF_CODE' );
7.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "7 " );
BEGIN { $tests += 2 };

# height.
sel;
$bef->store_code( <<'END_OF_CODE' );
8,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(8) );
sel;
$bef->store_code( <<'END_OF_CODE' );
8.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "8 " );
BEGIN { $tests += 2 };

# nine.
sel;
$bef->store_code( <<'END_OF_CODE' );
9,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(9) );
sel;
$bef->store_code( <<'END_OF_CODE' );
9.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "9 " );
BEGIN { $tests += 2 };

# ten.
sel;
$bef->store_code( <<'END_OF_CODE' );
a,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(10) );
sel;
$bef->store_code( <<'END_OF_CODE' );
a.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "10 " );
BEGIN { $tests += 2 };

# eleven.
sel;
$bef->store_code( <<'END_OF_CODE' );
b,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(11) );
sel;
$bef->store_code( <<'END_OF_CODE' );
b.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "11 " );
BEGIN { $tests += 2 };

# twelve.
sel;
$bef->store_code( <<'END_OF_CODE' );
c,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(12) );
sel;
$bef->store_code( <<'END_OF_CODE' );
c.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "12 " );
BEGIN { $tests += 2 };

# thirteen.
sel;
$bef->store_code( <<'END_OF_CODE' );
d,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(13) );
sel;
$bef->store_code( <<'END_OF_CODE' );
d.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "13 " );
BEGIN { $tests += 2 };

# fourteen.
sel;
$bef->store_code( <<'END_OF_CODE' );
e,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(14) );
sel;
$bef->store_code( <<'END_OF_CODE' );
e.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "14 " );
BEGIN { $tests += 2 };

# fifteen.
sel;
$bef->store_code( <<'END_OF_CODE' );
f,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, chr(15) );
sel;
$bef->store_code( <<'END_OF_CODE' );
f.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "15 " );
BEGIN { $tests += 2 };


BEGIN { plan tests => $tests };

