# $Id: Befunge.pm,v 1.16 2006/02/17 13:53:05 jquelin Exp $
#
# Copyright (c) 2002 Jerome Quelin <jquelin@cpan.org>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package Language::Befunge;
require 5.006;

=head1 NAME

Language::Befunge - a Befunge-98 interpreter


=head1 SYNOPSIS

    use Language::Befunge;
    my $interp = new Language::Befunge( "program.bf" );
    $interp->run_code( "param", 7, "foo" );

    Or, one can write directly:
    my $interp = new Language::Befunge;
    $interp->store_code( <<'END_OF_CODE' );
    < @,,,,"foo"a
    END_OF_CODE
    $interp->run_code;


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

This module also implements the Concurrent Funge semantics.

=cut
use strict;
use warnings;

# Modules we rely upon.
use Carp;     # This module can't explode :o)
use Config;   # For the 'y' instruction.
use Language::Befunge::IP;
use Language::Befunge::LaheySpace;

# Public variables of the module.
our $VERSION   = '2.01';
our $HANDPRINT = 'JQBF98'; # the handprint of the interpreter.
our $AUTOLOAD;
our %meths;
$| = 1;


=head1 CONSTRUCTOR

=head2 new( [filename] )

Create a new Befunge interpreter. If a filename is provided, then read
and store the content of the file in the cartesian Lahey space
topology of the interpreter.

=cut
sub new {
    # Create and bless the object.
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = 
      { file     => "STDIN",
        params   => [],
        retval   => 0,
        DEBUG    => 0,
        curip    => undef,
        lastip   => undef,
        ips      => [],
        newips   => [],
        torus    => new Language::Befunge::LaheySpace,
      };
    bless $self, $class;

    # Read the file if needed.
    my $file = shift;
    defined($file) and $self->read_file( $file );

    # Return the object.
    return $self;
}



=head1 ACCESSORS

The following is a list of attributes of a Language::Befunge. For each
of them, a method C<get_foobar> and C<set_foobar> exists, which does
what you can imagine - and if you can't, then i wonder why you are
reading this! :-)

=over 4

=item file:

the script filename (a string)

=item params:

the parameters of the script (an array reference)

=item retval:

the current return value of the interpreter (an integer)

=item DEBUG:

wether the interpreter should output debug messages (a boolean)

=item curip:

the current Instruction Pointer processed (a L::B::IP object)

=item lastip:

the last Instruction Pointer, when C<@> or C<q> instructions are
encountered (a L::B::IP object)

=item ips:

the current set of IPs travelling in the Lahey space (an array
reference)

=item newips:

the set of IPs that B<will> travel in the Lahey space B<after> the
current tick (an array reference)

=item torus:

the current Lahey space (a L::B::LaheySpace object)

=back

=cut
BEGIN {
    my @attrs = qw[ file params retval DEBUG curip lastip ips newips torus ];
    foreach my $attr ( @attrs ) {
        my $code = qq[ sub get_$attr { return \$_[0]->{$attr} } ];
        $code .= qq[ sub set_$attr { \$_[0]->{$attr} = \$_[1] } ];
        eval $code;
    }
}



=head1 PUBLIC METHODS

=head2 Utilities

=over 4

=item move_curip( [regex] )

Move the current IP according to its delta on the LaheySpace topology.

If a regex ( a C<qr//> object ) is specified, then IP will move as
long as the pointed character match the supplied regex.

Example: given the code C<;foobar;> (assuming the IP points on the
first C<;>) and the regex C<qr/[^;]/>, the IP will move in order to
point on the C<r>.

=cut
sub move_curip {
    my ($self, $re) = @_;
    my $curip = $self->get_curip;
    my $torus = $self->get_torus;

    if ( defined $re ) {
        my ($origx, $origy) = ($curip->curx, $curip->cury);
        # Moving as long as we did not reach the condition.
        while ( $torus->get_char($curip->curx, $curip->cury) =~ $re ) {
            $torus->move_ip_forward($curip);
            $self->abort("infinite loop")
                if ( ($curip->curx == $origx) && ($curip->cury == $origy) );
        }

        # We moved one char too far.
        $curip->dir_reverse;
        $torus->move_ip_forward($curip);
        $curip->dir_reverse;

    } else {
        # Moving one step beyond...
        $torus->move_ip_forward($curip);
    }
}


=item abort( reason )

Abort the interpreter with the given reason, as well as the current
file and coordinate of the offending instruction.

=cut
sub abort {
    my $self = shift;
    my $file = $self->get_file;
    my $x = $self->get_curip->curx;
    my $y = $self->get_curip->cury;
    croak "$file ($x,$y): ", @_;
}


=item debug( LIST )

Issue a warning if the interpreter has DEBUG enabled.

=cut
sub debug {
    my $self = shift;
    $self->get_DEBUG or return;
    warn @_;
}

=back



=head2 Code and Data Storage

=over 4

=item read_file( filename )

Read a file (given as argument) and store its code.

Side effect: clear the previous code.

=cut
sub read_file {
    my ($self, $file) = @_;

    # Fetch the code.
    my $code;
    open BF, "<$file" or croak "$!";
    {
        local $/; # slurp mode.
        $code = <BF>;
    }
    close BF;

    # Store code.
    $self->set_file( $file );
    $self->store_code( $code );
}


=item store_code( code )

Store the given code in the Lahey space.

Side effect: clear the previous code.

=cut
sub store_code {
    my ($self, $code) = @_;
    $self->debug( "Storing code\n" );
    $self->get_torus->clear;
    $self->get_torus->store( $code );
}

=back



=head2 Run methods

=over 4

=item run_code( [params]  )

Run the current code. That is, create a new Instruction Pointer and
move it around the code.

Return the exit code of the program.

=cut
sub run_code {
    my $self = shift;
    $self->set_params( [ @_ ] );

    # Cosmetics.
    $self->debug( "\n-= NEW RUN (".$self->get_file.") =-\n" );

    # Create the first Instruction Pointer.
    $self->set_ips( [ new Language::Befunge::IP ] );
    $self->set_retval(0);

    # Loop as long as there are IPs.
    $self->next_tick while scalar @{ $self->get_ips };

    # Return the exit code.
    return $self->get_retval;
}


=item next_tick(  )

Finish the current tick and stop just before the next tick.

=cut
sub next_tick {
    my $self = shift;

    # Cosmetics.
    $self->debug( "Tick!\n" );

    # Process the set of IPs.
    $self->set_newips( [] );
    $self->process_ip while $self->set_curip( shift @{ $self->get_ips } );

    # Copy the new ips.
    $self->set_ips( $self->get_newips );
}


=item process_ip(  )

Process the current ip.

=cut
sub process_ip {
    my ($self, $continue) = @_;
    $continue = 1 unless defined $continue;
    my $ip = $self->get_curip;

    # Fetch values for this IP.
    my $x  = $ip->curx;
    my $y  = $ip->cury;
    my $ord  = $self->get_torus->get_value( $x, $y );
    my $char = $self->get_torus->get_char( $x, $y );

    # Cosmetics.
    $self->debug( "#".$ip->id.":($x,$y): $char (ord=$ord)  Stack=(@{$ip->toss})\n" );

    # Check if we are in string-mode.
    if ( $ip->string_mode ) {
        if ( $char eq '"' ) {
            # End of string-mode.
            $self->debug( "leaving string-mode\n" );
            $ip->string_mode(0);

        } elsif ( $char eq ' ' ) {
            # A serie of spaces, to be treated as one space.
            $self->debug( "string-mode: pushing char ' '\n" );
            $self->move_curip( qr/ / );
            $ip->spush( $ord );

        } else {
            # A banal character.
            $self->debug( "string-mode: pushing char '$char'\n" );
            $ip->spush( $ord );                 
        }

    } else {
        # Not in string-mode.
        if ( exists $meths{$char} ) {
            # Regular instruction.
            my $meth = $meths{$char};
            $self->$meth;

        } elsif ( $char =~ /[A-Z]/ ) {
            # Maybe a library semantics.
            $self->debug( "library semantics\n" );

            my $found = 0;
            foreach my $obj ( @{ $ip->libs } ) {
                # Try the loaded libraries in order.
                eval "\$obj->$char(\$self)";
                next if $@; # Uh, this wasn't the good one.

                # We manage to get a library.
                $found = 1;
                $self->debug( "library semantics processed by ".ref($obj)."\n" );
                $found++;
                last;
            }

            # Non-overloaded capitals default to reverse.
            $ip->dir_reverse, $self->debug("no library semantics found: reversing\n") 
              unless $found;

        } else {
            # Not a regular instruction: reflect.
            $self->debug( "the command value $ord (char='$char') is not implemented.\n");
            $ip->dir_reverse;
        }
    }

    if($continue) {
        # Tick done for this IP, let's move it and push it in the
        # set of non-terminated IPs.
        $self->move_curip;
        push @{ $self->get_newips }, $ip unless $ip->end;
    }
}


=back



=head1 INSTRUCTION IMPLEMENTATIONS

=head2 Numbers

=over 4

=item op_num_push_number(  )

Push the current number onto the TOSS.

=cut
sub op_num_push_number {
    my $self = shift;

    # Fetching char.
    my $ip  = $self->get_curip;
    my $num = hex( chr( $self->get_torus->get_value( $ip->curx, $ip->cury ) ) );

    # Pushing value.
    $ip->spush( $num );

    # Cosmetics.
    $self->debug( "pushing number '$num'\n" );
}
@meths{0..9} = ("op_num_push_number") x 10;
@meths{"a".."f"} = ("op_num_push_number") x 6;

=back



=head2 Strings

=over 4

=item op_str_enter_string_mode(  )

=cut
sub op_str_enter_string_mode {
    my $self = shift;

    # Cosmetics.
    $self->debug( "entering string mode\n" );

    # Entering string-mode.
    $self->get_curip->string_mode(1);
}
$meths{'"'} = "op_str_enter_string_mode";


=item op_str_fetch_char(  )

=cut
sub op_str_fetch_char {
    my $self = shift;
    my $ip = $self->get_curip;

    # Moving pointer...
    $self->move_curip;
 
   # .. then fetch value and push it.
    my $ord = $self->get_torus->get_value( $ip->curx, $ip->cury );
    my $chr = $self->get_torus->get_char( $ip->curx, $ip->cury );
    $ip->spush( $ord );

    # Cosmetics.
    $self->debug( "pushing value $ord (char='$chr')\n" );
}
$meths{"'"} = "op_str_fetch_char";


=item op_str_store_char(  )

=cut
sub op_str_store_char {
    my $self = shift;
    my $ip = $self->get_curip;

    # Moving pointer.
    $self->move_curip;

    # Fetching value.
    my $val = $ip->spop;

    # Storing value.
    $self->get_torus->set_value( $ip->curx, $ip->cury, $val );
    my $chr = $self->get_torus->get_char( $ip->curx, $ip->cury );

    # Cosmetics.
    $self->debug( "storing value $val (char='$chr')\n" );
}
$meths{'s'} = "op_str_store_char";

=back



=head2 Mathematical operations

=over 4

=item op_math_addition(  )

=cut
sub op_math_addition {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_vec;
    $self->debug( "adding: $v1+$v2\n" );
    my $res = $v1 + $v2;

    # Checking over/underflow.
    $res > 2**31-1 and $self->abort( "program overflow while performing addition" );
    $res < -2**31  and $self->abort( "program underflow while performing addition" );

    # Pushing value.
    $ip->spush( $res );
}
$meths{'+'} = "op_math_addition";


=item op_math_substraction(  )

=cut
sub op_math_substraction {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_vec;
    $self->debug( "substracting: $v1-$v2\n" );
    my $res = $v1 - $v2;

    # checking over/underflow.
    $res > 2**31-1 and $self->abort( "program overflow while performing substraction" );
    $res < -2**31  and $self->abort( "program underflow while performing substraction" );

    # Pushing value.
    $ip->spush( $res );
}
$meths{'-'} = "op_math_substraction";


=item op_math_multiplication(  )

=cut
sub op_math_multiplication {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_vec;
    $self->debug( "multiplicating: $v1*$v2\n" );
    my $res = $v1 * $v2;

    # checking over/underflow.
    $res > 2**31-1 and $self->abort( "program overflow while performing multiplication" );
    $res < -2**31  and $self->abort( "program underflow while performing multiplication" );

    # Pushing value.
    $ip->spush( $res );
}
$meths{'*'} = "op_math_multiplication";


=item op_math_division(  )

=cut
sub op_math_division {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_vec;
    $self->debug( "dividing: $v1/$v2\n" );
    my $res = $v2 == 0 ? 0 : int($v1 / $v2);

    # Can't do over/underflow with integer division.

    # Pushing value.
    $ip->spush( $res );
}
$meths{'/'} = "op_math_division";


=item op_math_remainder(  )

=cut
sub op_math_remainder {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_vec;
    $self->debug( "remainder: $v1%$v2\n" );
    my $res = $v2 == 0 ? 0 : int($v1 % $v2);

    # Can't do over/underflow with integer remainder.

    # Pushing value.
    $ip->spush( $res );
}
$meths{'%'} = "op_math_remainder";

=back



=head2 Direction changing

=over 4

=item op_dir_go_east(  )

=cut
sub op_dir_go_east {
    my $self = shift;
    $self->debug( "going east\n" );
    $self->get_curip->dir_go_east;
}
$meths{'>'} = "op_dir_go_east";


=item op_dir_go_west(  )

=cut
sub op_dir_go_west {
    my $self = shift;
    $self->debug( "going west\n" );
    $self->get_curip->dir_go_west;
}
$meths{'<'} = "op_dir_go_west";


=item op_dir_go_north(  )

=cut
sub op_dir_go_north {
    my $self = shift;
    $self->debug( "going north\n" );
    $self->get_curip->dir_go_north;
}
$meths{'^'} = "op_dir_go_north";


=item op_dir_go_south(  )

=cut
sub op_dir_go_south {
    my $self = shift;
    $self->debug( "going south\n" );
    $self->get_curip->dir_go_south;
}
$meths{'v'} = "op_dir_go_south";


=item op_dir_go_away(  )

=cut
sub op_dir_go_away {
    my $self = shift;
    $self->debug( "going away!\n" );
    $self->get_curip->dir_go_away;
}
$meths{'?'} = "op_dir_go_away";


=item op_dir_turn_left(  )

Turning left, like a car (the specs speak about a bicycle, but perl
is _so_ fast that we can speak about cars ;) ).

