#-*- cperl -*-
# $Id: 22lib.t,v 1.2 2006/04/30 13:54:21 jquelin Exp $
#

#--------------------------------------#
#          Library semantics.          #
#--------------------------------------#

use strict;
use Language::Befunge;
use Config;
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

# Basic loading.
sel; # normal
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( P q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "Hello world!\n" );
sel; # interact with IP
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( S > :# #, _ q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "Hello world!\n" );
sel; # unknown extension
$bef->store_code( <<'END_OF_CODE' );
"JAVA" 4 #v( 2. q
 q . 1    <
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 3 };

# Overloading.
sel;
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( "OOF" 3 ( P q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "foo" );
BEGIN { $tests += 1 };

# Inheritance.
sel;
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( "OOF" 3 ( S > :# #, _ q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "Hello world!\n" );
BEGIN { $tests += 1 };

# Unloading.
sel; # normal unloading.
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( "OOF" 3 ( P ) P q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "fooHello world!\n" );
sel; # unloading under stack.
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( "OOF" 3 ( P "OLEH" 4 ) P #v S 2.q
                                q.1  <
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "foofoo1 " );
sel; # unloading non-loaded extension.
$bef->store_code( <<'END_OF_CODE' );
"OLEH" 4 ( "JAVA" 4 #v ) 2.q
                q.1  <
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 3 };


BEGIN { plan tests => $tests };
