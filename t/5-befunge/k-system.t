#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#---------------------------------#
#          System stuff.          #
#---------------------------------#

use strict;
use File::Spec::Functions qw{ catfile };
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

# exec instruction.
SKIP: {
    skip 'will barf on windows...', 1 if $^O eq 'MSWin32';

    sel; # unknown file.
    $bef->store_code( '< q . = "a_file_unlikely_to_exist"0' );
    {
        local $SIG{__WARN__} = sub {};
        $bef->run_code;
    }
    $out = slurp;
    is( $out, "-1 " );
}
sel; # normal system-ing.
$bef->store_code( <<'END_OF_CODE' );
< q . = "perl t/_resources/exit3.pl"0
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "3 " );
BEGIN { $tests += 2 };

# System info retrieval.
sel; # 1. flags.
$bef->store_code( <<'END_OF_CODE' );
1y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "15 " );
BEGIN { $tests += 1 };

sel; # 2. size of funge integers in bytes.
$bef->store_code( <<'END_OF_CODE' );
2y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "4 " );
BEGIN { $tests += 1 };

sel; # 3. handprint.
$bef->store_code( <<'END_OF_CODE' );
3y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
my $handprint = 0;
$handprint = $handprint*256 + ord($_) for split //, $bef->get_handprint;
is( $out, "$handprint " );
BEGIN { $tests += 1 };

sel; # 4. version of interpreter.
$bef->store_code( <<'END_OF_CODE' );
4y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
my $ver = $Language::Befunge::VERSION;
$ver =~ s/\.//g;
is( $out, "$ver " );
BEGIN { $tests += 1 };

sel; # 5. ID Code
$bef->store_code( <<'END_OF_CODE' );
5y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "1 " );
BEGIN { $tests += 1 };

sel; # 6. path separator.
$bef->store_code( <<'END_OF_CODE' );
6y,q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, catfile('','') );
BEGIN { $tests += 1 };

sel; # 7. size of funge (2D).
$bef->store_code( <<'END_OF_CODE' );
7y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "2 " );
BEGIN { $tests += 1 };

sel; # 8. IP id.
$bef->store_code( <<'END_OF_CODE' );
8y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
like( $out, qr/^\d+ $/ );
BEGIN { $tests += 1 };

sel; # 9. NetFunge (unimplemented).
$bef->store_code( <<'END_OF_CODE' );
9y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "0 " );
BEGIN { $tests += 1 };

sel; # 10,11. pos of IP.
$bef->store_code( <<'END_OF_CODE' );
bav
  > y.y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "1 6 " );
BEGIN { $tests += 1 };

sel; # 12,13. delta of IP.
$bef->store_code( <<'END_OF_CODE' );
v y
    .
      q
>dc 21  x
          y
            .
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "1 2 " );
BEGIN { $tests += 1 };

sel; # 14,15. Storage offset.
$bef->store_code( <<'END_OF_CODE' );
   0   {  fey.y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "0 8 " );
BEGIN { $tests += 1 };

sel; # 16,17. top-left corner of Lahey space.
$bef->store_code( <<'END_OF_CODE' );
6 03-04-p f1+f2+ y.y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "-3 -4 " );
BEGIN { $tests += 1 };

sel; # 18,19. bottom-right corner of Lahey space.
$bef->store_code( <<'END_OF_CODE' );
6 ff+8p 6 03-04-p f3+f4+y.y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "33 12 " );
BEGIN { $tests += 1 };

sel; # 20. Date.
my ($s,$m,$h,$dd,$mm,$yy)=localtime;
my $date = $yy*256*256+$mm*256+$dd;
my $time = $h*256*256+$m*256+$s;
$bef->store_code( <<'END_OF_CODE' );
f5+y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
chop($out); # remove trailing space.
is( $out >= $date,   1); # There is a tiny little chance
is( $out <= $date+1, 1); # that the date has changed.
BEGIN { $tests += 2 };

sel; # 21. Time.
$bef->store_code( <<'END_OF_CODE' );
f6+y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
chop($out); # remove trailing space.
is( $out >= $time,   1);  # The two tests should not take
is( $out <= $time+15, 1); # more than 15 seconds.
BEGIN { $tests += 2 };

sel; # 21. Size of stack stack.
$bef->store_code( <<'END_OF_CODE' );
0{0{0{0{ f7+y. 0}0} f7+y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "5 3 " );
BEGIN { $tests += 1 };

sel; # 22(,23,24). Size of each stack.
$bef->store_code( <<'END_OF_CODE' );
123 0{ 12 0{ 987654 f8+y.f9+y.fa+y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "6 4 5 " );
BEGIN { $tests += 1 };

sel; # 23+. Args.
$bef->store_code( <<'END_OF_CODE' );
yf7+k$ >  :#, _ $a, :#v _q
       ^              <
END_OF_CODE
$bef->run_code( "foo", 7, "bar" );
$out = slurp;
is( $out, "STDIN\nfoo\n7\nbar\n" );
BEGIN { $tests += 1 };

sel; # 24+. %ENV.
%ENV= ( LANG   => "C",
        LC_ALL => "C",
      );
$bef->store_code( <<'END_OF_CODE' );
v                   > $ ;EOL; a,  v
              > :! #^_ ,# #! #: <
> y ff+k$   : | ;new pair;   :    <
              q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "LANG=C\nLC_ALL=C\n" );
BEGIN { $tests += 1 };

sel; # negative.
$bef->store_code( <<'END_OF_CODE' );
02-y..q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "15 4 " );
BEGIN { $tests += 1 };

sel; # pick in stack.
%ENV= ();
$bef->store_code( <<'END_OF_CODE' );
1234567 75*y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
is( $out, "5 " );
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };
