#-*- cperl -*-
# $Id: 13dir.t,v 1.4 2002/04/11 08:56:12 jquelin Exp $
#

#-----------------------------------------------------------#
#          This file tests the direction changing.          #
#-----------------------------------------------------------#

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

# Go west.
sel;
store_code( <<'END_OF_CODE' );
<q.a
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "10 " );
BEGIN { $tests += 1 };

# Go south.
sel;
store_code( <<'END_OF_CODE' );
v
a
.
q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "10 " );
BEGIN { $tests += 1 };

# Go north.
sel;
store_code( <<'END_OF_CODE' );
^
q
.
a
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "10 " );
BEGIN { $tests += 1 };

# Go east.
sel;
store_code( <<'END_OF_CODE' );
v   > a . q
>   ^
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "10 " );
BEGIN { $tests += 1 };

# Go away.
sel;
store_code( <<'END_OF_CODE' );
v    > 2.q
>  #v? 1.q
     > 3.q
    >  4.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, qr/^[1-4] $/ );
BEGIN { $tests += 1 };

# Turn left.
sel; # from west.
store_code( <<'END_OF_CODE' );
v  > 1.q
>  [
   > 2.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from east.
store_code( <<'END_OF_CODE' );
v  > 1.q
<  [
   > 2.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "2 " );
sel; # from north.
store_code( <<'END_OF_CODE' );
>     v
  q.2 [ 1.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from south.
store_code( <<'END_OF_CODE' );
>     ^
  q.2 [ 1.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "2 " );
BEGIN { $tests += 4 };

# Turn right.
sel; # from west.
store_code( <<'END_OF_CODE' );
v  > 1.q
>  ]
   > 2.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "2 " );
sel; # from east.
store_code( <<'END_OF_CODE' );
v  > 1.q
<  ]
   > 2.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from north.
store_code( <<'END_OF_CODE' );
>     v
  q.2 ] 1.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "2 " );
sel; # from south.
store_code( <<'END_OF_CODE' );
>     ^
  q.2 ] 1.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 4 };

# Reverse.
sel; # from west.
store_code( <<'END_OF_CODE' );
>  #vr 2.q
    >  1.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from east.
store_code( <<'END_OF_CODE' );
<  q.2  rv#
   q.1   <
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from north.
store_code( <<'END_OF_CODE' );
>     v
      #
      > 1.q
      r
      > 2.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from south.
store_code( <<'END_OF_CODE' );
>     ^
      > 2.q
      r
      > 1.q
      #
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 4 };

# Absolute vector.
sel; # diagonal.
store_code( <<'END_OF_CODE' );
11x
   1
    .
     q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # diagonal/out-of-bounds.
store_code( <<'END_OF_CODE' );
101-x
       q
      .
     1
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 2 };


BEGIN { plan tests => $tests };

