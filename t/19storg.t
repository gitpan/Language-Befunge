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
#          Storage operations.          #
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

# put instruction.
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

# get instruction.
sel; # New storage offset.
$bef->store_code( <<'END_OF_CODE' );
0  ;blah;{  04-0g ,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "a" );
sel; # Retrieving old storage offset.
$bef->store_code( <<'END_OF_CODE' );
0  ;blah;  { 22+ 0 } 40g ,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "b" );
BEGIN { $tests += 2 };

# Medley.
sel; # Positive values.
$bef->store_code( <<'END_OF_CODE' );
0  'G14p . 14g ,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 G" );
sel; # Negative values.
$bef->store_code( <<'END_OF_CODE' );
0  'f01-04- p . 01-04-g ,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 f" );
BEGIN { $tests += 2 };

BEGIN { plan tests => $tests };

