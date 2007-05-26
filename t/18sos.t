#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#----------------------------------------------#
#          Stack of stack operations.          #
#----------------------------------------------#

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

# The big fat one.
sel;
$bef->store_code( <<'END_OF_CODE' );
123 2 { ... 3 { .... 0 { 3 .. 987 01- { . 2 u .. 4 u .. v
0u... 456 02- u 56 04- u 163 2 } .......   2 01-u 2 } v >
..  4 01- u 0 } .. 004 03-u 02- } .. q                >
END_OF_CODE
my $exp = "";
# (6,0) { new, >0, enough
#   * bef: ( [1 2 3 2] )      Storage (0,0)
#   * aft: ( [2 3] [1 0 0] )  Storage (7,0)
$exp .= "3 2 0 ";
# (14,0) { new, >0, not enough
#   * bef: ( [3] [1 0 0] )            Storage (7,0)
#   * aft: ( [0 0 0] [7 0] [1 0 0] )  Storage (15,0)
$exp .= "0 0 0 0 ";
# (23,0) { new, =0
#   * bef: ( [0] [7 0] [1 0 0] )        Storage (15,0)
#   * aft: ( [] [15 0] [7 0] [1 0 0] )  Storage (24,0)
$exp .= "3 0 ";
# (37,0) { new, <0
#   * bef: ( [9 8 7 -1] [15 0] [7 0] [1 0 0] )       Storage (24,0)
#   * aft: ( [0] [9 8 7 24 0] [15 0] [7 0] [1 0 0] ) Storage (38,0)
$exp .= "0 ";
# (44,0) u transfer, >0, enough
#   * bef: ( [2] [9 8 7 24 0] [15 0] [7 0] [1 0 0] ) Storage (38,0)
#   * aft: ( [0 24] [9 8 7] [15 0] [7 0] [1 0 0] )
$exp .= "24 0 ";
# (51,0) u transfer, >0, not enough
#   * bef: ( [6] [9 8 7] [15 0] [7 0] [1 0 0] )  Storage (38,0)
#   * aft: ( [7 8 9 0] [] [15 0] [7 0] [1 0 0] )
$exp .= "0 9 ";
# (1,1) u transfer, =0
#   * bef: ( [7 8 0] [] [15 0] [7 0] [1 0 0] ) Storage (38,0)
#   * aft: ( [7 8] [] [15 0] [7 0] [1 0 0] )
$exp .= "8 7 0 ";
# (14,1) u transfer, <0, enough
#   * bef: ( [4 5 6 -2] [] [15 0] [7 0] [1 0 0] ) Storage (38,0)
#   * aft: ( [4] [6 5] [15 0] [7 0] [1 0 0] )
# (23,1) u transfer, <0, not enough
#   * bef: ( [4 5 6 -4] [6 5] [15 0] [7 0] [1 0 0] ) Storage (38,0)
#   * aft: ( [] [6 5 6 5 4 0] [15 0] [7 0] [1 0 0] )
# (31,1) } destroy, >0, enough
#   * bef: ( [1 6 3 2] [6 5 6 5 4 0] [15 0] [7 0] [1 0 0] ) Storage (38,0)
#   * aft: ( [6 5 6 5 6 3] [15 0] [7 0] [1 0 0] )           Storage (4,0)
$exp .= "3 6 5 6 5 6 0 ";
# (52,1) } destroy, >0, not enough
#   * bef: ( [2] [15 0 2] [7 0] [1 0 0] ) Storage (4,0)
#   * aft: ( [] [7 0] [1 0 0] )         Storage (0,2)
$exp .= "0 0 ";
# (14,2) } destroy, =0
#   * bef: ( [0] [7 0 4] [1 0 0] ) Storage (0,2)
#   * aft: ( [7] [1 0 0] )         Storage (0,4)
$exp .= "7 0 ";
# (32,2) } destroy, <0
#   * bef: ( [-2] [1 0 0 4 0 0] ) Storage (0,4)
#   * aft: ( [1 0] )          Storage (0,0)
$exp .= "0 1 ";
$bef->run_code;
$out = slurp;
ok( $out, $exp );
BEGIN { $tests += 1 };

# Checking storage offset.
sel; # New storage offset.
$bef->store_code( <<'END_OF_CODE' );
0      {  01+a*1+a*8+ 11p v
    q.2                   <
         >  1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # Retrieving old storage offset.
$bef->store_code( <<'END_OF_CODE' );
0      { 22+ 0 } 01+a*1+a*8+ 61p v
 q.2                             <
      >  1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 2 };

# Checking non-valid end-of-block.
sel; # Retrieving old storage offset.
$bef->store_code( <<'END_OF_CODE' );
   #v  } 2.q
    > 1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 1};


BEGIN { plan tests => $tests };

