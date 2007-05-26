#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#---------------------------------------#
#          Direction changing.          #
#---------------------------------------#

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

# Go west.
sel;
$bef->store_code( <<'END_OF_CODE' );
<q.a
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "10 " );
BEGIN { $tests += 1 };

# Go south.
sel;
$bef->store_code( <<'END_OF_CODE' );
v
a
.
q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "10 " );
BEGIN { $tests += 1 };

# Go north.
sel;
$bef->store_code( <<'END_OF_CODE' );
^
q
.
a
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "10 " );
BEGIN { $tests += 1 };

# Go east.
sel;
$bef->store_code( <<'END_OF_CODE' );
v   > a . q
>   ^
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "10 " );
BEGIN { $tests += 1 };

# Go away.
sel;
$bef->store_code( <<'END_OF_CODE' );
v    > 2.q
>  #v? 1.q
     > 3.q
    >  4.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, qr/^[1-4] $/ );
BEGIN { $tests += 1 };

# Turn left.
sel; # from west.
$bef->store_code( <<'END_OF_CODE' );
v  > 1.q
>  [
   > 2.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from east.
$bef->store_code( <<'END_OF_CODE' );
v  > 1.q
<  [
   > 2.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "2 " );
sel; # from north.
$bef->store_code( <<'END_OF_CODE' );
>     v
  q.2 [ 1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from south.
$bef->store_code( <<'END_OF_CODE' );
>     ^
  q.2 [ 1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "2 " );
BEGIN { $tests += 4 };

# Turn right.
sel; # from west.
$bef->store_code( <<'END_OF_CODE' );
v  > 1.q
>  ]
   > 2.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "2 " );
sel; # from east.
$bef->store_code( <<'END_OF_CODE' );
v  > 1.q
<  ]
   > 2.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from north.
$bef->store_code( <<'END_OF_CODE' );
>     v
  q.2 ] 1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "2 " );
sel; # from south.
$bef->store_code( <<'END_OF_CODE' );
>     ^
  q.2 ] 1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 4 };

# Reverse.
sel; # from west.
$bef->store_code( <<'END_OF_CODE' );
>  #vr 2.q
    >  1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from east.
$bef->store_code( <<'END_OF_CODE' );
<  q.2  rv#
   q.1   <
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from north.
$bef->store_code( <<'END_OF_CODE' );
>     v
      #
      > 1.q
      r
      > 2.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # from south.
$bef->store_code( <<'END_OF_CODE' );
>     ^
      > 2.q
      r
      > 1.q
      #
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 4 };

# Absolute vector.
sel; # diagonal.
$bef->store_code( <<'END_OF_CODE' );
11x
   1
    .
     q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # diagonal/out-of-bounds.
$bef->store_code( <<'END_OF_CODE' );
101-x
   q
  .
 1
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 2 };


BEGIN { plan tests => $tests };

