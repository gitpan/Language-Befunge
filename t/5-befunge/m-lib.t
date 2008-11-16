#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#--------------------------------------#
#          Library semantics.          #
#--------------------------------------#

use strict;
use Language::Befunge;
use Config;
use POSIX qw! tmpnam !;
use Test::More;

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

# Basic loading.
sel; # normal
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( P q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "Hello world!\n" );

sel; # interact with IP
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( S > :# #, _ q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "Hello world!\n" );

sel; # unknown extension
$bef->store_code( <<'END_OF_CODE' );
"JAVA" 4 #v( 2. q
 q . 1    <
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "1 " );

sel; # negative fingerprint
$bef->store_code( <<'END_OF_CODE' );
f- 1 (
END_OF_CODE
eval { $bef->run_code; };
like( $@, qr/Attempt to build a fingerprint with a negative number/,
      "loading a library with a negative fingerprint barfs" );
BEGIN { $tests += 4 };


# Overloading.
sel;
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( "OOF" 3 ( P q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "foo" );
BEGIN { $tests += 1 };


# Inheritance.
sel;
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( "OOF" 3 ( S > :# #, _ q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "Hello world!\n" );
BEGIN { $tests += 1 };


# Unloading.
sel; # normal unloading.
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( "OOF" 3 ( P ) P q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "fooHello world!\n" );

sel; # unloading under stack.
$bef->store_code( <<'END_OF_CODE' );
"AMOR" 4 ( "UDOM" 4 ( "AMOR" 4 ) M .q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "1000 " );

sel; # unloading non-loaded extension.
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( "JAVA" 4 #v ) 2.q
                q.1  <
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "1 " );

sel; # negative fingerprint
$bef->store_code( <<'END_OF_CODE' );
f- 1 )
END_OF_CODE
eval { $bef->run_code; };
like( $@, qr/Attempt to build a fingerprint with a negative number/,
      "unloading a library with a negative fingerprint barfs" );
BEGIN { $tests += 4 };


BEGIN { plan tests => $tests };
