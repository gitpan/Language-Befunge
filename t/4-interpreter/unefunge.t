#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#-----------------------------------#
#          Exported funcs.          #
#-----------------------------------#

use strict;
use Language::Befunge;
use aliased 'Language::Befunge::Vector' => 'LBV';

use POSIX qw! tmpnam !;
use Test::More;

# Vars.
my ($file, $fh);
my $tests;
my $out;
my $unef = Language::Befunge->new( {syntax=>'unefunge98'} );
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
$unef = Language::Befunge->new( {file=>'t/_resources/q.bf', syntax=>'unefunge98'} );
$unef->run_code;
$out = slurp;
is( $out, "" );
BEGIN { $tests += 1 };

# Custom constructor.
$unef = Language::Befunge->new({
    syntax  => 'unefunge98',
    storage => 'Language::Befunge::Storage::Generic::Vec' });
is(ref($unef->get_storage), 'Language::Befunge::Storage::Generic::Vec', 'storage specified');
$unef = Language::Befunge->new({
    syntax   => 'unefunge98',
    wrapping => 'Language::Befunge::Wrapping::LaheySpace' });
is(ref($unef->get_wrapping), 'Language::Befunge::Wrapping::LaheySpace', 'wrapping specified');
$unef = Language::Befunge->new({
    syntax => 'unefunge98',
    ops    => 'Language::Befunge::Ops::GenericFunge98' });
ok(exists($$unef{ops}{m}), 'ops specified');
$unef = Language::Befunge->new({
    syntax => 'unefunge98',
    dims   => 4 });
is($$unef{dimensions}, 4, 'dims specified');
BEGIN { $tests += 4 };

# Basic reading.
$unef = Language::Befunge->new( {syntax=>'unefunge98'} );
sel;
$unef->read_file( "t/_resources/q.bf" );
$unef->run_code;
$out = slurp;
is( $out, "" );
BEGIN { $tests += 1 };

# Basic storing.
sel;
$unef->store_code( <<'END_OF_CODE' );
q
END_OF_CODE
$unef->run_code;
$out = slurp;
is( $out, "" );
BEGIN { $tests += 1 };

# Interpreter must treat non-characters as if they were an 'r' instruction.
sel;
$unef->store_code( <<'END_OF_CODE' );
01-ap#q1.2 q
END_OF_CODE
$unef->run_code;
$out = slurp;
is( $out, "1 2 " );
BEGIN { $tests += 1 };

# Interpreter must treat non-commands as if they were an 'r' instruction.
sel;
$unef->store_code( <<'END_OF_CODE' );
01+ap#q1.2 q
END_OF_CODE
$unef->run_code;
$out = slurp;
is( $out, "1 2 " );
BEGIN { $tests += 1 };

# Unefunge Interpreter treats North/South instructions as unknown characters.
sel;
$unef->store_code( <<"END_OF_CODE" );
1#q.2^3.q
END_OF_CODE
$unef->run_code;
$out = slurp;
is( $out, "1 2 " );
BEGIN { $tests += 1 };

# rectangle() just returns the original string again
is($unef->get_storage->rectangle(LBV->new(0), LBV->new(9)), '1#q.2^3.q', 'rectangle works');
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };
