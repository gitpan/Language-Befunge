# $Id: Befunge.pm,v 1.34 2002/04/12 13:02:15 jquelin Exp $
#
# Copyright (c) 2002 Jerome Quelin <jquelin@cpan.org>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package Language::Befunge;
require v5.6;

=head1 NAME

Language::Befunge - a Befunge-98 interpreter.


=head1 SYNOPSIS

    use Language::Befunge;
    read_file( "program.bf" );
    run_code;

    Or, one can write directly:
    store_code( <<'END_OF_CODE' );
    v @,,,,"foo"a <
    >             ^
    END_OF_CODE
    run_code;


=head1 DESCRIPTION

Enter the realm of topological languages!

This module implements the Funge-98 specifications on a 2D field (also
called Befunge). In particular, be aware that this is not a Trefunge
implementation (3D).

This Befunge-98 interpreters assumes the stack and Funge-Space cells
of this implementation are 32 bits signed integers (I hope your os
understand those integers). This means that the torus (or Cartesian
Lahey-Space topology to be more precise) looks like the following:

              32-bit Befunge-98
              =================
                      ^
                      |-2,147,483,648
                      |
                      |         x
          <-----------+----------->
  -2,147,483,648      |      2,147,483,647
                      |
                     y|2,147,483,647
                      v

This implementation is meant to work on unix-like systems, because
this interpreters only handle the character which ordinal value is 10
(also known as \n) as an End-Of-Line chars. In particular, no warranty
is made neither for Microsoft systems (\r\n) nor for Macs (\r).

=cut

# A little anal retention ;-)
use strict;
use warnings;

# Modules we relied upon.
use Carp;     # This module can't explode :o)
use Config;
use Exporter;
use Language::Befunge::IP;
use Language::Befunge::LaheySpace;

# Inheritance.
use base qw(Exporter);

# Public variables of the module.
our $VERSION   = '0.10';
our $HANDPRINT = 'JQBF98'; # the handprint of the interpreter.
our @EXPORT    =  qw! read_file store_code run_code !;
$| = 1;

# Private variables of the module.
my $file;               # Name of the current befunge file.
my @ip;                 # Set of Instruction Pointers.
my $retval;             # Return code of the program.
my $kcounter;           # To store how many times we must repeat an instruction.
my $torus = new Language::Befunge::LaheySpace;



=head1 PRIVATE FUNCTIONS

=head2 debug(  )

Output debug messages.

=cut
sub DEBUG () { 0; }
BEGIN {
    *Language::Befunge::debug =
      DEBUG ?
        sub ($) { my $msg = shift; warn "$msg"; }:
        sub ($) { };
}


=head1 EXPORTED FUNCTIONS

=head2 read_file( filename )

Read a file (given as argument) and store its code.

Side effect: clear the previous code.

=cut
sub read_file {
    $file = shift;
    my $code;
    open BF, "<$file" or croak "$!";
    {
        local $/; # slurp mode.
        $code = <BF>;
    }
    close BF;

    # Store code.
    store_code( $code, $file );
}


=head2 store_code( code )

Store the given code in the Lahey space.

Side effect: clear the previous code.

=cut
sub store_code {
    my $code = shift;
    $file = shift || "STDIN"; # black magic for error msgs.
    $torus->clear;
    $torus->store( $code );
}


=head2 run_code(  )

Run the current code. That is, create a new Instruction Pointer and
move it around the code.

Return the exit code of the program.

=cut
sub run_code {
    debug "\n";
    debug "=-=-=-=-=-=-=-=\n";
    debug "-=  NEW RUN  =-\n";
    debug "=-=-=-=-=-=-=-=\n";

    # Create the first Instruction Pointer.
    @ip = ();
    $kcounter = 1;
    $retval = 0;
    push @ip, new Language::Befunge::IP;

    use Dumpvalue;
    my $d = new Dumpvalue;
    #$d->dumpValue( \@ip );

  tick: while ( scalar( @ip ) ) {
        debug "\n** NEW TICK (".scalar(@ip)." ips to process)\n";
        my @new_ip = ();
        my $ip;

        # Cycle through the IPs.
      ip: while ( $ip = shift @ip ) {
            debug "* NEW IP $ip\n";

            # Fetch values for this IP.
            my $x = $ip->curx;
            my $y = $ip->cury;

            my $ord  = $torus->get_value( $x, $y );
            my $char = $ord < 256 ? chr($ord) : " ";

            debug "#".$ip->id.":($x,$y): $char (ord=$ord)  Stack=(@{$ip->toss})\n";

            # Check if we must execute the instruction.
            if ( $kcounter == 0 ) {
                # We pass in this bloc if and only if the instruction
                # has been repeated n times with a 'k' instruction.
                $kcounter = 1;
                $torus->move_ip_forward($ip);
                push @new_ip, $ip;
                next ip;
            }

            # Check if we are in string-mode.
            if ( $ip->string_mode ) {
                if ( $char eq '"' ) {
                    # End of string-mode.
                    debug "-> End of string-mode.\n";
                    $ip->string_mode(0);
                    $ip->space_pushed(0);
                } elsif ( $char eq ' ' ) {
                    debug "-> SGML style spaces.\n";
                    # A serie of spaces, to be treated as one space.
                    $torus->move_ip_forward( $ip );
                    $ip->space_pushed or $ip->spush( $ord ), $ip->space_pushed(1);
                    redo ip;
                } else {
                    debug "-> We are in string-mode.\n";
                    # A banal character.
                    $ip->spush( $ord );                 
                }
            } else {

              switch: {
                    # -= Numbers =-
                    $char =~ /([0-9a-f])/ and do {
                        debug "-> Pushing number (".hex($1).")\n";
                        $ip->spush( hex($1) );
                        last switch;
                    };


                    # -= Strings =-
                    # Toggle string-mode.
                    $char eq '"' and do {
                        debug "-> Entering string mode.\n";
                        $ip->string_mode(1);
                        last switch;
                    };

                    # Fetch character.
                    $char eq "'" and do {
                        debug "-> Fetching character\n";
                        $torus->move_ip_forward( $ip );
                        $ip->spush( $torus->get_value( $ip->curx, $ip->cury ) );
                        last switch;
                    };

                    # Store character.
                    $char eq 's' and do {
                        debug "-> Storing character\n";
                        $torus->move_ip_forward( $ip );
                        $torus->set_value( $ip->curx, $ip->cury, $ip->spop );
                        last switch;
                    };


                    # -= Mathematical operations =-
                    # Addition.
                    $char eq '+' and do {
                        my $v2 = $ip->spop;
                        my $v1 = $ip->spop;
                        debug "-> Adding: $v1+$v2\n";
                        my $res = $v1 + $v2;
                        $res > 2**31-1 and
                          croak "$file ($x,$y): program overflow while performing addition";
                        $res < -2**31 and
                          croak "$file ($x,$y): program underflow while performing addition";
                        $ip->spush( $res );
                        last switch;
                    };

                    # Substraction.
                    $char eq '-' and do {
                        my $v2 = $ip->spop;
                        my $v1 = $ip->spop;
                        debug "-> Substracting: $v1-$v2\n";
                        my $res = $v1 - $v2;
                        $res > 2**31-1 and
                          croak "$file ($x,$y): program overflow while performing substraction";
                        $res < -2**31 and
                          croak "$file ($x,$y): program underflow while performing substraction";
                        $ip->spush( $res );
                        last switch;
                    };

                    # Multiplication.
                    $char eq '*' and do {
                        my $v2 = $ip->spop;
                        my $v1 = $ip->spop;
                        debug "-> Multiplicating: $v1*$v2\n";
                        my $res = $v1 * $v2;
                        $res > 2**31-1 and
                          croak "$file ($x,$y): program overflow while performing multiplication";
                        $res < -2**31 and
                          croak "$file ($x,$y): program underflow while performing multiplication";
                        $ip->spush( $res );
                        last switch;
                    };

                    # Division.
                    $char eq '/' and do {
                        my $v2 = $ip->spop;
                        my $v1 = $ip->spop;
                        debug "-> Dividing: $v1/$v2\n";
                        my $res = $v2 == 0 ? 0 : int($v1 / $v2);
                        # Can't do over/underflow with integer division.
                        $ip->spush( $res );
                        last switch;
                    };

                    # Remainder.
                    $char eq '%' and do {
                        my $v2 = $ip->spop;
                        my $v1 = $ip->spop;
                        debug "-> Remainder: $v1%$v2\n";
                        my $res = ( $v2 == 0 ) ? 0 : int($v1 % $v2);
                        # Can't do over/underflow with integer remainder.
                        $ip->spush( $res );
                        last switch;
                    };


                    # -= Direction changing =-
                    # Cardinal directions.
                    $char eq '>' and do { debug "-> Go east\n";  $ip->dir_go_east;  last switch; };
                    $char eq '<' and do { debug "-> Go west\n";  $ip->dir_go_west;  last switch; };
                    $char eq '^' and do { debug "-> Go north\n"; $ip->dir_go_north; last switch; };
                    $char eq 'v' and do { debug "-> Go south\n"; $ip->dir_go_south; last switch; };

                    # Surprise! =D
                    $char eq '?' and do { debug "-> Go away\n"; $ip->dir_go_away;  last switch; };

                    # Turning right or left, like a car (the specs speak about
                    # a bicycle, but perl is _so_ fast that we can speak about
                    # cars ;) ).
                    $char eq '[' and do { debug "-> Turn left\n";  $ip->dir_turn_left;  last switch; };
                    $char eq ']' and do { debug "-> Turn right\n"; $ip->dir_turn_right; last switch; };

                    # Complete turn around!
                    $char eq 'r' and do { debug "-> Reverse\n"; $ip->dir_reverse; last switch; };

                    # Hmm, the user seems to know where he wants to go. Let's
                    # trust him.
                    $char eq 'x' and do {
                        my $new_dy = $ip->spop;
                        my $new_dx = $ip->spop;
                        debug "-> Setting delta to ($new_dx, $new_dy)\n";
                        $ip->set_delta( $new_dx, $new_dy );
                        last switch;
                    };


                    # -= Decision Making =-
                    # Negation.
                    $char eq '!' and do {
                        debug "-> Logical not\n";
                        $ip->spush( $ip->spop ? 0 : 1 );
                        last switch;
                    };

                    # Comparison.
                    $char eq '`' and do {
                        my $v2 = $ip->spop;
                        my $v1 = $ip->spop;
                        debug "-> Comparing $v1 vs $v2\n";
                        $ip->spush( ($v1 > $v2) ? 1 : 0 );
                        last switch;
                    };

                    # Horizontal if.
                    $char eq '_' and do {
                        debug "-> Horizontal if\n";
                        $ip->spop ? $ip->dir_go_west : $ip->dir_go_east;
                        last switch;
                    };

                    # Vertical if.
                    $char eq '|' and do {
                        debug "-> Vertical if\n";
                        $ip->spop ? $ip->dir_go_north : $ip->dir_go_south;
                        last switch;
                    };

                    # Compare instruction.
                    $char eq 'w' and do {
                        my $v2 = $ip->spop;
                        my $v1 = $ip->spop;
                        debug "-> Comparing $v1 with $v2\n";
                        last switch if $v1 == $v2;
                        $v1 < $v2 ? $ip->dir_turn_left : $ip->dir_turn_right;
                        last switch;
                    };


                    # -= Flow Control =-
                    # No-op.
                    $char eq ' ' and do {
                        debug "-> Slurping next spaces\n";
                        # A serie of spaces is to be treated as _one_ NO-OP.
                        $torus->move_ip_forward($ip) 
                          while $torus->get_value( $ip->curx, $ip->cury ) == 32;

                        # Since pointer will be moved forward after the
                        # switch, we are to put the pointer upon the _last_
                        # space of the serie, instead of the next char
                        # following the serie.
                        $ip->dir_reverse;
                        $torus->move_ip_forward($ip);
                        $ip->dir_reverse;
                        last switch;
                    };

                    # True no-op.
                    $char eq 'z' and debug "-> No-op\n", last switch;

                    # Comments.
                    $char eq ';' and do {
                        debug "-> Comments\n";
                        # Let's skip all those comments during the tick.
                        my $o;
                        for ( $torus->move_ip_forward($ip) ;
                              ( $o = $torus->get_value( $ip->curx, $ip->cury ) ) != ord(";") ; ) {
                            debug "-> Skipping ".chr($o)."\n";
                            $torus->move_ip_forward($ip);
                        }
                        last switch;
                    };

                    # Trampoline. Skip next instruction.
                    $char eq '#' and do {
                        debug "-> Trampoline! (skipping next instruction)\n";
                        $torus->move_ip_forward($ip);
                        last switch;
                    };

                    # Jump to.
                    $char eq 'j' and do {
                        my $count = $ip->spop;
                        debug "-> Skipping $count instructions\n";
                        $count == 0 and last switch;
                        $count < 0  and $ip->dir_reverse; # We can move backward.
                        $torus->move_ip_forward($ip) for (1..abs($count));
                        $count < 0  and $torus->move_ip_forward($ip), $ip->dir_reverse;
                        last switch;
                    };

                    # Repeat instruction.
                    $char eq 'k' and do {
                        $kcounter = $ip->spop;
                        debug "-> Repeating next instruction $kcounter times.\n";
                        $torus->move_ip_forward($ip);
                        $kcounter == 0 and last switch;

                        $kcounter < 0 and # Oops, error.
                          croak "$file ($x,$y): Attempt to repeat ('k') a negative number of times ($kcounter)";

                        my $val = $torus->get_value( $ip->curx, $ip->cury );
                        $val > 0 and $val < 256 and chr($val) =~ /([ ;])/ and
                          croak "$file ($x,$y): Attempt to repeat ('k') a forbidden instruction ('$1')";
                        $kcounter != 0 and $val > 0 and $val < 256 and chr($val) eq "k" and
                          croak "$file ($x,$y): Attempt to repeat ('k') a repeat instruction ('k')";
                        redo ip;
                    };
            
                    # End thread.
                    $char eq '@' and debug "-> End IP\n", next ip;

                    # Quit program.
                    $char eq 'q' and do {
                        debug "-> End program\n";
                        @new_ip = @ip = ();
                        $retval = $ip->spop;
                        last tick;
                    };


                    # -= Stack Manipulation =-
                    # Pop.
                    $char eq '$' and do {
                        debug "-> Popping a value.\n";
                        $ip->spop;
                        last switch;
                    };

                    # Duplicate.
                    $char eq ':' and do {
                        my $value = $ip->spop;
                        debug "-> Duplicating $value\n";
                        $ip->spush( $value );
                        $ip->spush( $value );
                        last switch;
                    };

                    # Swap.
                    $char eq '\\' and do {
                        my $v2 = $ip->spop;
                        my $v1 = $ip->spop;
                        debug "-> Swapping $v1 and $v2\n";
                        $ip->spush( $v2 );
                        $ip->spush( $v1 );
                        last switch;
                    };

                    # Clear stack.
                    $char eq 'n' and do {
                        debug "-> Clearing stack\n";
                        $ip->sclear;
                        last switch;
                    };


                    # -= Stack stack manipulation =-
                    # Begin block.
                    $char eq '{' and do {
                        debug "-> Begin block\n";
                        $ip->ss_create( $ip->spop );  # create new TOSS.
                        $ip->soss_push( $ip->storx ); # Store the current storage
                        $ip->soss_push( $ip->story ); # offset on SOSS.
                        # Set the new Storage Offset.
                        $torus->move_ip_forward($ip);
                        $ip->storx( $ip->curx );
                        $ip->story( $ip->cury );
                        $ip->dir_reverse;
                        $torus->move_ip_forward($ip);
                        $ip->dir_reverse;
                        last switch;
                    };
                
                    # End block.
                    $char eq '}' and do {
                        debug "-> End bloc\n";
                        $ip->ss_count <= 0 and $ip->dir_reverse, last switch;
                        # Restore Storage offset.
                        $ip->story( $ip->soss_pop );
                        $ip->storx( $ip->soss_pop );
                        # Remove the TOSS.
                        $ip->ss_remove( $ip->spop );
                        last switch;
                    };
                
                    # Stack under stack.
                    $char eq 'u' and do {
                        debug "-> Transfering values\n";
                        $ip->ss_count <= 0 and $ip->dir_reverse, last switch;
                        $ip->ss_transfer( $ip->spop );
                        last switch;
                    };


                    # -= Funge-space storage =-
                    # Get instruction.
                    $char eq 'g' and do {
                        debug "-> Fetch character\n";
                        my $y = $ip->spop + $ip->story;
                        my $x = $ip->spop + $ip->storx;
                        $ip->spush( $torus->get_value( $x, $y ) );
                        last switch;
                    };

                    # Put instruction.
                    $char eq 'p' and do {
                        debug "-> Store character\n";
                        my $y = $ip->spop + $ip->story;
                        my $x = $ip->spop + $ip->storx;
                        $torus->set_value( $x, $y, $ip->spop );
                        last switch;
                    };


                    # -= Standard Input/Output =-
                    # Numeric output.
                    $char eq '.' and do {
                        debug "-> Numeric output\n"; 
                        print($ip->spop, " ") or $ip->dir_reverse;
                        last switch;
                    };

                    # Ascii output.
                    $char eq ',' and do {
                        debug "-> Ascii output\n";
                        print ( chr( $ip->spop) ) or $ip->dir_reverse;
                        last switch;
                    };

                    # Numeric input.
                    $char eq '&' and do {
                        debug "-> Numeric input\n"; 
                        my $in = <STDIN>;
                        if ( $in =~ /(-\d+)/ ) {
                            $in = $1;
                            $in < -2**31  and $in = -2**31;
                            $in > 2**31-1 and $in = 2**31-1;
                        } else {
                            $in = 0;
                        }
                        $ip->spush( $in );
                        last switch;
                    };

                    # Ascii input.
                    $char eq '~' and do {
                        debug "-> Ascii input\n"; 
                        my $in = $ip->input or <STDIN>;
                        my $c = substr $in, 0, 1, "";
                        $ip->spush( ord($c) );
                        $ip->input( $in );
                        last switch;
                    };

                    # File input.
                    $char eq 'i' and do {
                        debug "-> Input file\n";
                        # Fetch arguments.
                        my $path = $ip->spop_gnirts;
                        my $flag = $ip->spop; # unused in this interpreter.
                        my $yin = $ip->spop + $ip->story;
                        my $xin = $ip->spop + $ip->storx;

                        # Read file.
                        open F, "<", $path or $ip->dir_reverse, last switch;
                        my $lines;
                        {
                            local $/; # slurp mode.
                            $lines = <F>;
                        }
                        close F or $ip->dir_reverse, last switch;

                        # Store the code and the result vector.
                        my ($wid, $hei) = $torus->store( $lines, $xin, $yin );
                        $ip->spush( $wid, $hei, $xin, $yin );

                        last switch;
                    };

                    # File output.
                    $char eq 'o' and do {
                        debug "-> Output file\n";
                        # Fetch arguments.
                        my $path = $ip->spop_gnirts;
                        my $flag = $ip->spop;
                        my $yin = $ip->spop + $ip->story;
                        my $xin = $ip->spop + $ip->storx;
                        my $hei = $ip->spop;
                        my $wid = $ip->spop;
                        my $data = $torus->rectangle( $xin, $yin, $wid, $hei );

                        # Treat the data chunk as text file?
                        if ( $flag & 1 ) {
                            $data =~ s/ +$//mg;  # blank lines are now void.
                            $data =~ s/\n+\z/\n/;   # final blank lines are stripped.
                        }

                        # Write file.
                        open F, ">", $path or $ip->dir_reverse, last switch;
                        print F $data;
                        close F or $ip->dir_reverse, last switch;

                        last switch;
                    };


                    # System execution.
                    $char eq '=' and do {
                        debug "-> Executing external command.\n";
                        my $path = $ip->spop_gnirts;
                        system( $path );
                        $ip->spush( $? == -1 ? -1 : $? >> 8 );
                        last switch;
                    };


                    # -= System information retrieval =-
                    $char eq 'y' and do {
                        debug "-> System info retrieval.\n";
                        my $val = $ip->spop;
                        my @cells = ();

                        # 1. flags
                        push @cells, 0x01  # 't' is implemented.
                                  |  0x02  # 'i' is implemented.
                                  |  0x04  # 'o' is implemented.
                                  |  0x08  # '=' is implemented.
                                  | !0x10; # buffered IO (non getch).

                        # 2. number of bytes per cell.
                        # 32 bytes Funge: 4 bytes.
                        push @cells, 4; 

                        # 3. implementation handprint.
                        my @hand = reverse map { ord } split //, $HANDPRINT.chr(0);
                        push @cells, \@hand;

                        # 4. version number.
                        my $ver = $VERSION;
                        $ver =~ s/\D//g;
                        push @cells, $ver;

                        # 5. ID code for Operating Paradigm.
                        push @cells, 1; # C-language system() call behaviour.

                        # 6. Path separator character.
                        push @cells, ord( $Config{path_sep} );

                        # 7. Number of dimensions.
                        push @cells, 2;

                        # 8. Unique IP number.
                        push @cells, $ip->id;

                        # 9. Concurrent Funge (not implemented).
                        push @cells, 0;

                        # 10. Position of the curent IP.
                        my @pos = ( $ip->curx, $ip->cury );
                        push @cells, \@pos;

                        # 11. Delta of the curent IP.
                        my @delta = ( $ip->dx, $ip->dy );
                        push @cells, \@delta;

                        # 12. Storage offset of the curent IP.
                        my @stor = ( $ip->storx, $ip->story );
                        push @cells, \@stor;

                        # 13. Top-left point.
                        my @topleft = ( $torus->xmin, $torus->ymin );
                        push @cells, \@topleft;

                        # 14. Dims of the torus.
                        my @dims = ( $torus->xmax - $torus->xmin + 1,
                                     $torus->ymax - $torus->ymin + 1 );
                        push @cells, \@dims;

                        # 15/16. Current date/time.
                        my ($s,$m,$h,$dd,$mm,$yy)=localtime;
                        push @cells, $yy*256*256 + $mm*256 + $dd;
                        push @cells, $h*256*256 + $m*256 + $s;

                        # 17. Size of stack stack.
                        push @cells, $ip->ss_count + 1;

                        # 18. Size of each stack in the stack stack.
                        # !!FIXME!! Funge specs just tell to push onto the
                        # stack the size of the stacks, but nothing is
                        # said about how user will retrieve the number of
                        # stacks.
                        my @sizes = reverse $ip->ss_sizes;
                        push @cells, \@sizes;
                    
                        # 19. $file + @ARGV.
                        # !!FIXME!! This may not be accurate, since this
                        # is a module and the main perl application may
                        # have already processed the command line.
                        my $str = join chr(0), $file, @ARGV, chr(0);
                        my @cmdline = reverse map { ord } split //, $str;
                        push @cells, \@cmdline;
                    
                        # 20. %ENV
                        # 00EULAV=EMAN0EULAV=EMAN
                        $str = "";
                        $str .= "$_=$ENV{$_}".chr(0) foreach sort keys %ENV;
                        $str .= chr(0);
                        my @env = reverse map { ord } split //, $str;
                        push @cells, \@env;

                        # Okay, what to do with those cells.
                        if ( $val <= 0 ) {
                            debug "-> Pushing the whole thing.\n";
                            # Blindly push them onto the stack.
                            foreach my $cell ( reverse @cells ) {
                                $ip->spush( ref( $cell ) eq "ARRAY" ?
                                            @$cell : $cell );
                            }
                            
                        } elsif ( $val <= 20 ) {
                            debug "-> Pushing a given value ($val).\n";
                            # Only push the wanted value.
                            $ip->spush( ref( $cells[$val-1] ) eq "ARRAY" ?
                                        @{ $cells[$val-1] } : $cells[$val-1] );

                        } else {
                            debug "-> Picking a value.\n";
                            # Pick a given value in the stack and push it.
                            $ip->spush( $ip->svalue($val - 20) );
                        }

                        last switch;
                    };


                    # -= Concurrent Funge =-
                    $char eq 't' and do {
                        debug "-> Spawning new IP.\n";
                        my $newip = $ip->clone;
                        $newip->dir_reverse;
                        $torus->move_ip_forward($newip);
                        push @new_ip, $newip;
                        last switch;
                    };
            

                    # -= Capital letters =-
                    $char =~ /[A-Z]/ and do {
                        # Non-overloaded capitals default to
                        # reverse.
                        $ip->dir_reverse;
                        last switch;
                    };


                    # -= Errors =-
                    # Not a regular instruction. Issue a warning & reflect.
                    carp "$file ($x,$y): Unknown instruction '$char'.";
                    $ip->dir_reverse;
                }
            }

            # Check if we must reexecute the instruction.
            if ( $kcounter > 1 ) {
                debug "kcounter > 1: let's redo instruction...\n";
                $kcounter--;
                redo ip;
            }

            # Tick done for this IP, let's move it and push it in the
            # set of non-terminated IPs.
            debug "-> Moving IP\n";
            $torus->move_ip_forward($ip);
            $kcounter = 1;
            push @new_ip, $ip;
        }

        # Copy the new ips.
        @ip = @new_ip;
    }

    # Return value...
    return $retval;
}


1;
__END__


=head1 TODO

=over 4

=item o

Implement the libraries mechanism: "(" and ")" respectively.

=item o

Implement a standard/simple mechanism in order to allow user to write
their own extensions (aka fingerprints)

=item o

Maybe rewrite the core loop in order to take benefits of the
hash mechanism instead of a giant switch tester.

=item o

Check all the module docs.

=item o

Write standard libraries.

=back


=head1 BUGS

Although this module comes with a full set of tests, maybe there are
subtle bugs - or maybe even I misinterpreted the Funge-98
specs. Please report them to me.

There are some bugs anyway, but they come from the specs:

=over 4

=item o

About the 18th cell pushed by the C<y> instruction: Funge specs just
tell to push onto the stack the size of the stacks, but nothing is
said about how user will retrieve the number of stacks.

=item o

About the 19th cell pushed by the C<y> instruction: what this
interpreter pushes on the stack may not be accurate, since this is a
module and the main perl application may have already processed the
command line.

=back


=head1 AUTHOR

Jerome Quelin, E<lt>jquelin@cpan.orgE<gt>


=head1 COPYRIGHT

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=head1 SEE ALSO

=over 4

=item L<perl>

=item L<http://www.catseye.mb.ca/esoteric/befunge/>

=item L<http://dufflebunk.iwarp.com/JSFunge/spec98.html>

=back

=cut
