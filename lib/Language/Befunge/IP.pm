#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

package Language::Befunge::IP;
require 5.006;

=head1 NAME

Language::Befunge::IP - an Instruction Pointer for a Befunge-97 program.


=head1 DESCRIPTION

This is the class implementing the Instruction Pointers. An
Instruction Pointer (aka IP) has a stack, and a stack of stacks that
can be manipulated via the methods of the class.

We need a class, since this is a concurrent Befunge, so we can have
more than one IP travelling on the Lahey space.

=cut
use strict;
use warnings;
use integer;

# Modules we rely upon.
use Language::Befunge::Vector;
use Carp;     # This module can't explode :o)
use Storable qw(dclone);


=head1 CONSTRUCTOR

=head2 new( [dimensions] )

Create a new Instruction Pointer, which operates in a universe of the given
number of dimensions.  If dimensions is not specified, it defaults to 2.

=cut
sub new {
    my ($class, $dims) = @_;
    $dims = 2 unless defined $dims;
    my $self  =
      { id           => 0,
      	dims         => $dims,
        toss         => [],
        ss           => [],
        position     => Language::Befunge::Vector->new_zeroes($dims),
        delta        => Language::Befunge::Vector->new_zeroes($dims),
        storage      => Language::Befunge::Vector->new_zeroes($dims),
        string_mode  => 0,
        end          => 0,
        input        => "",
        data         => {},
        libs         => [],
      };
    # go right by default
    $self->{delta}->set_component(0, 1);
    bless $self, $class;
    $self->set_id( $self->_get_new_id );
    return $self;
}

=head2 clone(  )

Clone the current Instruction Pointer with all its stacks, position,
delta, etc. Change its unique ID.

=cut
sub clone {
    my $self = shift;
    my $clone = dclone( $self );
    $clone->set_id( $self->_get_new_id );
    return $clone;
}


=head1 ACCESSORS

=head2 Attributes

The following is a list of attributes of a Language::Befunge::IP
object. For each of them, a method C<get_foobar> and C<set_foobar>
exists.

=over 4

=item get_id() / set_id()

the unique ID of the IP (an integer)

=item get_dims()

the number of dimensions this IP operates in (an integer).  This is
read-only.

=item get_position() / set_position()

the current coordinates of the IP (a vector)

=item get_delta() / set_delta()

the offset of the IP (a vector)

=item get_storage() / set_storage()

the coordinates of the storage offset of the IP (a vector)

=item get_data() / set_data()

the library private storage space (a hash reference)

=item get_input() / set_input()

the input cache (a string)

=item get_string_mode() / set_string_mode()

the string_mode of the IP (a boolean)

=item get_end() / set_end()

wether the IP should be terminated (a boolean)

=item get_libs() / set_libs()

the current stack of loaded libraries (an array reference)

=item get_ss() / set_ss()

the stack of stack of the IP (an array reference)

=item get_toss() / set_toss()

the current stack (er, TOSS) of the IP (an array reference)

=back

=cut
BEGIN {
    my @attrs = qw[ position data delta end id input libs
                    ss storage string_mode toss ];
    foreach my $attr ( @attrs ) {
        my $code = qq[ sub get_$attr { return \$_[0]->{$attr} } ];
        $code .= qq[ sub set_$attr { \$_[0]->{$attr} = \$_[1] } ];
        eval $code;
    }
}

sub get_dims { return $_[0]->{dims} };

=pod

=head2 soss(  )

Get or set the SOSS.

=cut
sub soss {
    my $self = shift;
    # Remember, the Stack Stack is up->bottom.
    @_ and $self->get_ss->[0] = shift;
    return $self->get_ss->[0];
}


=head1 PUBLIC METHODS

=head2 Internal stack

In this section, I speak about the stack. In fact, this is the TOSS - that
is, the Top Of the Stack Stack.

In Befunge-98, standard stack operations occur transparently on the
TOSS (as if there were only one stack, as in Befunge-93).

=over 4

=item scount(  )

Return the number of elements in the stack.

=cut
sub scount {
    my $self = shift;
    return scalar @{ $self->get_toss };
}

=item spush( value )

Push a value on top of the stack.

=cut
sub spush {
    my $self = shift;
    push @{ $self->get_toss }, @_;
}

=item spush_vec( vector )

Push a vector on top of the stack. The x coordinate is pushed first.

=cut
sub spush_vec {
	my ($self) = shift;
	foreach my $v (@_) {
		$self->spush($v->get_all_components);
	}
}

=item spush_args ( arg, ... )

Push a list of argument on top of the stack (the first argument will
be the deeper one). Convert each argument: a number is pushed as is,
whereas a string is pushed as a 0gnirts.

B</!\> Do B<not> push references or weird arguments: this method
supports only numbers (positive and negative) and strings.

=cut
sub spush_args {
    my $self = shift;
    foreach my $arg ( @_ ) {
        $self->spush
          ( ($arg =~ /^-?\d+$/) ?
              $arg                                    # A number.
            : reverse map {ord} split //, $arg.chr(0) # A string.
          );
    }
}

=item spop(  )

Pop a value from the stack. If the stack is empty, no error occurs and
the method acts as if it popped a 0.

=cut
sub spop {
    my $self = shift;
    my $val = pop @{ $self->get_toss };
    defined $val or $val = 0;
    return $val;
}

=item spop_mult( <count> )

Pop multiple values from the stack. If the stack becomes empty, the
remainder of the returned values will be 0.

=cut
sub spop_mult {
    my ($self, $count) = @_;
    my @rv = reverse map { $self->spop() } (1..$count);
    return @rv;
}

=item spop_vec(  )

Pop a vector from the stack. Returns a Vector object.

=cut
sub spop_vec {
    my $self = shift;
    return Language::Befunge::Vector->new($self->get_dims, $self->spop_mult($self->get_dims));
}

=item spop_gnirts(  )

Pop a 0gnirts string from the stack.

=cut
sub spop_gnirts {
    my $self = shift;
    my ($val, $str);
    do {
        $val = pop @{ $self->get_toss };
        defined $val or $val = 0;
        $str .= chr($val);
    } while( $val != 0 );
    chop $str; # Remove trailing \0.
    return $str;
}

=item sclear(  )

Clear the stack.

=cut
sub sclear {
    my $self = shift;
    $self->set_toss( [] );
}

=item svalue( offset )

Return the C<offset>th value of the TOSS, counting from top of the
TOSS. The offset is interpreted as a negative value, that is, a call
with an offset of C<2> or C<-2> would return the second value on top
of the TOSS.

=cut
sub svalue {
    my ($self, $idx) = @_;

    $idx = - abs( $idx );
    return 0 unless exists $self->get_toss->[$idx];
    return $self->get_toss->[$idx];
}

=back


=head2 Stack stack

This section discusses about the stack stack. We can speak here about
TOSS (Top Of Stack Stack) and SOSS (second on stack stack).

=over 4

=item ss_count(  )

Return the number of stacks in the stack stack. This of course does
not include the TOSS itself.

=cut
sub ss_count {
    my $self = shift;
    return scalar( @{ $self->get_ss } );
}

=item ss_create( count )

Push the TOSS on the stack stack and create a new stack, aimed to be
the new TOSS. Once created, transfer C<count> elements from the SOSS
(the former TOSS) to the TOSS. Transfer here means move - and B<not>
copy -, furthermore, order is preserved.

If count is negative, then C<count> zeroes are pushed on the new TOSS.

=cut
sub ss_create {
    my ( $self, $n ) = @_;

    my @new_toss;

    if ( $n < 0 ) {
        # Push zeroes.
        @new_toss = (0) x abs($n);
    } elsif ( $n > 0 ) {
        my $c = $n - $self->scount;
        if ( $c <= 0 ) {
            # Transfer elements.
            @new_toss = splice @{ $self->get_toss }, -$n;
        } else {
            # Transfer elems and fill with zeroes.
            @new_toss = ( (0) x $c, @{ $self->get_toss } );
            $self->sclear;
        }
    }
    # $n == 0: do nothing


    # Push the former TOSS on the stack stack and copy reference to
    # the new TOSS.
    # For commodity reasons, the Stack Stack is oriented up->bottom
    # (that is, a push is an unshift, and a pop is a shift).
    unshift @{ $self->get_ss }, $self->get_toss;
    $self->set_toss( \@new_toss );
}

=item ss_remove( count )

Move C<count> elements from TOSS to SOSS, discard TOSS and make the
SOSS become the new TOSS. Order of elems is preserved.

=cut
sub ss_remove {
    my ( $self, $n ) = @_;

    # Fetch the TOSS.
    # Remember, the Stack Stack is up->bottom.
    my $new_toss = shift @{ $self->get_ss };

    if ( $n < 0 ) {
        # Remove values.
        if ( scalar(@$new_toss) >= abs($n) ) {
            splice @$new_toss, $n;
        } else {
            $new_toss = [];
        }
    } elsif ( $n > 0 ) {
        my $c = $n - $self->scount;
        if ( $c <= 0 ) {
            # Transfer elements.
            push @$new_toss, splice( @{ $self->get_toss }, -$n );
        } else {
            # Transfer elems and fill with zeroes.
            push @$new_toss, ( (0) x $c, @{ $self->get_toss } );
        }
    }
    # $n == 0: do nothing


    # Store the new TOSS.
    $self->set_toss( $new_toss );
}

=item ss_transfer( count )

Transfer C<count> elements from SOSS to TOSS, or from TOSS to SOSS if
C<count> is negative; the transfer is done via pop/push.

The order is not preserved, it is B<reversed>.

=cut
sub ss_transfer {
    my ($self, $n) = @_;
    $n == 0 and return;

    if ( $n > 0 ) {
        # Transfer from SOSS to TOSS.
        my $c = $n - $self->soss_count;
        my @elems;
        if ( $c <= 0 ) {
            @elems = splice @{ $self->soss }, -$n;
        } else {
            @elems = ( (0) x $c, @{ $self->soss } );
            $self->soss_clear;
        }
        $self->spush( reverse @elems );

    } else {
        $n = -$n;
        # Transfer from TOSS to SOSS.
        my $c = $n - $self->scount;
        my @elems;
        if ( $c <= 0 ) {
            @elems = splice @{ $self->get_toss }, -$n;
        } else {
            @elems = ( (0) x $c, @{ $self->get_toss } );
            $self->sclear;
        }
        $self->soss_push( reverse @elems );

    }
}

=item ss_sizes(  )

Return a list with all the sizes of the stacks in the stack stack
(including the TOSS), from the TOSS to the BOSS.

=cut
sub ss_sizes {
    my $self = shift;

    my @sizes = ( $self->scount );

    # Store the size of each stack.
    foreach my $i ( 1..$self->ss_count ) {
        push @sizes, scalar @{ $self->get_ss->[$i-1] };
    }

    return @sizes;
}


=item soss_count(  )

Return the number of elements in SOSS.

=cut
sub soss_count {
    my $self = shift;
    return scalar( @{ $self->soss } );
}

=item soss_push( value )

Push a value on top of the SOSS.

=cut
sub soss_push {
    my $self = shift;
    push @{ $self->soss }, @_;
}


=item soss_pop_mult( <count> )

Pop multiple values from the SOSS. If the stack becomes empty, the
remainder of the returned values will be 0.

=cut
sub soss_pop_mult {
    my ($self, $count) = @_;
    my @rv = reverse map { $self->soss_pop() } (1..$count);
    return @rv;
}

=item soss_push_vec( vector )

Push a vector on top of the SOSS.

=cut
sub soss_push_vec {
    my $self = shift;
	foreach my $v (@_) {
		$self->soss_push($v->get_all_components);
	}
}

=item soss_pop(  )

Pop a value from the SOSS. If the stack is empty, no error occurs and
the method acts as if it popped a 0.

=cut
sub soss_pop {
    my $self = shift;
    my $val = pop @{ $self->soss };
    defined $val or $val = 0;
    return $val;
}

=item soss_pop_vec(  )

Pop a vector from the SOSS. If the stack is empty, no error occurs
and the method acts as if it popped a 0.  returns a Vector.

=cut
sub soss_pop_vec {
    my $self = shift;
    return Language::Befunge::Vector->new($self->get_dims, $self->soss_pop_mult($self->get_dims));
}

=item soss_clear(  )

Clear the SOSS.

=cut
sub soss_clear {
    my $self = shift;
    $self->soss( [] );
}



=back


=head2 Changing direction

=over 4

=item dir_go_east(  )

Implements the C<E<gt>> instruction. Force the IP to travel east.

=cut
sub dir_go_east {
    my $self = shift;
    $self->get_delta->zero();
    $self->get_delta->set_component(0, 1);
}

=item dir_go_west(  )

Implements the C<E<lt>> instruction. Force the IP to travel west.

=cut
sub dir_go_west {
    my $self = shift;
    $self->get_delta->zero();
    $self->get_delta->set_component(0, -1);
}

=item dir_go_north(  )

Implements the C<^> instruction. Force the IP to travel north.

Not valid for Unefunge.

=cut
sub dir_go_north {
    my $self = shift;
    $self->get_delta->zero();
    $self->get_delta->set_component(1, -1);
}

=item dir_go_south(  )

Implements the C<v> instruction. Force the IP to travel south.

Not valid for Unefunge.

=cut
sub dir_go_south {
    my $self = shift;
    $self->get_delta->zero();
    $self->get_delta->set_component(1, 1);
}

=item dir_go_high(  )

Implements the C<h> instruction. Force the IP to travel up.

Not valid for Unefunge or Befunge.

=cut
sub dir_go_high {
    my $self = shift;
    $self->get_delta->zero();
    $self->get_delta->set_component(2, 1);
}

=item dir_go_low(  )

Implements the C<l> instruction. Force the IP to travel down.

Not valid for Unefunge or Befunge.

=cut
sub dir_go_low {
    my $self = shift;
    $self->get_delta->zero();
    $self->get_delta->set_component(2, -1);
}

=item dir_go_away(  )

Implements the C<?> instruction. Cause the IP to travel in a random
cardinal direction (in Befunge's case, one of: north, south, east or
west).

=cut
sub dir_go_away {
    my $self = shift;
    my $nd = $self->get_dims;
    my $dim = (0..$nd-1)[int(rand $nd)];
    $self->get_delta->zero();
    my $value = (-1, 1)[int(rand 2)];
    $self->get_delta->set_component($dim, $value);
}

=item dir_turn_left(  )

Implements the C<[> instruction. Rotate by 90 degrees on the left the
delta of the IP which encounters this instruction.

Not valid for Unefunge.  For Trefunge and greater, only affects the
X and Y axes.

=cut
sub dir_turn_left {
    my $self = shift;
    my $old_dx = $self->get_delta->get_component(0);
    my $old_dy = $self->get_delta->get_component(1);
    $self->get_delta->set_component(0, 0 + $old_dy);
    $self->get_delta->set_component(1, 0 + $old_dx * -1);
}

=item dir_turn_right(  )

Implements the C<]> instruction. Rotate by 90 degrees on the right the
delta of the IP which encounters this instruction.

Not valid for Unefunge.  For Trefunge and higher dimensions, only
affects the X and Y axes.

=cut
sub dir_turn_right {
    my $self = shift;
    my $old_dx = $self->get_delta->get_component(0);
    my $old_dy = $self->get_delta->get_component(1);
    $self->get_delta->set_component(0, 0 + $old_dy * -1);
    $self->get_delta->set_component(1, 0 + $old_dx);
}

=item dir_reverse(  )

Implements the C<r> instruction. Reverse the direction of the IP, that
is, multiply the IP's delta by -1.

=cut
sub dir_reverse {
    my $self = shift;
    $self->set_delta($self->get_delta->vector_invert());
}

=back

=head2 Libraries semantics

=over 4

=item load( obj )

Load the given library semantics. The parameter is an extension object
(a library instance).

=cut
sub load {
    my ($self, $lib) = @_;
    unshift @{ $self->get_libs }, $lib;
}

=item unload( lib )

Unload the given library semantics. The parameter is the library name.

Return the library name if it was correctly unloaded, undef otherwise.

B</!\> If the library has been loaded twice, this method will only
unload the most recent library. Ie, if an IP has loaded the libraries
( C<FOO>, C<BAR>, C<FOO>, C<BAZ> ) and one calls C<unload( "FOO" )>,
then the IP will follow the semantics of C<BAZ>, then C<BAR>, then
<FOO> (!).

=cut
sub unload {
    my ($self, $lib) = @_;

    my $offset = -1;
    foreach my $i ( 0..$#{$self->get_libs} ) {
        $offset = $i, last if ref($self->get_libs->[$i]) eq $lib;
    }
    $offset == -1 and return undef;
    splice @{ $self->get_libs }, $offset, 1;
    return $lib;
}

=item extdata( library, [value] )

Store or fetch a value in a private space. This private space is
reserved for libraries that need to store internal values.

Since in Perl references are plain scalars, one can store a reference
to an array or even a hash.

=cut
sub extdata {
    my $self = shift;
    my $lib  = shift;
    @_ ? $self->get_data->{$lib} = shift : $self->get_data->{$lib};
}

=back

=head1 PRIVATE METHODS

=head2 _get_new_id(  )

Forge a new IP id, that will distinct it from the other IPs of the program.

=cut
my $id = 0;
sub _get_new_id {
    return $id++;
}

1;
__END__


=head1 SEE ALSO

L<Language::Befunge>.


=head1 AUTHOR

Jerome Quelin, E<lt>jquelin@cpan.orgE<gt>


=head1 COPYRIGHT & LICENSE

Copyright (c) 2001-2007 Jerome Quelin, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
