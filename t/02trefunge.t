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
my $tref = Language::Befunge->new( Dimensions => 3 );
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
$tref = Language::Befunge->new( "t/q.bf", Dimensions => 3 );
$tref->run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Basic reading.
$tref = Language::Befunge->new( Dimensions => 3 );
sel;
$tref->read_file( "t/q.bf" );
$tref->run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Basic storing.
sel;
$tref->store_code( <<'END_OF_CODE' );
q
END_OF_CODE
$tref->run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Interpreter must treat non-characters as if they were an 'r' instruction.
sel;
$tref->store_code( <<'END_OF_CODE' );
01-c00p#q1.2 q
END_OF_CODE
$tref->run_code;
$out = slurp;
ok( $out, "1 2 " );
BEGIN { $tests += 1 };

# Interpreter must treat non-commands as if they were an 'r' instruction.
sel;
$tref->store_code( <<'END_OF_CODE' );
01+c00p#q1.2 q
END_OF_CODE
$tref->run_code;
$out = slurp;
ok( $out, "1 2 " );
BEGIN { $tests += 1 };

# Interpreter reads trefunge code properly, and operates in 3 dimensions, and
# knows that vectors are 3 integers.
sel;
$tref->store_code( <<"END_OF_CODE" );
#v401-11x\n
 >..q
\f h>
  ^3   <
END_OF_CODE
$tref->run_code;
$out = slurp;
ok( $out, "3 4 " );
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };
