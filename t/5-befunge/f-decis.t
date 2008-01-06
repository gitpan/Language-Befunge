#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#-------------------------------------------------#
#          Decision making instructions.          #
#-------------------------------------------------#

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

# Logical not.
sel; # true.
$bef->store_code( <<'END_OF_CODE' );
a!.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
sel; # negative.
$bef->store_code( <<'END_OF_CODE' );
05-!.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
sel; # false.
$bef->store_code( <<'END_OF_CODE' );
0!.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 3 };

# Comparison.
sel; # greater.
$bef->store_code( <<'END_OF_CODE' );
53`.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # equal.
$bef->store_code( <<'END_OF_CODE' );
55`.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
sel; # smaller.
$bef->store_code( <<'END_OF_CODE' );
35`.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
BEGIN { $tests += 3 };

# Horizontal if.
sel; # left from north.
$bef->store_code( <<'END_OF_CODE' );
1    v
 q.3 _ 4.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 " );
sel; # right from north
$bef->store_code( <<'END_OF_CODE' );
0    v
 q.3 _ 4.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "4 " );
sel; # left from south.
$bef->store_code( <<'END_OF_CODE' );
1    ^
 q.3 _ 4.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 " );
sel; # right from south
$bef->store_code( <<'END_OF_CODE' );
0    ^
 q.3 _ 4.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "4 " );
BEGIN { $tests += 4 };

# Vertical if.
sel; # north from left.
$bef->store_code( <<'END_OF_CODE' );
1 v   >3.q
  >   |
      >4.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 " );
sel; # south from left.
$bef->store_code( <<'END_OF_CODE' );
0 v   >3.q
  >   |
      >4.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "4 " );
sel; # north from right.
$bef->store_code( <<'END_OF_CODE' );
1 v   >3.q
  <   |
      >4.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 " );
sel; # south from right.
$bef->store_code( <<'END_OF_CODE' );
0 v   >3.q
  <   |
      >4.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "4 " );
BEGIN { $tests += 4 };

# Compare (3 branches if).
sel; # greater.
$bef->store_code( <<'END_OF_CODE' );
34     v
 q..1  w  01-..q
       > 0..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "-1 0 " );
sel; # equal.
$bef->store_code( <<'END_OF_CODE' );
33     v
 q..1  w  01-..q
       > 0..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 0 " );
sel; # smaller.
$bef->store_code( <<'END_OF_CODE' );
43     v
 q..1  w  01-..q
       > 0..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 0 " );
BEGIN { $tests += 3 };


BEGIN { plan tests => $tests };

