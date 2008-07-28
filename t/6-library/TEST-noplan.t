#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#--------------------------------#
#          TEST library          #
#--------------------------------#

use strict;
use Language::Befunge;
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

# TEST.pm and this test script share the same plan.



#$bef->set_DEBUG(1);
# plan (no_plan)
$bef->store_code( <<'END_OF_CODE' );
0"TSET"4(#@0P)@
END_OF_CODE
$bef->run_code;

# ok
sel;
$bef->store_code( <<'END_OF_CODE' );
0"TSET"4(0"dnammoc O"1O)@
END_OF_CODE
$bef->run_code;

# is
sel;
$bef->store_code( <<'END_OF_CODE' );
0"TSET"4(0"dnammoc I"44I)@
END_OF_CODE
$bef->run_code;

