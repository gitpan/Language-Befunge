#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#----------------------------------#
#          The basic I/O.          #
#----------------------------------#

use strict;
use Language::Befunge;
use Language::Befunge::IP;
use POSIX qw! tmpnam !;
use Test::More;

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

# ascii output.
sel;
$bef->store_code( <<'END_OF_CODE' );
ff+7+,q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "%" );
{
    # testing output error.
    local $SIG{__WARN__} = sub{};
    $file = tmpnam();
    open OUT, ">$file" or die $!;
    $fh = select OUT;
    close OUT;
    my $ip = Language::Befunge::IP->new;
    $ip->set_delta( Language::Befunge::Vector->new(1,0) );
    $ip->spush( 65 );
    $bef->set_curip($ip);
    $bef->get_ops->{","}->($bef);
    is( $ip->get_delta, "(-1,0)", "output error reverse ip delta" );
}
BEGIN { $tests += 2 };


# number output.
sel;
$bef->store_code( <<'END_OF_CODE' );
f.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "15 " );
{
    # testing output error.
    local $SIG{__WARN__} = sub{};
    $file = tmpnam();
    open OUT, ">$file" or die $!;
    $fh = select OUT;
    close OUT;
    my $ip = Language::Befunge::IP->new;
    $ip->set_delta( Language::Befunge::Vector->new(1,0) );
    $ip->spush( 65 );
    $bef->set_curip($ip);
    $bef->get_ops->{"."}->($bef);
    is( $ip->get_delta, "(-1,0)", "output error reverse ip delta" );
}
BEGIN { $tests += 2 };


# Not testing input.
# If somebody know how to test input automatically...


# file input.
sel; # unknown file.
$bef->store_code( <<'END_OF_CODE' );
v q.2 i v# "/dev/a_file_that_probably_does_not_exist"0 <
>                 ;vector; 3 6   ;flag; 0              ^
        > 1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "1 " );
sel; # existant file.
$bef->store_code( <<'END_OF_CODE' );
v v i "t/_resources/hello.bf"0   <
>     ;vector; 3 6  ;flag; 0     ^
  .
  .
  .
  .
  >
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "6 3 2 35 hello world!\n" );
BEGIN { $tests += 2 };

# binary file input
sel;
$bef->store_code( <<'END_OF_CODE' );
v qiv# "t/_resources/hello.bf"0  <
>     ;vector; 6 9 ;flag; 1      ^
    <q ,,,,,,,,,"IO Error"a
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $bef->storage->rectangle
    ( Language::Befunge::Vector->new( 6, 9),
      Language::Befunge::Vector->new( 71, 1) ),
    qq{v q  ,,,,,,,,,,,,,"hello world!"a <\n>                                 ^} );
is( $out, "" );
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
is( $out, "1 " );
sel; # valid file.
$bef->store_code( <<'END_OF_CODE' );
v q o "t/foo.txt"0  0 ;flag;     <
>     ;size; 4 4   ;offset; 3 2  ^
   foo!

   ;-)
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "" );
open FOO, "<t/foo.txt" or die $!;
{
    local $/;
    $slurp = <FOO>;
}
is( $slurp, "foo!\n    \n;-) \n    " );
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
is( $out, "" );
open FOO, "<t/foo.txt" or die $!;
{
    local $/;
    $slurp = <FOO>;
}
is( $slurp, "foo!\n\n;-)\n" );
unlink "t/foo.txt";
BEGIN { $tests += 5 };

# testing unability to


BEGIN { plan tests => $tests };