=cut
sub op_dir_turn_left {
    my $self = shift;
    $self->debug( "turning on the left\n" );
    $self->get_curip->dir_turn_left;
}
$meths{'['} = "op_dir_turn_left";


=item op_dir_turn_right(  )

Turning right, like a car (the specs speak about a bicycle, but perl
is _so_ fast that we can speak about cars ;) ).

=cut
sub op_dir_turn_right {
    my $self = shift;
    $self->debug( "turning on the right\n" );
    $self->get_curip->dir_turn_right;
}
$meths{']'} = "op_dir_turn_right";


=item op_dir_reverse(  )

=cut
sub op_dir_reverse {
    my $self = shift;
    $self->debug( "180 deg!\n" );
    $self->get_curip->dir_reverse;
}
$meths{'r'} = "op_dir_reverse";


=item op_dir_set_delta(  )

Hmm, the user seems to know where he wants to go. Let's trust him/her.

=cut
sub op_dir_set_delta {
    my $self = shift;
    my $ip = $self->get_curip;
    my ($new_dx, $new_dy) = $ip->spop_vec;
    $self->debug( "setting delta to ($new_dx, $new_dy)\n" );
    $ip->set_delta( $new_dx, $new_dy );
}
$meths{'x'} = "op_dir_set_delta";

=back



=head2 Decision making

=over 4

=item op_decis_neg(  )

=cut
sub op_decis_neg {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching value.
    my $val = $ip->spop ? 0 : 1;
    $ip->spush( $val );

    $self->debug( "logical not: pushing $val\n" );
}
$meths{'!'} = "op_decis_neg";


=item op_decis_gt(  )

=cut
sub op_decis_gt {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching values.
    my ($v1, $v2) = $ip->spop_vec;
    $self->debug( "comparing $v1 vs $v2\n" );
    $ip->spush( ($v1 > $v2) ? 1 : 0 );
}
$meths{'`'} = "op_decis_gt";


=item op_decis_horiz_if(  )

=cut
sub op_decis_horiz_if {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching value.
    my $val = $ip->spop;
    $val ? $ip->dir_go_west : $ip->dir_go_east;
    $self->debug( "horizontal if: going " . ( $val ? "west\n" : "east\n" ) );
}
$meths{'_'} = "op_decis_horiz_if";


=item op_decis_vert_if(  )

=cut
sub op_decis_vert_if {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching value.
    my $val = $ip->spop;
    $val ? $ip->dir_go_north : $ip->dir_go_south;
    $self->debug( "vertical if: going " . ( $val ? "north\n" : "south\n" ) );
}
$meths{'|'} = "op_decis_vert_if";


=item op_decis_cmp(  )

=cut
sub op_decis_cmp {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching value.
    my ($v1, $v2) = $ip->spop_vec;
    $self->debug( "comparing $v1 with $v2: straight forward!\n"), return if $v1 == $v2;

    my $dir;
    if ( $v1 < $v2 ) {
        $ip->dir_turn_left;
        $dir = "left";
    } else {
        $ip->dir_turn_right;
        $dir = "right";
    }
    $self->debug( "comparing $v1 with $v2: turning: $dir\n" );
}
$meths{'w'} = "op_decis_cmp";

=back



=head2 Flow control

=over 4

=item op_flow_space(  )

A serie of spaces is to be treated as B<one> NO-OP.

=cut
sub op_flow_space {
    my $self = shift;
    $self->move_curip( qr/ / );
    $self->debug( "slurping serie of spaces\n" );
}
$meths{' '} = "op_flow_space";


=item op_flow_no_op(  )

=cut
sub op_flow_no_op {
    my $self = shift;
    $self->debug( "no-op\n" );
}
$meths{'z'} = "op_flow_no_op";


=item op_flow_comments(  )

Bypass comments in one tick.

=cut
sub op_flow_comments {
    my $self = shift;
    $self->move_curip;
    $self->move_curip( qr/[^;]/ );
    $self->move_curip;
    $self->debug( "skipping comments\n" );
}
$meths{';'} = "op_flow_comments";


=item op_flow_trampoline(  )

=cut
sub op_flow_trampoline {
    my $self = shift;
    $self->move_curip;
    $self->debug( "trampoline! (skipping next instruction)\n" );
}
$meths{'#'} = "op_flow_trampoline";


=item op_flow_jump_to(  )

=cut
sub op_flow_jump_to {
    my $self = shift;
    my $ip = $self->get_curip;
    my $count = $ip->spop;
    $self->debug( "skipping $count instructions\n" );
    $count == 0 and return;
    $count < 0  and $ip->dir_reverse; # We can move backward.
    $self->move_curip for (1..abs($count));
    $count < 0  and $self->move_curip, $ip->dir_reverse;
}
$meths{'j'} = "op_flow_jump_to";


=item op_flow_repeat(  )

=cut
sub op_flow_repeat {
    my $self = shift;
    my $ip = $self->get_curip;

    my $kcounter = $ip->spop;
    $self->debug( "repeating next instruction $kcounter times.\n" );
    $self->move_curip;

    # Nothing to repeat.
    $kcounter == 0 and return;

    # Ooops, error.
    $kcounter < 0 and $self->abort( "Attempt to repeat ('k') a negative number of times ($kcounter)" );

    # Fetch instruction to repeat.
    my $val = $self->get_torus->get_value( $ip->curx, $ip->cury );

    # Check if we can repeat the instruction.
    $val > 0 and $val < 256 and chr($val) =~ /([ ;])/ and
      $self->abort( "Attempt to repeat ('k') a forbidden instruction ('$1')" );
    $val > 0 and $val < 256 and chr($val) eq "k" and
      $self->abort( "Attempt to repeat ('k') a repeat instruction ('k')" );

    $self->process_ip(0) for (1..$kcounter);
}
$meths{'k'} = "op_flow_repeat";


=item op_flow_kill_thread(  )

=cut
sub op_flow_kill_thread {
    my $self = shift;
    $self->debug( "end of Instruction Pointer\n" );
    $self->get_curip->end('@');
    $self->set_lastip( $self->get_curip );
}
$meths{'@'} = "op_flow_kill_thread";


=item op_flow_quit(  )

=cut
sub op_flow_quit {
    my $self = shift;
    $self->debug( "end program\n" );
    $self->set_newips( [] );
    $self->set_ips( [] );
    $self->get_curip->end('q');
    $self->set_retval( $self->get_curip->spop );
    $self->set_lastip( $self->get_curip );
}
$meths{'q'} = "op_flow_quit";

=back



=head2 Stack manipulation

=over 4

=item op_stack_pop(  )

=cut
sub op_stack_pop {
    my $self = shift;
    $self->debug( "popping a value\n" );
    $self->get_curip->spop;
}
$meths{'$'} = "op_stack_pop";


=item op_stack_duplicate(  )

=cut
sub op_stack_duplicate {
    my $self = shift;
    my $ip = $self->get_curip;
    my $value = $ip->spop;
    $self->debug( "duplicating value '$value'\n" );
    $ip->spush( $value );
    $ip->spush( $value );
}
$meths{':'} = "op_stack_duplicate";


=item op_stack_swap(  )

=cut
sub op_stack_swap {
    my $self = shift;
    my $ ip = $self->get_curip;
    my ($v1, $v2) = $ip->spop_vec;
    $self->debug( "swapping $v1 and $v2\n" );
    $ip->spush( $v2 );
    $ip->spush( $v1 );
}
$meths{'\\'} = "op_stack_swap";


=item op_stack_clear(  )

=cut
sub op_stack_clear {
    my $self = shift;
    $self->debug( "clearing stack\n" );
    $self->get_curip->sclear;
}
$meths{'n'} = "op_stack_clear";

=back



=head2 Stack stack manipulation

=over 4

=item op_block_open(  )

=cut
sub op_block_open {
    my $self = shift;
    my $ip = $self->get_curip;
    $self->debug( "block opening\n" );

    # Create new TOSS.
    $ip->ss_create( $ip->spop );

    # Store current storage offset on SOSS.
    $ip->soss_push( $ip->storx );
    $ip->soss_push( $ip->story );

    # Set the new Storage Offset.
    $self->move_curip;
    $ip->storx( $ip->curx );
    $ip->story( $ip->cury );
    $ip->dir_reverse;
    $self->move_curip;
    $ip->dir_reverse;
}
$meths{'{'} = "op_block_open";


=item op_block_close(  )

=cut
sub op_block_close {
    my $self = shift;
    my $ip = $self->get_curip;

    # No opened block.
    $ip->ss_count <= 0 and $ip->dir_reverse, $self->debug("no opened block\n"), return;

    $self->debug( "block closing\n" );

    # Restore Storage offset.
    $ip->story( $ip->soss_pop );
    $ip->storx( $ip->soss_pop );

    # Remove the TOSS.
    $ip->ss_remove( $ip->spop );
}
$meths{'}'} = "op_block_close";


=item op_bloc_transfer(  )

=cut
sub op_bloc_transfer {
    my $self = shift;
    my $ip = $self->get_curip;

    $ip->ss_count <= 0 and $ip->dir_reverse, $self->debug("no SOSS available\n"), return;

    # Transfering values.
    $self->debug( "transfering values\n" );
    $ip->ss_transfer( $ip->spop );
}
$meths{'u'} = "op_bloc_transfer";

=back



=head2 Funge-space storage

=over 4

=item op_store_get(  )

=cut
sub op_store_get {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching coordinates.
    my ($x, $y) = $ip->spop_vec;
    $x += $ip->storx;
    $y += $ip->story;

    # Fetching char.
    my $val = $self->get_torus->get_value( $x, $y );
    $ip->spush( $val );

    $self->debug( "fetching value at ($x,$y): pushing $val\n" );
}
$meths{'g'} = "op_store_get";


=item op_store_put(  )

=cut
sub op_store_put {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching coordinates.
    my ($x, $y) = $ip->spop_vec;
    $x += $ip->storx;
    $y += $ip->story;

    # Fetching char.
    my $val = $ip->spop;
    $self->get_torus->set_value( $x, $y, $val );

    $self->debug( "storing value $val at ($x,$y)\n" );
}
$meths{'p'} = "op_store_put";

=back



=head2 Standard Input/Output

=over 4

=item op_stdio_out_num(  )

=cut
sub op_stdio_out_num {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetch value and print it.
    my $val = $ip->spop;
    $self->debug( "numeric output: $val\n");
    print( "$val " ) or $ip->dir_reverse;
}
$meths{'.'} = "op_stdio_out_num";


=item op_stdio_out_ascii(  )

=cut
sub op_stdio_out_ascii {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetch value and print it.
    my $val = $ip->spop;
    my $chr = chr $val;
    $self->debug( "ascii output: '$chr' (ord=$val)\n");
    print( $chr ) or $ip->dir_reverse;
}
$meths{','} = "op_stdio_out_ascii";


=item op_stdio_in_num(  )

=cut
sub op_stdio_in_num {
    my $self = shift;
    my $ip = $self->get_curip;
    my ($in, $nb);
    while ( not defined($nb) ) {
        $in = $ip->input || <STDIN> while not $in;
        if ( $in =~ s/^.*?(-?\d+)// ) {
            $nb = $1;
            $nb < -2**31  and $nb = -2**31;
            $nb > 2**31-1 and $nb = 2**31-1;
        } else {
            $in = "";
        }
        $ip->input( $in );
    }
    $ip->spush( $nb );
    $self->debug( "numeric input: pushing $nb\n" ); 
}
$meths{'&'} = "op_stdio_in_num";


=item op_stdio_in_ascii(  )

=cut
sub op_stdio_in_ascii {
    my $self = shift;
    my $ip = $self->get_curip;
    my $in;
    $in = $ip->input || <STDIN> while not $in;
    my $chr = substr $in, 0, 1, "";
    my $ord = ord $chr;
    $ip->spush( $ord );
    $ip->input( $in );
    $self->debug( "ascii input: pushing '$chr' (ord=$ord)\n" ); 
}
$meths{'~'} = "op_stdio_in_ascii";


=item op_stdio_in_file(  )

=cut
sub op_stdio_in_file {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetch arguments.
    my $path = $ip->spop_gnirts;
    my $flag = $ip->spop;
    my ($xin, $yin) = $ip->spop_vec;
    $xin += $ip->storx;
    $yin += $ip->story;

    # Read file.
    $self->debug( "input file '$path' at ($xin,$yin)\n" );
    open F, "<", $path or $ip->dir_reverse, return;
    my $lines;
    {
        local $/; # slurp mode.
        $lines = <F>;
    }
    close F or $ip->dir_reverse, return;

    # Store the code and the result vector.
    my ($wid, $hei) = $flag % 2
        ? ( $self->get_torus->store_binary( $lines, $xin, $yin ) )
        : ( $self->get_torus->store( $lines, $xin, $yin ) );
    $ip->spush( $wid, $hei, $xin, $yin );
}
$meths{'i'} = "op_stdio_in_file";


=item op_stdio_out_file(  )

=cut
sub op_stdio_out_file {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetch arguments.
    my $path = $ip->spop_gnirts;
    my $flag = $ip->spop;
    my ($xin, $yin) = $ip->spop_vec;
    $xin += $ip->storx;
    $yin += $ip->story;
    my ($hei, $wid) = $ip->spop_vec;
    my $data = $self->get_torus->rectangle( $xin, $yin, $wid, $hei );

    # Cosmetics.
    my $x2 = $xin + $wid;
    my $y2 = $yin + $hei;
    $self->debug( "output ($xin,$yin)-($x2,$y2) to '$path'\n" );

    # Treat the data chunk as text file?
    if ( $flag & 0x1 ) {
        $data =~ s/ +$//mg;    # blank lines are now void.
        $data =~ s/\n+\z/\n/;  # final blank lines are stripped.
    }

    # Write file.
    open F, ">", $path or $ip->dir_reverse, return;
    print F $data;
    close F or $ip->dir_reverse, return;
}
$meths{'o'} = "op_stdio_out_file";


=item op_stdio_sys_exec(  )

=cut
sub op_stdio_sys_exec {
    my $self = shift;
    my $ip = $self->get_curip;
    
    # Fetching command.
    my $path = $ip->spop_gnirts;
    $self->debug( "spawning external command: $path\n" );
    system( $path );
    $ip->spush( $? == -1 ? -1 : $? >> 8 );
}
$meths{'='} = "op_stdio_sys_exec";

=back



=head2 System info retrieval

=over 4

=item op_sys_info(  )

=cut
sub op_sys_info {
    my $self = shift;
    my $ip    = $self->get_curip;
    my $torus = $self->get_torus;

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
    push @cells, 1;             # C-language system() call behaviour.

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
    my @topleft = ( $torus->{xmin}, $torus->{ymin} );
    push @cells, \@topleft;

    # 14. Dims of the torus.
    my @dims = ( $torus->{xmax} - $torus->{xmin} + 1,
                 $torus->{ymax} - $torus->{ymin} + 1 );
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
                    
    # 19. $file + params.
    my $str = join chr(0), $self->get_file, @{$self->get_params}, chr(0);
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
        # Blindly push them onto the stack.
        $self->debug( "system info: pushing the whole stuff\n" );
        foreach my $cell ( reverse @cells ) {
            $ip->spush( ref( $cell ) eq "ARRAY" ?
                        @$cell : $cell );
        }

    } elsif ( $val <= 20 ) {
        # Only push the wanted value.
        $self->debug( "system info: pushing the ${val}th value\n" );
        $ip->spush( ref( $cells[$val-1] ) eq "ARRAY" ?
                    @{ $cells[$val-1] } : $cells[$val-1] );

    } else {
        # Pick a given value in the stack and push it.
        my $offset = $val - 20;
        my $value  = $ip->svalue($offset);
        $self->debug( "system info: picking the ${offset}th value from the stack = $value\n" );
        $ip->spush( $value );
    }
}
$meths{'y'} = "op_sys_info";

=back



=head2 Concurrent Funge

=over 4

=item op_spawn_ip(  )

=cut
sub op_spawn_ip {
    my $self = shift;

    # Cosmetics.
    $self->debug( "spawning new IP\n" );

    # Cloning and storing new IP.
    my $newip = $self->get_curip->clone;
    $newip->dir_reverse;
    $self->get_torus->move_ip_forward($newip);
    push @{ $self->get_newips }, $newip;
}
$meths{'t'} = "op_spawn_ip";

=back



=head2 Library semantics

=over 4

=item op_lib_load(  )

=cut
sub op_lib_load {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching fingerprint.
    my $count = $ip->spop;
    my $fgrprt = 0;
    while ( $count-- > 0 ) {
        my $val = $ip->spop;
        $self->abort( "Attempt to build a fingerprint with a negative number" )
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
    $lib = __PACKAGE__ . "::lib::" . reverse $lib;

    # Checking if library exists.
    eval "require $lib";
    if ( $@ ) {
        $self->debug( sprintf("unknown extension $lib (0x%x): reversing\n", $fgrprt) );
        $ip->dir_reverse;
    } else {
        $self->debug( sprintf("extension $lib (0x%x) loaded\n", $fgrprt) );
        my $obj = new $lib;
        $ip->load( $obj );
        $ip->spush( $fgrprt, 1 );
    }
}
$meths{'('} = "op_lib_load";


=item op_lib_unload(  )

=cut
sub op_lib_unload {
    my $self = shift;
    my $ip = $self->get_curip;

    # Fetching fingerprint.
    my $count = $ip->spop;
    my $fgrprt = 0;
    while ( $count-- > 0 ) {
        my $val = $ip->spop;
        $self->abort( "Attempt to build a fingerprint with a negative number" )
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
    $lib = __PACKAGE__ . "::lib::" . reverse $lib;

    # Unload the library.
    if ( defined( $ip->unload($lib) ) ) {
        $self->debug( sprintf("unloading library $lib (0x%x)\n", $fgrprt) );
    } else {
        # The library wasn't loaded.
        $self->debug( sprintf("library $lib (0x%x) wasn't loaded\n", $fgrprt) );
        $ip->dir_reverse;
    }
}
$meths{')'} = "op_lib_unload";

=back

=cut


1;
__END__


=head1 TODO

=over 4

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

About the load semantics. Once a library is loaded, the interpreter is
to put onto the TOSS the fingerprint of the just-loaded library. But
nothing is said if the fingerprint is bigger than the maximum cell
width (here, 4 bytes). This means that libraries can't have a name
bigger than C<0x80000000>, ie, more than four letters with the first
one smaller than C<P> (C<chr(80)>).

Since perl is not so rigid, one can build libraries with more than
four letters, but perl will issue a warning about non-portability of
numbers greater than C<0xffffffff>.

=back


=head1 AUTHOR

Jerome Quelin, E<lt>jquelin@cpan.orgE<gt>

Development is discussed on E<lt>language-befunge@mongueurs.netE<gt>


=head1 ACKNOWLEDGEMENTS

I would like to thank Chris Pressey, creator of Befunge, who gave a
whole new dimension to both coding and obfuscating.


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
