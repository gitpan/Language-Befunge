#-*- cperl -*-
# $Id: 20system.t,v 1.1.1.1 2003/02/22 10:17:10 jquelin Exp $
#

#---------------------------------#
#          System stuff.          #
#---------------------------------#

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
my $bef = new Language::Befunge;
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
sel; # unknown file.
$bef->store_code( <<'END_OF_CODE' );
< q . = "a_file_unlikely_to_exist"0
END_OF_CODE
{
    local $SIG{__WARN__} = sub {};
    $bef->run_code; 
}
$out = slurp;
ok( $out, "-1 " );
sel; # normal system-ing.
$bef->store_code( <<'END_OF_CODE' );
< q . = "perl t/exit3.pl"0
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 " );
BEGIN { $tests += 2 };

# System info retrieval.
sel; # 1. flags.
$bef->store_code( <<'END_OF_CODE' );
1y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "15 " );
BEGIN { $tests += 1 };

sel; # 2. size of funge integers in bytes.
$bef->store_code( <<'END_OF_CODE' );
2y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "4 " );
BEGIN { $tests += 1 };

sel; # 3. handprint.
$bef->store_code( <<'END_OF_CODE' );
3y,,,,,,.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "JQBF980 " );
BEGIN { $tests += 1 };

sel; # 4. version of interpreter.
$bef->store_code( <<'END_OF_CODE' );
4y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
my $ver = $Language::Befunge::VERSION;
$ver =~ s/\.//g;
ok( $out, "$ver " );
BEGIN { $tests += 1 };

sel; # 5. ID Code
$bef->store_code( <<'END_OF_CODE' );
5y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 1 };

sel; # 6. path separator.
$bef->store_code( <<'END_OF_CODE' );
6y,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, $Config{path_sep} );
BEGIN { $tests += 1 };

sel; # 7. size of funge (2D).
$bef->store_code( <<'END_OF_CODE' );
7y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "2 " );
BEGIN { $tests += 1 };

sel; # 8. IP id.
$bef->store_code( <<'END_OF_CODE' );
8y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, qr/^\d+ $/ );
BEGIN { $tests += 1 };

sel; # 9. NetFunge (unimplemented).
$bef->store_code( <<'END_OF_CODE' );
9y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 " );
BEGIN { $tests += 1 };

sel; # 10. pos of IP.
$bef->store_code( <<'END_OF_CODE' );
a v
  > y..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 4 " );
BEGIN { $tests += 1 };

sel; # 11. delta of IP.
$bef->store_code( <<'END_OF_CODE' );
b 21x   .   q
      y   .
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 2 " );
BEGIN { $tests += 1 };

sel; # 12. Storage offset.
$bef->store_code( <<'END_OF_CODE' );
   0   {  cy..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "0 8 " );
BEGIN { $tests += 1 };

sel; # 13. top-left corner of Lahey space.
$bef->store_code( <<'END_OF_CODE' );
6 03-04-p  dy..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "-4 -3 " );
BEGIN { $tests += 1 };

sel; # 14. bottom-right corner of Lahey space.
$bef->store_code( <<'END_OF_CODE' );
6 ff+8p 6 03-04-p ey..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "13 34 " );
BEGIN { $tests += 1 };

sel; # 15. Date.
my ($s,$m,$h,$dd,$mm,$yy)=localtime;
my $date = $yy*256*256+$mm*256+$dd;
my $time = $h*256*256+$m*256+$s;
$bef->store_code( <<'END_OF_CODE' );
fy.q
END_OF_CODE
$bef->run_code;
$out = slurp;
chop($out); # remove trailing space.
ok( $out >= $date,   1); # There is a tiny little chance
ok( $out <= $date+1, 1); # that the date has changed.
BEGIN { $tests += 2 };

sel; # 16. Time.
$bef->store_code( <<'END_OF_CODE' );
88+y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
chop($out); # remove trailing space.
ok( $out >= $time,   1);  # The two tests should not take
ok( $out <= $time+15, 1); # more than 15 seconds.
BEGIN { $tests += 2 };

sel; # 17. Size of stack stack.
$bef->store_code( <<'END_OF_CODE' );
0{0{0{0{ 89+y. 0}0} 89+y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "5 3 " );
BEGIN { $tests += 1 };

sel; # 18. Size of each stack.
$bef->store_code( <<'END_OF_CODE' );
123 0{ 12 0{ 987654 99+y...q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "6 4 5 " );
BEGIN { $tests += 1 };

sel; # 19. Args.
$bef->store_code( <<'END_OF_CODE' );
a9+y >  :#, _ $a, :#v _q
     ^              <
END_OF_CODE
$bef->run_code( "foo", 7, "bar" );
$out = slurp;
ok( $out, "STDIN\nfoo\n7\nbar\n" );
BEGIN { $tests += 1 };

sel; # 20. %ENV.
%ENV= ( LANG   => "C",
        LC_ALL => "C",
      );
$bef->store_code( <<'END_OF_CODE' );
v                > $ ;EOL; a,  v
           > :! #^_ ,# #! #: <
>  2a*y  : | ;new pair;   :    <
           q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "LANG=C\nLC_ALL=C\n" );
BEGIN { $tests += 1 };

sel; # negative.
$bef->store_code( <<'END_OF_CODE' );
02-y..,,,,,,q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "15 4 JQBF98" );
BEGIN { $tests += 1 };

sel; # pick in stack.
$bef->store_code( <<'END_OF_CODE' );
1234567 b2*y.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "6 " );
BEGIN { $tests += 1 };

BEGIN { plan tests => $tests };
