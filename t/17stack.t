#-*- cperl -*-
# $Id: 17stack.t,v 1.1.1.1 2003/02/22 10:17:10 jquelin Exp $
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
my $bef = new Language::Befunge;
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

