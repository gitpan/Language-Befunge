#-*- cperl -*-
# $Id: 02befunge.t,v 1.3 2006/04/30 13:54:21 jquelin Exp $
#

#-----------------------------------#
#          Exported funcs.          #
#-----------------------------------#

use strict;
use Language::Befunge;
use POSIX qw! tmpnam !;
use Test;

# Vars.
my ($file, $fh);
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

# Basic constructor.
sel;
$bef = Language::Befunge->new( "t/q.bf" );
$bef->run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Basic reading.
$bef = Language::Befunge->new;
sel;
$bef->read_file( "t/q.bf" );
$bef->run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Reading a non existent file.
eval { $bef->read_file( "/dev/a_file_that_is_not_likely_to_exist" ); };
ok( $@, qr/line/ );
BEGIN { $tests += 1 };

# Basic storing.
sel;
$bef->store_code( <<'END_OF_CODE' );
q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "" );
BEGIN { $tests += 1 };

# Interpreter must treat non-characters as if they were an 'r' instruction.
sel;
$bef->store_code( <<'END_OF_CODE' );
01-b0p#q1.2 q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 2 " );
BEGIN { $tests += 1 };

# Interpreter must treat non-commands as if they were an 'r' instruction.
sel;
$bef->store_code( <<'END_OF_CODE' );
01+b0p#q1.2 q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 2 " );
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };
