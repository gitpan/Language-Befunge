#-*- cperl -*-
# $Id: 10stdio.t,v 1.4 2002/04/11 12:06:43 jquelin Exp $
#

#--------------------------------------------------#
#          This file tests the basic I/O.          #
#--------------------------------------------------#

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

# Ascii output.
sel;
store_code( <<'END_OF_CODE' );
ff+7+,q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "%" );
BEGIN { $tests += 1 };

# Number output.
sel;
store_code( <<'END_OF_CODE' );
f.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "15 " );
BEGIN { $tests += 1 };

# Not testing input.
# If somebody know how to test input automatically...

BEGIN { plan tests => $tests };

