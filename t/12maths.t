#-*- cperl -*-
# $Id: 12maths.t,v 1.3 2002/04/11 07:56:36 jquelin Exp $
#

#-------------------------------------------------------#
#          This file tests the math functions.          #
#-------------------------------------------------------#

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

# Multiplication.
sel; # regular multiplication.
store_code( <<'END_OF_CODE' );
49*.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "36 " );
sel; # empty stack.
store_code( <<'END_OF_CODE' );
4*.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 " );
sel; # program overflow.
store_code( <<'END_OF_CODE' );
aaa** aaa** * aaa** aaa** *  * . q
END_OF_CODE
eval { run_code; };
$out = slurp;
ok( $@, qr/program overflow while performing multiplication/ );
sel; # program underflow.
store_code( <<'END_OF_CODE' );
1- aaa*** aaa** * aaa** aaa** *  * . q
END_OF_CODE
eval { run_code; };
$out = slurp;
ok( $@, qr/program underflow while performing multiplication/ );
BEGIN { $tests += 4 };


# Addition.
sel; # regular addition.
store_code( <<'END_OF_CODE' );
35+.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "8 " );
sel; # empty stack.
store_code( <<'END_OF_CODE' );
f+.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "15 " );
sel; # program overflow.
store_code( <<'END_OF_CODE' );
2+a* 1+a* 4+a* 7+a* 4+a* 8+a* 3+a* 6+a* 4+a* 6+ f+ .q
END_OF_CODE
eval { run_code; };
$out = slurp;
ok( $@, qr/program overflow while performing addition/ );
sel; # program underflow.
store_code( <<'END_OF_CODE' );
2+a* 1+a* 4+a* 7+a* 4+a* 8+a* 3+a* 6+a* 4+a* 6+ - 0f- + .q
END_OF_CODE
eval { run_code; };
$out = slurp;
ok( $@, qr/program underflow while performing addition/ );
BEGIN { $tests += 4 };


# Substraction.
sel; # regular substraction.
store_code( <<'END_OF_CODE' );
93-.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "6 " );
sel; # regular substraction (negative).
store_code( <<'END_OF_CODE' );
35-.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "-2 " );
sel; # empty stack.
store_code( <<'END_OF_CODE' );
f-.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "-15 " );
sel; # program overflow.
store_code( <<'END_OF_CODE' );
2+a* 1+a* 4+a* 7+a* 4+a* 8+a* 3+a* 6+a* 4+a* 6+ 0f- - .q
END_OF_CODE
eval { run_code; };
$out = slurp;
ok( $@, qr/program overflow while performing substraction/ );
sel; # program underflow.
store_code( <<'END_OF_CODE' );
2+a* 1+a* 4+a* 7+a* 4+a* 8+a* 3+a* 6+a* 4+a* 6+ - f- .q
END_OF_CODE
eval { run_code; };
$out = slurp;
ok( $@, qr/program underflow while performing substraction/ );
BEGIN { $tests += 5 };


# Division.
sel; # regular division.
store_code( <<'END_OF_CODE' );
93/.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "3 " );
sel; # regular division (non-integer).
store_code( <<'END_OF_CODE' );
54/.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # empty stack.
store_code( <<'END_OF_CODE' );
f/.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 " );
sel; # division by zero.
store_code( <<'END_OF_CODE' );
a0/.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 " );
# Can't over/underflow integer division.
BEGIN { $tests += 4 };

# Remainder.
sel; # regular remainder.
store_code( <<'END_OF_CODE' );
93%.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 " );
sel; # regular remainder (non-integer).
store_code( <<'END_OF_CODE' );
54/.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # empty stack.
store_code( <<'END_OF_CODE' );
f%.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 " );
sel; # remainder by zero.
store_code( <<'END_OF_CODE' );
a0%.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 " );
# Can't over/underflow integer remainder.
BEGIN { $tests += 4 };


BEGIN { plan tests => $tests };

