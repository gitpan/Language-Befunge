#-*- cperl -*-
# $Id: 17stack.t,v 1.1 2002/04/11 13:08:05 jquelin Exp $
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
store_code( <<'END_OF_CODE' );
12345$..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "4 3 " );
sel; # empty stack.
store_code( <<'END_OF_CODE' );
$..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 0 " );
BEGIN { $tests += 2 };

# Duplicate.
sel; # normal.
store_code( <<'END_OF_CODE' );
4:..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "4 4 " );
sel; # empty stack.
store_code( <<'END_OF_CODE' );
:..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 0 " );
BEGIN { $tests += 2 };

# Swap stack.
sel; # normal.
store_code( <<'END_OF_CODE' );
34\..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "3 4 " );
sel; # empty stack.
store_code( <<'END_OF_CODE' );
3\..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 3 " );
BEGIN { $tests += 2 };

# Clear stack.
sel;
store_code( <<'END_OF_CODE' );
12345678"azertyuiop"n..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "0 0 " );
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };

