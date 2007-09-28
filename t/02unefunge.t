#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#-----------------------------------#
#          Exported funcs.          #
#-----------------------------------#

use strict;
use Language::Befunge;
use POSIX qw! tmpnam !;
use Test;

# Vars.
my ($file, $fh);
my $tests;
my $out;
my $unef = Language::Befunge->new( Dimensions => 1 );
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

# Basic constructor.
sel;
$unef = Language::Befunge->new( "t/q.bf", Dimensions => 1 );
$unef->run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Basic reading.
$unef = Language::Befunge->new( Dimensions => 1 );
sel;
$unef->read_file( "t/q.bf" );
$unef->run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Basic storing.
sel;
$unef->store_code( <<'END_OF_CODE' );
q
END_OF_CODE
$unef->run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Interpreter must treat non-characters as if they were an 'r' instruction.
sel;
$unef->store_code( <<'END_OF_CODE' );
01-ap#q1.2 q
END_OF_CODE
$unef->run_code;
$out = slurp;
ok( $out, "1 2 " );
BEGIN { $tests += 1 };

# Interpreter must treat non-commands as if they were an 'r' instruction.
sel;
$unef->store_code( <<'END_OF_CODE' );
01+ap#q1.2 q
END_OF_CODE
$unef->run_code;
$out = slurp;
ok( $out, "1 2 " );
BEGIN { $tests += 1 };

# Unefunge Interpreter treats North/South instructions as unknown characters.
sel;
$unef->store_code( <<"END_OF_CODE" );
1#q.2^3.q
END_OF_CODE
$unef->run_code;
$out = slurp;
ok( $out, "1 2 " );
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };
