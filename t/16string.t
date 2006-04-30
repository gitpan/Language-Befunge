#-*- cperl -*-
# $Id: 16string.t,v 1.2 2006/04/30 13:54:21 jquelin Exp $
#

#----------------------------------------#
#          The string thingies.          #
#----------------------------------------#

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

# String mode.
sel; # True string mode.
$bef->store_code( <<'END_OF_CODE' );
<q,,,,,,,,,,,,,"hello world!"a
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "hello world!\n" );
sel; # SGML mode.
$bef->store_code( <<'END_OF_CODE' );
<q,,,,,,,,,,,,,"hello   world!"a
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "hello world!\n" );
BEGIN { $tests += 2 };

# Fetch character.
sel; # normal output.
$bef->store_code( <<'END_OF_CODE' );
<q,,,,,,,,,,,,,h'e'l'l'o' 'w'o'r'l'd'!'a
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "hello world!\n" );
sel; # space doubled.
$bef->store_code( <<'END_OF_CODE' );
<q,,,,,,,,,,,,,,h'e'l'l'o' ' 'w'o'r'l'd'!'a
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "hello  world!\n" );
BEGIN { $tests += 2 };

# Store character.
sel; # space doubled.
$bef->store_code( <<'END_OF_CODE' );
v       > .q
>   '4 s  v
        ^ <
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "4 " );
BEGIN { $tests += 1 };


BEGIN { plan tests => $tests };

