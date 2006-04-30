#-*- cperl -*-
# $Id: 10stdio.t,v 1.4 2006/04/30 13:54:21 jquelin Exp $
#

#----------------------------------#
#          The basic I/O.          #
#----------------------------------#

use strict;
use Language::Befunge;
use POSIX qw! tmpnam !;
use Test;

# Vars.
my $file;
my $fh;
my $tests;
my $out;
my $slurp;
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

# Ascii output.
sel;
$bef->store_code( <<'END_OF_CODE' );
ff+7+,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "%" );
BEGIN { $tests += 1 };

# Number output.
sel;
$bef->store_code( <<'END_OF_CODE' );
f.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "15 " );
BEGIN { $tests += 1 };

# Not testing input.
# If somebody know how to test input automatically...

# File input.
sel; # unknown file.
$bef->store_code( <<'END_OF_CODE' );
v q.2 i v# "/dev/a_file_that_probably_does_not_exist"0 <
>                 ;vector; 3 6   ;flag; 0              ^
        > 1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # existant file.
$bef->store_code( <<'END_OF_CODE' );
v v i "t/hello.bf"0           <
>     ;vector; 3 6  ;flag; 0  ^
  .
  .
  .
  .
  >
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "6 3 2 35 hello world!\n" );
BEGIN { $tests += 2 };

# binary file input
sel;
$bef->store_code( <<'END_OF_CODE' );
v qiv# "t/hello.bf"0        <
>     ;vector; 6 9 ;flag; 1 ^
    <q ,,,,,,,,,"IO Error"a
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $bef->get_torus->rectangle(6, 9, 71, 1),
    qq{v q  ,,,,,,,,,,,,,"hello world!"a <\n>                                 ^} . "\n" );
ok( $out, "" );
BEGIN { $tests += 2 };

# File output.
sel; # unknown file.
$bef->store_code( <<'END_OF_CODE' );
v q.2 o v# "/ved/a_file_that_probably_does_not_exist"0 <
>          ;size; 4 5   ;offset; 7 8       ;flag; 0    ^
    q.1 <
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # valid file.
$bef->store_code( <<'END_OF_CODE' );
v q o "t/foo.txt"0  0 ;flag;     <
>     ;size; 4 4   ;offset; 3 2  ^
   foo!

   ;-)
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "" );
open FOO, "<t/foo.txt" or die $!;
{
    local $/;
    $slurp = <FOO>;
}
ok( $slurp, "foo!\n    \n;-) \n    \n" );
unlink "t/foo.txt";
sel; # flag: text file.
$bef->store_code( <<'END_OF_CODE' );
v q o "t/foo.txt"0  1 ;flag;     <
>     ;size; 4 4   ;offset; 3 2  ^
   foo!

   ;-)
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "" );
open FOO, "<t/foo.txt" or die $!;
{
    local $/;
    $slurp = <FOO>;
}
ok( $slurp, "foo!\n\n;-)\n" );
unlink "t/foo.txt";
BEGIN { $tests += 5 };


BEGIN { plan tests => $tests };

