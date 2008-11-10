#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

package Language::Befunge::Ops;
require 5.010;

use strict;
use warnings;

use File::Spec::Functions qw{ catfile };   # For the 'y' instruction.


=head1 NAME

Language::Befunge::Ops - definition of the various operations


=head1 DESCRIPTION

This module implements the various befunge operations. Not all those
operations will be supported by the interpreter though, it will depend
on the type of befunge chosen.


=head1 SUBROUTINES

=head2 Numbers

=over 4

=item num_push_number(  )

Push the current number onto the TOSS.

=cut
sub num_push_number {
    my ($lbi, $char) = @_;

    # Fetching char.
    my $ip  = $lbi->get_curip;
    my $num = hex( $char );

    # Pushing value.
    $ip->spush( $num );

    # Cosmetics.
    $lbi->debug( "pushing number '$num'\n" );
}

=back



=head2 Strings

=over 4

=item str_enter_string_mode(  )

=cut
sub str_enter_string_mode {
    my ($lbi) = @_;

    # Cosmetics.
    $lbi->debug( "entering string mode\n" );

    # Entering string-mode.
    $lbi->get_curip->set_string_mode(1);
}


=item str_fetch_char(  )

=cut
sub str_fetch_char {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Moving pointer...
    $lbi->_move_ip_once($lbi->get_curip);

   # .. then fetch value and push it.
    my $ord = $lbi->storage->get_value( $ip->get_position );
    my $chr = $lbi->storage->get_char( $ip->get_position );
    $ip->spush( $ord );

    # Cosmetics.
    $lbi->debug( "pushing value $ord (char='$chr')\n" );
}


=item str_store_char(  )

=cut
sub str_store_char {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Moving pointer.
    $lbi->_move_ip_once($lbi->get_curip);

    # Fetching value.
    my $val = $ip->spop;

    # Storing value.
    $lbi->storage->set_value( $ip->get_position, $val );
    my $chr = $lbi->storage->get_char( $ip->get_position );

    # Cosmetics.
    $lbi->debug( "storing value $val (char='$chr')\n" );
}

=back



=head2 Mathematical operations

=over 4

=item math_addition(  )

=cut
sub math_addition {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_mult(2);
    $lbi->debug( "adding: $v1+$v2\n" );
    my $res = $v1 + $v2;

    # Checking over/underflow.
    $res > 2**31-1 and $lbi->abort( "program overflow while performing addition" );
    $res < -2**31  and $lbi->abort( "program underflow while performing addition" );

    # Pushing value.
    $ip->spush( $res );
}


=item math_substraction(  )

=cut
sub math_substraction {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_mult(2);
    $lbi->debug( "substracting: $v1-$v2\n" );
    my $res = $v1 - $v2;

    # checking over/underflow.
    $res > 2**31-1 and $lbi->abort( "program overflow while performing substraction" );
    $res < -2**31  and $lbi->abort( "program underflow while performing substraction" );

    # Pushing value.
    $ip->spush( $res );
}


=item math_multiplication(  )

=cut
sub math_multiplication {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_mult(2);
    $lbi->debug( "multiplicating: $v1*$v2\n" );
    my $res = $v1 * $v2;

    # checking over/underflow.
    $res > 2**31-1 and $lbi->abort( "program overflow while performing multiplication" );
    $res < -2**31  and $lbi->abort( "program underflow while performing multiplication" );

    # Pushing value.
    $ip->spush( $res );
}


=item math_division(  )

=cut
sub math_division {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_mult(2);
    $lbi->debug( "dividing: $v1/$v2\n" );
    my $res = $v2 == 0 ? 0 : int($v1 / $v2);

    # Can't do over/underflow with integer division.

    # Pushing value.
    $ip->spush( $res );
}


=item math_remainder(  )

=cut
sub math_remainder {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_mult(2);
    $lbi->debug( "remainder: $v1%$v2\n" );
    my $res = $v2 == 0 ? 0 : int($v1 % $v2);

    # Can't do over/underflow with integer remainder.

    # Pushing value.
    $ip->spush( $res );
}

=back



=head2 Direction changing

=over 4

=item dir_go_east(  )

=cut
sub dir_go_east {
    my ($lbi) = @_;
    $lbi->debug( "going east\n" );
    $lbi->get_curip->dir_go_east;
}


=item dir_go_west(  )

=cut
sub dir_go_west {
    my ($lbi) = @_;
    $lbi->debug( "going west\n" );
    $lbi->get_curip->dir_go_west;
}


=item dir_go_north(  )

=cut
sub dir_go_north {
    my ($lbi) = @_;
    $lbi->debug( "going north\n" );
    $lbi->get_curip->dir_go_north;
}


=item dir_go_south(  )

=cut
sub dir_go_south {
    my ($lbi) = @_;
    $lbi->debug( "going south\n" );
    $lbi->get_curip->dir_go_south;
}


=item dir_go_high(  )

=cut
sub dir_go_high {
    my ($lbi) = @_;
    $lbi->debug( "going high\n" );
    $lbi->get_curip->dir_go_high;
}


=item dir_go_low(  )

=cut
sub dir_go_low {
    my ($lbi) = @_;
    $lbi->debug( "going low\n" );
    $lbi->get_curip->dir_go_low;
}


=item dir_go_away(  )

=cut
sub dir_go_away {
    my ($lbi) = @_;
    $lbi->debug( "going away!\n" );
    $lbi->get_curip->dir_go_away;
}


=item dir_turn_left(  )

Turning left, like a car (the specs speak about a bicycle, but perl
is _so_ fast that we can speak about cars ;) ).

=cut
sub dir_turn_left {
    my ($lbi) = @_;
    $lbi->debug( "turning on the left\n" );
    $lbi->get_curip->dir_turn_left;
}


=item dir_turn_right(  )

Turning right, like a car (the specs speak about a bicycle, but perl
is _so_ fast that we can speak about cars ;) ).

=cut
sub dir_turn_right {
    my ($lbi) = @_;
    $lbi->debug( "turning on the right\n" );
    $lbi->get_curip->dir_turn_right;
}


=item dir_reverse(  )

=cut
sub dir_reverse {
    my ($lbi) = @_;
    $lbi->debug( "180 deg!\n" );
    $lbi->get_curip->dir_reverse;
}


=item dir_set_delta(  )

Hmm, the user seems to know where he wants to go. Let's trust him/her.

=cut
sub dir_set_delta {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;
    my ($new_d) = $ip->spop_vec;
    $lbi->debug( "setting delta to $new_d\n" );
    $ip->set_delta( $new_d );
}

=back



=head2 Decision making

=over 4

=item decis_neg(  )

=cut
sub decis_neg {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching value.
    my $val = $ip->spop ? 0 : 1;
    $ip->spush( $val );

    $lbi->debug( "logical not: pushing $val\n" );
}


=item decis_gt(  )

=cut
sub decis_gt {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_mult(2);
    $lbi->debug( "comparing $v1 vs $v2\n" );
    $ip->spush( ($v1 > $v2) ? 1 : 0 );
}


=item decis_horiz_if(  )

=cut
sub decis_horiz_if {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching value.
    my $val = $ip->spop;
    $val ? $ip->dir_go_west : $ip->dir_go_east;
    $lbi->debug( "horizontal if: going " . ( $val ? "west\n" : "east\n" ) );
}


=item decis_vert_if(  )

=cut
sub decis_vert_if {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching value.
    my $val = $ip->spop;
    $val ? $ip->dir_go_north : $ip->dir_go_south;
    $lbi->debug( "vertical if: going " . ( $val ? "north\n" : "south\n" ) );
}


=item decis_z_if(  )

=cut
sub decis_z_if {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching value.
    my $val = $ip->spop;
    $val ? $ip->dir_go_low : $ip->dir_go_high;
    $lbi->debug( "z if: going " . ( $val ? "low\n" : "high\n" ) );
}


=item decis_cmp(  )

=cut
sub decis_cmp {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching value.
    my ($v1, $v2) = $ip->spop_mult(2);
    $lbi->debug( "comparing $v1 with $v2: straight forward!\n"), return if $v1 == $v2;

    my $dir;
    if ( $v1 < $v2 ) {
        $ip->dir_turn_left;
        $dir = "left";
    } else {
        $ip->dir_turn_right;
        $dir = "right";
    }
    $lbi->debug( "comparing $v1 with $v2: turning: $dir\n" );
}

=back



=head2 Flow control

=over 4

=item flow_space(  )

A serie of spaces is to be treated as B<one> NO-OP.

=cut
sub flow_space {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;
    $lbi->_move_ip_till($ip, qr/ /);
    $lbi->move_ip($lbi->get_curip);

    my $char = $lbi->storage->get_char($ip->get_position);
    $lbi->_do_instruction($char);
}


=item flow_no_op(  )

=cut
sub flow_no_op {
    my ($lbi) = @_;
    $lbi->debug( "no-op\n" );
}


=item flow_comments(  )

Bypass comments in B<zero> tick.

=cut
sub flow_comments {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    $lbi->_move_ip_once($ip);             # skip comment ';'
    $lbi->_move_ip_till( $ip, qr/[^;]/ ); # till just before matching ';'
    $lbi->_move_ip_once($ip);             # till matching ';'
    $lbi->_move_ip_once($ip);             # till just after matching ';'

    my $char = $lbi->storage->get_char($ip->get_position);
    $lbi->_do_instruction($char);
}


=item flow_trampoline(  )

=cut
sub flow_trampoline {
    my ($lbi) = @_;
    $lbi->_move_ip_once($lbi->get_curip);
    $lbi->debug( "trampoline! (skipping next instruction)\n" );
}


=item flow_jump_to(  )

=cut
sub flow_jump_to {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;
    my $count = $ip->spop;
    $lbi->debug( "skipping $count instructions\n" );
    $count == 0 and return;
    $count < 0  and $ip->dir_reverse; # We can move backward.
    $lbi->_move_ip_once($lbi->get_curip) for (1..abs($count));
    $count < 0 and $ip->dir_reverse;
}


=item flow_repeat(  )

=cut
sub flow_repeat {
    my ($lbi) = @_;
    my $ip  = $lbi->get_curip;
    my $pos = $ip->get_position;

    my $kcounter = $ip->spop;
    $lbi->debug( "repeating next instruction $kcounter times.\n" );

    # fetch instruction to repeat
    $lbi->move_ip($lbi->get_curip);
    my $char = $lbi->storage->get_char($ip->get_position);

    $char eq 'k' and return;     # k cannot be itself repeated
    $kcounter == 0 and return;   # nothing to repeat
    $kcounter  < 0 and return;   # oops, error

    # reset position back to where k is, and repeat instruction
    $ip->set_position($pos);
    $lbi->_do_instruction($char) for (1..$kcounter);
}


=item flow_kill_thread(  )

=cut
sub flow_kill_thread {
    my ($lbi) = @_;
    $lbi->debug( "end of Instruction Pointer\n" );
    $lbi->get_curip->set_end('@');
}


=item flow_quit(  )

=cut
sub flow_quit {
    my ($lbi) = @_;
    $lbi->debug( "end program\n" );
    $lbi->set_newips( [] );
    $lbi->set_ips( [] );
    $lbi->get_curip->set_end('q');
    $lbi->set_retval( $lbi->get_curip->spop );
}

=back



=head2 Stack manipulation

=over 4

=item stack_pop(  )

=cut
sub stack_pop {
    my ($lbi) = @_;
    $lbi->debug( "popping a value\n" );
    $lbi->get_curip->spop;
}


=item stack_duplicate(  )

=cut
sub stack_duplicate {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;
    my $value = $ip->spop;
    $lbi->debug( "duplicating value '$value'\n" );
    $ip->spush( $value );
    $ip->spush( $value );
}


=item stack_swap(  )

=cut
sub stack_swap {
    my ($lbi) = @_;
    my $ ip = $lbi->get_curip;
    my ($v1, $v2) = $ip->spop_mult(2);
    $lbi->debug( "swapping $v1 and $v2\n" );
    $ip->spush( $v2 );
    $ip->spush( $v1 );
}


=item stack_clear(  )

=cut
sub stack_clear {
    my ($lbi) = @_;
    $lbi->debug( "clearing stack\n" );
    $lbi->get_curip->sclear;
}

=back



=head2 Stack stack manipulation

=over 4

=item block_open(  )

=cut
sub block_open {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;
    $lbi->debug( "block opening\n" );

    # Create new TOSS.
    $ip->ss_create( $ip->spop );

    # Store current storage offset on SOSS.
    $ip->soss_push( $ip->get_storage->get_all_components );

    # Set the new Storage Offset.
    $lbi->_move_ip_once($lbi->get_curip);
    $ip->set_storage( $ip->get_position );
    $ip->dir_reverse;
    $lbi->_move_ip_once($lbi->get_curip);
    $ip->dir_reverse;
}


=item block_close(  )

=cut
sub block_close {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # No opened block.
    $ip->ss_count <= 0 and $ip->dir_reverse, $lbi->debug("no opened block\n"), return;

    $lbi->debug( "block closing\n" );

    # Restore Storage offset.
    $ip->set_storage( $ip->soss_pop_vec );

    # Remove the TOSS.
    $ip->ss_remove( $ip->spop );
}


=item bloc_transfer(  )

=cut
sub bloc_transfer {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    $ip->ss_count <= 0 and $ip->dir_reverse, $lbi->debug("no SOSS available\n"), return;

    # Transfering values.
    $lbi->debug( "transfering values\n" );
    $ip->ss_transfer( $ip->spop );
}

=back



=head2 Funge-space storage

=over 4

=item store_get(  )

=cut
sub store_get {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching coordinates.
    my ($v) = $ip->spop_vec;
    $v += $ip->get_storage;

    # Fetching char.
    my $val = $lbi->storage->get_value( $v );
    $ip->spush( $val );

    $lbi->debug( "fetching value at $v: pushing $val\n" );
}


=item store_put(  )

=cut
sub store_put {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching coordinates.
    my ($v) = $ip->spop_vec;
    $v += $ip->get_storage;

    # Fetching char.
    my $val = $ip->spop;
    $lbi->storage->set_value( $v, $val );

    $lbi->debug( "storing value $val at $v\n" );
}

=back



=head2 Standard Input/Output

=over 4

=item stdio_out_num(  )

=cut
sub stdio_out_num {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetch value and print it.
    my $val = $ip->spop;
    $lbi->debug( "numeric output: $val\n");
    print( "$val " ) or $ip->dir_reverse;
}


=item stdio_out_ascii(  )

=cut
sub stdio_out_ascii {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetch value and print it.
    my $val = $ip->spop;
    my $chr = chr $val;
    $lbi->debug( "ascii output: '$chr' (ord=$val)\n");
    print( $chr ) or $ip->dir_reverse;
}


=item stdio_in_num(  )

=cut
sub stdio_in_num {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;
    my ($in, $nb) = ('', 0);
    my $last = 0;
    while(!$last) {
        my $char = $lbi->get_input();
        $in .= $char if defined $char;
        my $overflow;
        ($nb, $overflow) = $in =~ /(-?\d+)(\D*)$/;
        if((defined($overflow) && length($overflow)) || !defined($char)) {
            # either we found a non-digit character: $overflow
            # or else we reached EOF: !$char
            return $ip->dir_reverse() unless defined $nb;
            $nb < -2**31  and $nb = -2**31;
            $nb > 2**31-1 and $nb = 2**31-1;
            $in = $overflow;
            $last++;
        }
    }
    $lbi->set_input( $in );
    $ip->spush( $nb );
    $lbi->debug( "numeric input: pushing $nb\n" );
}


=item stdio_in_ascii(  )

=cut
sub stdio_in_ascii {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;
    my $in = $lbi->get_input();
    return $ip->dir_reverse unless defined $in;
    my $ord = ord $in;
    $ip->spush( $ord );
    $lbi->debug( "ascii input: pushing $ord\n" );
}


=item stdio_in_file(  )

=cut
sub stdio_in_file {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetch arguments.
    my $path = $ip->spop_gnirts;
    my $flag = $ip->spop;
    my ($vin) = $ip->spop_vec;
    $vin += $ip->get_storage;

    # Read file.
    $lbi->debug( "input file '$path' at $vin\n" );
    open F, "<", $path or $ip->dir_reverse, return;
    my $lines;
    {
        local $/; # slurp mode.
        $lines = <F>;
    }
    close F;

    # Store the code and the result vector.
    my ($size) = $flag % 2
        ? ( $lbi->storage->store_binary( $lines, $vin ) )
        : ( $lbi->storage->store( $lines, $vin ) );
    $ip->spush_vec( $size, $vin );
}


=item stdio_out_file(  )

=cut
sub stdio_out_file {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetch arguments.
    my $path = $ip->spop_gnirts;
    my $flag = $ip->spop;
    my ($vin) = $ip->spop_vec;
    $vin += $ip->get_storage;
    my ($size) = $ip->spop_vec;
    my $data = $lbi->storage->rectangle( $vin, $size );

    # Cosmetics.
    my $vend = $vin + $size;
    $lbi->debug( "output $vin-$vend to '$path'\n" );

    # Treat the data chunk as text file?
    if ( $flag & 0x1 ) {
        $data =~ s/ +$//mg;    # blank lines are now void.
        $data =~ s/\n+\z/\n/;  # final blank lines are stripped.
    }

    # Write file.
    open F, ">", $path or $ip->dir_reverse, return;
    print F $data;
    close F;
}


=item stdio_sys_exec(  )

=cut
sub stdio_sys_exec {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching command.
    my $path = $ip->spop_gnirts;
    $lbi->debug( "spawning external command: $path\n" );
    system( $path );
    $ip->spush( $? == -1 ? -1 : $? >> 8 );
}

=back



=head2 System info retrieval

=over 4

=item sys_info(  )

=cut
sub sys_info {
    my ($lbi) = @_;
    my $ip      = $lbi->get_curip;
    my $storage = $lbi->storage;

    my $val = $ip->spop;
    my @infos = ();

    # 1. flags
    push @infos, 0x01  # 't' is implemented.
              |  0x02  # 'i' is implemented.
              |  0x04  # 'o' is implemented.
              |  0x08  # '=' is implemented.
              | !0x10; # buffered IO (non getch).

    # 2. number of bytes per cell.
    # 32 bytes Funge: 4 bytes.
    push @infos, 4;

    # 3. implementation handprint.
    my $handprint = 0;
    $handprint = $handprint * 256 + ord($_) for split //, $lbi->get_handprint;
    push @infos, $handprint;

    # 4. version number.
    my $ver = $Language::Befunge::VERSION;
    $ver =~ s/\D//g;
    push @infos, $ver;

    # 5. ID code for Operating Paradigm.
    push @infos, 1;             # C-language system() call behaviour.

    # 6. Path separator character.
    push @infos, ord( catfile('','') );

    # 7. Number of dimensions.
    push @infos, $ip->get_dims;

    # 8. Unique IP number.
    push @infos, $ip->get_id;

    # 9. Unique team number for the IP (NetFunge, not implemented).
    push @infos, 0;

    # 10. Position of the curent IP.
    my @pos = ( $ip->get_position->get_all_components );
    push @infos, \@pos;

    # 11. Delta of the curent IP.
    my @delta = ( $ip->get_delta->get_all_components );
    push @infos, \@delta;

    # 12. Storage offset of the curent IP.
    my @stor = ( $ip->get_storage->get_all_components );
    push @infos, \@stor;

    # 13. Top-left point.
    my $min = $storage->min;
    # FIXME: multiple dims?
    my @topleft = ( $min->get_component(0), $min->get_component(1) );
    push @infos, \@topleft;

    # 14. Dims of the storage.
    my $max = $storage->max;
    # FIXME: multiple dims?
    my @dims = ( $max->get_component(0) - $min->get_component(0),
                 $max->get_component(1) - $min->get_component(1) );
    push @infos, \@dims;

    # 15/16. Current date/time.
    my ($s,$m,$h,$dd,$mm,$yy)=localtime;
    push @infos, $yy*256*256 + $mm*256 + $dd;
    push @infos, $h*256*256 + $m*256 + $s;

    # 17. Size of stack stack.
    push @infos, $ip->ss_count + 1;

    # 18. Size of each stack in the stack stack.
    # note: the number of stack is given by previous value.
    my @sizes = reverse $ip->ss_sizes;
    push @infos, \@sizes;

    # 19. $file + params.
    my $str = join chr(0), $lbi->get_file, @{$lbi->get_params}, chr(0)x2;
    my @cmdline = reverse map { ord } split //, $str;
    push @infos, \@cmdline;

    # 20. %ENV
    # 00EULAV=EMAN0EULAV=EMAN
    $str = "";
    $str .= "$_=$ENV{$_}".chr(0) foreach sort keys %ENV;
    $str .= chr(0);
    my @env = reverse map { ord } split //, $str;
    push @infos, \@env;

    my @cells = map { ref($_) eq 'ARRAY' ? (@$_) : ($_) } reverse @infos;

    # Okay, what to do with those cells.
    if ( $val <= 0 ) {
        # Blindly push them onto the stack.
        $lbi->debug( "system info: pushing the whole stuff\n" );
        $ip->spush(@cells);

    } elsif ( $val <= scalar(@cells) ) {
        # Only push the wanted value.
        $lbi->debug( "system info: pushing the ${val}th value\n" );
        $ip->spush( $cells[$#cells-$val+1] );

    } else {
        # Pick a given value in the stack and push it.
        my $offset = $val - $#cells - 1;
        my $value  = $ip->svalue($offset);
        $lbi->debug( "system info: picking the ${offset}th value from the stack = $value\n" );
        $ip->spush( $value );
    }
}

=back



=head2 Concurrent Funge

=over 4

=item spawn_ip(  )

=cut
sub spawn_ip {
    my ($lbi) = @_;

    # Cosmetics.
    $lbi->debug( "spawning new IP\n" );

    # Cloning and storing new IP.
    my $newip = $lbi->get_curip->clone;
    $newip->dir_reverse;
    $lbi->move_ip($newip);
    push @{ $lbi->get_newips }, $newip;
}

=back



=head2 Library semantics

=over 4

=item lib_load(  )

=cut
sub lib_load {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching fingerprint.
    my $count = $ip->spop;
    my $fgrprt = 0;
    while ( $count-- > 0 ) {
        my $val = $ip->spop;
        $lbi->abort( "Attempt to build a fingerprint with a negative number" )
          if $val < 0;
        $fgrprt = $fgrprt * 256 + $val;
    }

    # Transform the fingerprint into a library name.
    my $lib = "";
    my $finger = $fgrprt;
    while ( $finger > 0 ) {
        my $c = $finger % 0x100;
        $lib .= chr($c);
        $finger = int ( $finger / 0x100 );
    }
    $lib = "Language::Befunge::lib::" . reverse $lib;

    # Checking if library exists.
    eval "require $lib";
    if ( $@ ) {
        $lbi->debug( sprintf("unknown extension $lib (0x%x): reversing\n", $fgrprt) );
        $ip->dir_reverse;
    } else {
        $lbi->debug( sprintf("extension $lib (0x%x) loaded\n", $fgrprt) );
        my $obj = new $lib;
        $ip->load( $obj );
        $ip->spush( $fgrprt, 1 );
    }
}


=item lib_unload(  )

=cut
sub lib_unload {
    my ($lbi) = @_;
    my $ip = $lbi->get_curip;

    # Fetching fingerprint.
    my $count = $ip->spop;
    my $fgrprt = 0;
    while ( $count-- > 0 ) {
        my $val = $ip->spop;
        $lbi->abort( "Attempt to build a fingerprint with a negative number" )
          if $val < 0;
        $fgrprt = $fgrprt * 256 + $val;
    }

    # Transform the fingerprint into a library name.
    my $lib = "";
    my $finger = $fgrprt;
    while ( $finger > 0 ) {
        my $c = $finger % 0x100;
        $lib .= chr($c);
        $finger = int ( $finger / 0x100 );
    }
    $lib = "Language::Befunge::lib::" . reverse $lib;

    # Unload the library.
    if ( defined( $ip->unload($lib) ) ) {
        $lbi->debug( sprintf("unloading library $lib (0x%x)\n", $fgrprt) );
    } else {
        # The library wasn't loaded.
        $lbi->debug( sprintf("library $lib (0x%x) wasn't loaded\n", $fgrprt) );
        $ip->dir_reverse;
    }
}

=item lib_run_instruction( )

=cut

sub lib_run_instruction {
    my ($lbi) = @_;
    my $ip   = $lbi->get_curip;
    my $char = $lbi->storage->get_char( $ip->get_position );

    # Maybe a library semantics.
    $lbi->debug( "library semantics\n" );

    foreach my $obj ( @{ $ip->get_libs } ) {
        # Try the loaded libraries in order.
        eval "\$obj->$char(\$lbi)";
        if( $@ ) {
            $lbi->debug( ref($obj) . "->$char failed: $@" );
            next;
        }

        # We manage to get a library.
        $lbi->debug( "library semantics processed by ".ref($obj)."\n" );
        return;
    }

    # Non-overloaded capitals default to reverse.
    $lbi->debug("no library semantics found: reversing\n");
    $ip->dir_reverse;
}

=back

=cut

1;

__END__

=head1 SEE ALSO

L<Language::Befunge>


=head1 AUTHOR

Jerome Quelin, E<lt>jquelin@cpan.orgE<gt>

Development is discussed on E<lt>language-befunge@mongueurs.netE<gt>


=head1 COPYRIGHT & LICENSE

Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

