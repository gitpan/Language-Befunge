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
#          Concurrent Funge.          #
#-------------------------------------#

use strict;
use Language::Befunge;
use Config;
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

# Basic concurrency.
sel;
$bef->store_code( <<'END_OF_CODE' );
#vtzz1.@
 >2.@
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "2 1 " );
BEGIN { $tests += 1 };

# q kills all IPs $bef->running.
sel;
$bef->store_code( <<'END_OF_CODE' );
#vtq
 >123...@
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Cloning the stack.
sel;
$bef->store_code( <<'END_OF_CODE' );
123 #vtzz...@
     >...@
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 3 2 2 1 1 " );
BEGIN { $tests += 1 };

# Spaces are one no-op.
sel;
$bef->store_code( <<'END_OF_CODE' );
#vtzzz2.@
 >         1.@
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 2 " );
BEGIN { $tests += 1 };

# Comments are one no-op.
sel;
$bef->store_code( <<'END_OF_CODE' );
#vtzzz2.@
 >;this is a comment;1.@
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 2 " );
BEGIN { $tests += 1 };

# Repeat instructions are one op.
sel;
$bef->store_code( <<'END_OF_CODE' );
#vtzzzzz2.@
 >1112k..@
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 1 2 1 " );
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };
