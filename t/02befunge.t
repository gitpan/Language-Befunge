#-*- cperl -*-
# $Id: 02befunge.t,v 1.4 2002/04/11 07:27:43 jquelin Exp $
#

#-------------------------------------------------------#
#          This file tests the exported funcs.          #
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

# Basic reading.
sel;
read_file( "t/q.bf" );
run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Reading a non existent file.
eval { read_file( "/dev/a_file_that_is_not_likely_to_exist" ); };
ok( $@, qr/line/ );
BEGIN { $tests += 1 };

# Basic storing.
sel;
store_code( <<'END_OF_CODE' );
q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };
