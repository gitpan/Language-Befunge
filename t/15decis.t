#-*- cperl -*-
# $Id$
#

#---------------------------------------------------------------------#
#          This file tests the decision making instructions.          #
#---------------------------------------------------------------------#

use strict;
use Language::Befunge;
use POSIX qw! tmpnam !;
use Test;

# Vars.
my $file;
my $fh;
my $tests;
my $out;

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
store_code( <<'END_OF_CODE' );
a!.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 " );
sel; # negative.
store_code( <<'END_OF_CODE' );
05-!.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 " );
sel; # false.
store_code( <<'END_OF_CODE' );
0!.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 3 };

# Comparison.
sel; # greater.
store_code( <<'END_OF_CODE' );
53`.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # equal.
store_code( <<'END_OF_CODE' );
55`.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 " );
sel; # smaller.
store_code( <<'END_OF_CODE' );
35`.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 " );
BEGIN { $tests += 3 };

# Horizontal if.
sel; # left from north.
store_code( <<'END_OF_CODE' );
1    v
 q.3 _ 4.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "3 " );
sel; # right from north
store_code( <<'END_OF_CODE' );
0    v
 q.3 _ 4.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "4 " );
sel; # left from south.
store_code( <<'END_OF_CODE' );
1    ^
 q.3 _ 4.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "3 " );
sel; # right from south
store_code( <<'END_OF_CODE' );
0    ^
 q.3 _ 4.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "4 " );
BEGIN { $tests += 4 };

# Vertical if.
sel; # north from left.
store_code( <<'END_OF_CODE' );
1 v   >3.q
  >   |
      >4.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "3 " );
sel; # south from left.
store_code( <<'END_OF_CODE' );
0 v   >3.q
  >   |
      >4.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "4 " );
sel; # north from right.
store_code( <<'END_OF_CODE' );
1 v   >3.q
  <   |
      >4.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "3 " );
sel; # south from right.
store_code( <<'END_OF_CODE' );
0 v   >3.q
  <   |
      >4.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "4 " );
BEGIN { $tests += 4 };

# Compare (3 branches if).
sel; # greater.
store_code( <<'END_OF_CODE' );
34     v  
 q..1  w  01-..q
       > 0..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "-1 0 " );
sel; # equal.
store_code( <<'END_OF_CODE' );
33     v  
 q..1  w  01-..q
       > 0..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 0 " );
sel; # smaller.
store_code( <<'END_OF_CODE' );
43     v  
 q..1  w  01-..q
       > 0..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 0 " );
BEGIN { $tests += 3 };


BEGIN { plan tests => $tests };

