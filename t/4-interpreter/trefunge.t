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
my $tref = Language::Befunge->new( {syntax=>'trefunge98'} );
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
$tref = Language::Befunge->new( {file=>'t/_resources/q.bf', syntax=>'trefunge98'} );
$tref->run_code;
$out = slurp;
is( $out, '', 'constructor worked' );
BEGIN { $tests += 1 };

# Custom constructor.
$tref = Language::Befunge->new({
    syntax  => 'trefunge98',
    storage => 'Language::Befunge::Storage::Generic::Vec' });
is(ref($tref->get_storage), 'Language::Befunge::Storage::Generic::Vec', 'storage specified');
$tref = Language::Befunge->new({
    syntax   => 'trefunge98',
    wrapping => 'Language::Befunge::Wrapping::LaheySpace' });
is(ref($tref->get_wrapping), 'Language::Befunge::Wrapping::LaheySpace', 'wrapping specified');
$tref = Language::Befunge->new({
    syntax => 'trefunge98',
    ops    => 'Language::Befunge::Ops::GenericFunge98' });
ok(exists($$tref{ops}{m}), 'ops specified');
$tref = Language::Befunge->new({
    syntax => 'trefunge98',
    dims   => 4 });
is($$tref{dimensions}, 4, 'dims specified');
BEGIN { $tests += 4 };

# Basic reading.
$tref = Language::Befunge->new( {syntax=>'trefunge98'} );
sel;
$tref->read_file( "t/_resources/q.bf" );
$tref->run_code;
$out = slurp;
is( $out, "", 'read_file' );
BEGIN { $tests += 1 };

# Basic storing.
sel;
$tref->store_code( <<'END_OF_CODE' );
q
END_OF_CODE
$tref->run_code;
$out = slurp;
is( $out, '', 'store_code' );
BEGIN { $tests += 1 };

# Interpreter must treat non-characters as if they were an 'r' instruction.
sel;
$tref->store_code( <<'END_OF_CODE' );
01-c00p#q1.2 q
END_OF_CODE
$tref->run_code;
$out = slurp;
is( $out, "1 2 ", 'treats non-characters like "r"' );
BEGIN { $tests += 1 };

# Interpreter must treat non-commands as if they were an 'r' instruction.
sel;
$tref->store_code( <<'END_OF_CODE' );
01+c00p#q1.2 q
END_OF_CODE
$tref->run_code;
$out = slurp;
is( $out, "1 2 ", 'treats non-commands like "r"' );
BEGIN { $tests += 1 };

# Interpreter reads trefunge code properly, and operates in 3 dimensions, and
# knows that vectors are 3 integers.
sel;
my $code = <<"END_OF_CODE";
#v401-11x
 >..q    
\f h>      
  ^3   < 
END_OF_CODE
$tref->store_code( $code );
$tref->run_code;
$out = slurp;
is( $out, "3 4 ", 'full operation' );
BEGIN { $tests += 1 };

# rectangle() returns the original box again
chomp $code;
is($tref->get_storage->rectangle(LBV->new(0,0,0), LBV->new(9,2,2)), $code, 'rectangle works');
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };
