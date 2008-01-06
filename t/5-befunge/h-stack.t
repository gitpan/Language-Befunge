#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#-------------------------------------#
#          Stack operations.          #
#-------------------------------------#

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

# Pop.
sel; # normal.
$bef->store_code( <<'END_OF_CODE' );
12345$..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "4 3 " );
sel; # empty stack.
$bef->store_code( <<'END_OF_CODE' );
$..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 0 " );
BEGIN { $tests += 2 };

# Duplicate.
sel; # normal.
$bef->store_code( <<'END_OF_CODE' );
4:..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "4 4 " );
sel; # empty stack.
$bef->store_code( <<'END_OF_CODE' );
:..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 0 " );
BEGIN { $tests += 2 };

# Swap stack.
sel; # normal.
$bef->store_code( <<'END_OF_CODE' );
34\..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 4 " );
sel; # empty stack.
$bef->store_code( <<'END_OF_CODE' );
3\..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 3 " );
BEGIN { $tests += 2 };

# Clear stack.
sel;
$bef->store_code( <<'END_OF_CODE' );
12345678"azertyuiop"n..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 0 " );
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };

