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
#          Flow control.          #
#---------------------------------#

use strict;
use Language::Befunge;
use Language::Befunge::IP;
use Language::Befunge::Vector;
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

# Space is a no-op.
sel;
$bef->store_code( <<'END_OF_CODE' );
   f   f  +     7       +  ,   q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "%" );
BEGIN { $tests += 1 };

# z is a true no-op.
sel;
$bef->store_code( <<'END_OF_CODE' );
zzzfzzzfzz+zzzzz7zzzzzzz+zz,zzzq
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "%" );
BEGIN { $tests += 1 };

# Trampoline.
sel;
$bef->store_code( <<'END_OF_CODE' );
1#2.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 1 };

# Stop.
sel;
$bef->store_code( <<'END_OF_CODE' );
1.@
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 1 };

# Comments / Jump over.
sel;
$bef->store_code( <<'END_OF_CODE' );
2;this is a comment;1+.@
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 " );
BEGIN { $tests += 1 };

# Jump to.
sel; # Positive.
$bef->store_code( <<'END_OF_CODE' );
2j123..q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "3 0 " );
sel; # Null.
$bef->store_code( <<'END_OF_CODE' );
0j1.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # Negative.
$bef->store_code( <<'END_OF_CODE' );
v   q.1 <>06-j2.q
>        ^
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
BEGIN { $tests += 3 };

# Quit instruction.
sel;
$bef->store_code( <<'END_OF_CODE' );
af.q
END_OF_CODE
my $rv = $bef->run_code;
$out = slurp;
ok( $out, "15 " );
ok( $rv, 10 );
BEGIN { $tests += 2 };

# Repeat instruction (glurps).
sel; # normal repeat.
$bef->store_code( <<'END_OF_CODE' );
3572k.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "7 5 3 " );
sel; # null repeat.
$bef->store_code( <<'END_OF_CODE' );
0k.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "" );
sel; # useless repeat.
$bef->store_code( <<'END_OF_CODE' );
5kv
 > 1.q
  >2.q
END_OF_CODE
$bef->run_code;
$out = slurp;
ok( $out, "1 " );
sel; # repeat negative.
$bef->store_code( <<'END_OF_CODE' );
5-k43.q
END_OF_CODE
eval { $bef->run_code; };
$out = slurp;
ok( $out, "3 " );
sel; # repeat forbidden char.
$bef->store_code( <<'END_OF_CODE' );
5k;q
END_OF_CODE
eval { $bef->run_code; };
$out = slurp;
ok( $out eq '' );
sel; # repeat repeat.
$bef->store_code( <<'END_OF_CODE' );
5kkq
END_OF_CODE
eval { $bef->run_code; };
$out = slurp;
ok( $out eq '' );
sel; # move_ip() short circuits on a dead end
$bef->store_code( <<'END_OF_CODE' );

END_OF_CODE
$bef->set_curip( Language::Befunge::IP->new );
$bef->get_curip->set_position( Language::Befunge::Vector->new_zeroes(2) );
eval {
    local $SIG{ALRM} = sub { die "timeout\n" };
    alarm 10;
    $bef->move_ip($bef->get_curip, qr/ /);
    alarm 0;
};
$out = slurp;
ok( $@, qr/infinite loop/ );
sel;
$bef->store_code( <<'END_OF_CODE' );
 ; 
END_OF_CODE
$bef->set_curip( Language::Befunge::IP->new );
$bef->get_curip->set_position( Language::Befunge::Vector->new_zeroes(2) );
eval {
    local $SIG{ALRM} = sub { die "timeout\n" };
    alarm 10;
    $bef->move_ip($bef->get_curip, qr/ /);
    alarm 0;
};
$out = slurp;
ok( $@, qr/infinite loop/ );
BEGIN { $tests += 8 };



BEGIN { plan tests => $tests };

