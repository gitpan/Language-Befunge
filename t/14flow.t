#-*- cperl -*-
# $Id: 14flow.t,v 1.3 2002/04/11 12:52:03 jquelin Exp $
#

#---------------------------------#
#          Flow control.          #
#---------------------------------#

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

# Space is a no-op.
sel;
store_code( <<'END_OF_CODE' );
   f   f  +     7       +  ,   q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "%" );
BEGIN { $tests += 1 };

# z is a true no-op.
sel;
store_code( <<'END_OF_CODE' );
zzzfzzzfzz+zzzzz7zzzzzzz+zz,zzzq
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "%" );
BEGIN { $tests += 1 };

# Trampoline.
sel;
store_code( <<'END_OF_CODE' );
1#2.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 1 };

# Stop.
sel;
store_code( <<'END_OF_CODE' );
1.@
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 1 };

# Comments / Jump over.
sel;
store_code( <<'END_OF_CODE' );
2;this is a comment;1+.@
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "3 " );
BEGIN { $tests += 1 };

# Jump to.
sel; # Positive.
store_code( <<'END_OF_CODE' );
2j123..q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "3 0 " );
sel; # Null.
store_code( <<'END_OF_CODE' );
0j1.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # Negative.
store_code( <<'END_OF_CODE' );
v   q.1 < >06-j2.q
>         ^
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 3 };

# Quit instruction.
sel;
store_code( <<'END_OF_CODE' );
af.q
END_OF_CODE
my $rv = run_code;
$out = slurp;
ok( $out, "15 " );
ok( $rv, 10 );
BEGIN { $tests += 2 };

# Repeat instruction (glurps).
sel; # normal repeat.
store_code( <<'END_OF_CODE' );
572k.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "7 5 " );
sel; # null repeat.
store_code( <<'END_OF_CODE' );
0k.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "" );
sel; # useless repeat.
store_code( <<'END_OF_CODE' );
5kv
  > 1.q
END_OF_CODE
run_code;
$out = slurp;
ok( $out, "1 " );
sel; # repeat negative.
store_code( <<'END_OF_CODE' );
5-kq
END_OF_CODE
eval { run_code; };
$out = slurp;
ok( $@, qr/Attempt to repeat \('k'\) a negative number of times \(-5\)/ );
sel; # repeat forbidden char.
store_code( <<'END_OF_CODE' );
5k;q
END_OF_CODE
eval { run_code; };
$out = slurp;
ok( $@, qr/Attempt to repeat \('k'\) a forbidden instruction \(';'\)/ );
sel; # repeat repeat.
store_code( <<'END_OF_CODE' );
5kkq
END_OF_CODE
eval { run_code; };
$out = slurp;
ok( $@, qr/Attempt to repeat \('k'\) a repeat instruction \('k'\)/ );
BEGIN { $tests += 6 };



BEGIN { plan tests => $tests };

