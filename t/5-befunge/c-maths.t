#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#---------------------------------------#
#          The math functions.          #
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

# Multiplication.
sel; # regular multiplication.
$bef->store_code( <<'END_OF_CODE' );
49*.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "36 " );
sel; # empty stack.
$bef->store_code( <<'END_OF_CODE' );
4*.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
sel; # program overflow.
$bef->store_code( <<'END_OF_CODE' );
aaa** aaa** * aaa** aaa** *  * . q
END_OF_CODE
eval { $bef->run_code; };
$out = slurp;
ok( $@, qr/program overflow while performing multiplication/ );
sel; # program underflow.
$bef->store_code( <<'END_OF_CODE' );
1- aaa*** aaa** * aaa** aaa** *  * . q
END_OF_CODE
eval { $bef->run_code; };
$out = slurp;
ok( $@, qr/program underflow while performing multiplication/ );
BEGIN { $tests += 4 };


# Addition.
sel; # regular addition.
$bef->store_code( <<'END_OF_CODE' );
35+.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "8 " );
sel; # empty stack.
$bef->store_code( <<'END_OF_CODE' );
f+.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "15 " );
sel; # program overflow.
$bef->store_code( <<'END_OF_CODE' );
2+a* 1+a* 4+a* 7+a* 4+a* 8+a* 3+a* 6+a* 4+a* 6+ f+ .q
END_OF_CODE
eval { $bef->run_code; };
$out = slurp;
ok( $@, qr/program overflow while performing addition/ );
sel; # program underflow.
$bef->store_code( <<'END_OF_CODE' );
2+a* 1+a* 4+a* 7+a* 4+a* 8+a* 3+a* 6+a* 4+a* 6+ - 0f- + .q
END_OF_CODE
eval { $bef->run_code; };
$out = slurp;
ok( $@, qr/program underflow while performing addition/ );
BEGIN { $tests += 4 };


# Substraction.
sel; # regular substraction.
$bef->store_code( <<'END_OF_CODE' );
93-.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "6 " );
sel; # regular substraction (negative).
$bef->store_code( <<'END_OF_CODE' );
35-.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "-2 " );
sel; # empty stack.
$bef->store_code( <<'END_OF_CODE' );
f-.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "-15 " );
sel; # program overflow.
$bef->store_code( <<'END_OF_CODE' );
2+a* 1+a* 4+a* 7+a* 4+a* 8+a* 3+a* 6+a* 4+a* 6+ 0f- - .q
END_OF_CODE
eval { $bef->run_code; };
$out = slurp;
ok( $@, qr/program overflow while performing substraction/ );
sel; # program underflow.
$bef->store_code( <<'END_OF_CODE' );
2+a* 1+a* 4+a* 7+a* 4+a* 8+a* 3+a* 6+a* 4+a* 6+ - f- .q
END_OF_CODE
eval { $bef->run_code; };
$out = slurp;
ok( $@, qr/program underflow while performing substraction/ );
BEGIN { $tests += 5 };


# Division.
sel; # regular division.
$bef->store_code( <<'END_OF_CODE' );
93/.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 " );
sel; # regular division (non-integer).
$bef->store_code( <<'END_OF_CODE' );
54/.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # empty stack.
$bef->store_code( <<'END_OF_CODE' );
f/.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
sel; # division by zero.
$bef->store_code( <<'END_OF_CODE' );
a0/.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
# Can't over/underflow integer division.
BEGIN { $tests += 4 };

# Remainder.
sel; # regular remainder.
$bef->store_code( <<'END_OF_CODE' );
93%.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
sel; # regular remainder (non-integer).
$bef->store_code( <<'END_OF_CODE' );
54/.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # empty stack.
$bef->store_code( <<'END_OF_CODE' );
f%.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
sel; # remainder by zero.
$bef->store_code( <<'END_OF_CODE' );
a0%.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
# Can't over/underflow integer remainder.
BEGIN { $tests += 4 };


BEGIN { plan tests => $tests };

