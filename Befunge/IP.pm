# $Id: IP.pm,v 1.11 2002/04/11 15:23:40 jquelin Exp $
#
# Copyright (c) 2002 Jerome Quelin <jquelin@cpan.org>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package Language::Befunge::IP;
require v5.6;

=head1 NAME

Language::Befunge::IP - an Instruction Pointer for a Befunge-97 program.


=head1 SYNOPSIS



=head1 DESCRIPTION


=cut

# A little anal retention ;-)
use strict;
use warnings;

# Modules we relied upon.
use Carp;     # This module can't explode :o)
use Storable qw(dclone);

# Variables of the module.
our $AUTOLOAD;
our $subs;

BEGIN {
    my @subs = split /\|/, 
      $subs = 'id|curx|cury|dx|dy|storx|story|string_mode|space_pushed|toss|ss|input';
    use subs @subs;
}

# Private variables of the module.


=head1 CONSTRUCTOR

=head2 new(  )

Create a new Instruction Pointer.

=cut
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = 
      { id           => 0,  
        toss         => [],
        ss           => [],
        curx         => 0,
        cury         => 0,
        dx           => 1,
        dy           => 0,
        storx        => 0,
        story        => 0,
        string_mode  => 0,
        space_pushed => 0,
        input        => "",
      };
    bless $self, $class;
    $self->id( $self->get_new_id );
    return $self;
}

=head2 clone(  )

Clone the current Instruction Pointer with all its stacks, position,
delta, etc. Change its unique ID.

=cut
sub clone {
    my $self = shift;
    my $clone = dclone( $self );
    $clone->id( $self->get_new_id );
    return $clone;
}


=head1 ACCESSORS

=head2 set_pos( x, y )

Set the current position of the IP to the corresponding location.

=cut
sub set_pos {
    my ($self, $x, $y) = @_;
    $self->curx( $x );
    $self->cury( $y );
}

=pod

All the following accessors are autoloaded.

=head2 id( id )

Get or set the unique ID of the IP.

=head2 curx( x )

Get or set the current x-coordinate of the IP.

=head2 cury( y )

Get or set the current y-coordinate of the IP.

=head2 dx( dx )

Get or set the horizontal offset of the IP.

=head2 dy( dy )

Get or set the vertical offset of the IP.

=head2 storx( x )

Get or set the x-coordinate of the storage offset of the IP.

=head2 story( y )

Get or set the y-coordinate of the storage offset of the IP.

=head2 input( [string] )

Get or set the input cache.

=head2 string_mode( [boolean] )

Get or set the string_mode of the IP.

=head2 space_pushed( [boolean] )

Get or set wether a space has been pushed on the stack when
encountering a serie of spaces in string-mode.

=head2 ss(  )

Get the stack of stack of the IP.

=head2 toss(  )

Access the current stack (er, TOSS) of the IP.

=cut
sub AUTOLOAD {
    # We don't DESTROY.
    return if $AUTOLOAD =~ /::DESTROY/;

    # Fetch the attribute name
    $AUTOLOAD =~ /.*::(\w+)/;
    my $attr = $1;
    # Must be one of the registered subs (compile once)
    if( $attr =~ /$subs/o ) {
        no strict 'refs';

        # Create the method (but don't pollute other namespaces)
        *{$AUTOLOAD} = sub {
            my $self = shift;
            @_ ? $self->{$attr} = shift : $self->{$attr};
        };

        # Now do it
        goto &{$AUTOLOAD};
    }
    # Should we really die here?
    croak "Undefined method $AUTOLOAD";
}

=head2 soss(  )

Get or set the SOSS.

=cut
sub soss {
    my $self = shift;
    # Remember, the Stack Stack is up->bottom.
    @_ and $self->ss->[0] = shift;
    return $self->ss->[0];
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
    return scalar @{ $self->toss };
}

=item spush( value )

Push a value on top of the stack.

=cut
sub spush {
    my $self = shift;
    push @{ $self->toss }, @_;
}

=item spop(  )

Pop a value from the stack. If the stack is empty, no error occurs and
the method acts as if it popped a 0.

=cut
sub spop {
    my $self = shift;
    my $val = pop @{ $self->toss };
    defined $val or $val = 0;
    return $val;
}

=item spop_gnirts(  )

Pop a 0gnirts string from the stack.

=cut
sub spop_gnirts {
    my $self = shift;
    my ($val, $str);
    do {
        $val = pop @{ $self->toss };
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
    $self->toss( [] );
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
    return $self->toss->[$idx];
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
    return scalar( @{ $self->ss } );
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

  sw: {
        $n == 0 and last sw;
        $n < 0 and do {
            # Push zeroes.
            @new_toss = (0) x abs($n);
            last sw;
        };
        $n > 0 and do {
            my $c = $n - $self->scount;
            if ( $c <= 0 ) {
                # Transfer elements.
                @new_toss = splice @{ $self->toss }, -$n;
            } else {
                # Transfer elems and fill with zeroes.
                @new_toss = ( (0) x $c, @{ $self->toss } );
                $self->sclear;
            }
                
            last sw;
        };
    }

    # Push the former TOSS on the stack stack and copy reference to
    # the new TOSS.
    # For commodity reasons, the Stack Stack is oriented up->bottom
    # (that is, a push is an unshift, and a pop is a shift).
    unshift @{ $self->ss }, $self->toss;
    $self->toss( \@new_toss );
}

=item ss_remove( count )

Move C<count> elements from TOSS to SOSS, discard TOSS and make the
SOSS become the new TOSS. Order of elems is preserved.

=cut
sub ss_remove {
    my ( $self, $n ) = @_;

    # Fetch the TOSS.
    # Remember, the Stack Stack is up->bottom.
    my $new_toss = shift @{ $self->ss };

  sw: {
        $n == 0 and last sw;
        $n < 0 and do {
            # Remove values.
            if ( scalar(@$new_toss) >= abs($n) ) {
                splice @$new_toss, $n;
            } else {
                $new_toss = [];
            }
            last sw;
        };
        $n > 0 and do {
            my $c = $n - $self->scount;
            if ( $c <= 0 ) {
                # Transfer elements.
                push @$new_toss, splice( @{ $self->toss }, -$n );
            } else {
                # Transfer elems and fill with zeroes.
                push @$new_toss, ( (0) x $c, @{ $self->toss } );
            }
            last sw;
        };
    }

    # Store the new TOSS.
    $self->toss( $new_toss );
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
            @elems = splice @{ $self->toss }, -$n;
        } else { 
            @elems = ( (0) x $c, @{ $self->toss } );
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
        push @sizes, scalar @{ $self->ss->[$i-1] };
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

=item set_delta( dx, dy )

Implements the C<x> instruction. Set the delta vector of the IP
according to the provided values.

=cut
sub set_delta {
    my ($self, $dx, $dy) = @_;
    $self->dx( $dx );
    $self->dy( $dy );
}

=item dir_go_east(  )

Implements the C<E<gt>> instruction. Force the IP to travel east.

=cut
sub dir_go_east {
    my $self = shift;
    $self->set_delta( 1, 0);
}

=item dir_go_west(  )

Implements the C<E<lt>> instruction. Force the IP to travel west.

=cut
sub dir_go_west {
    my $self = shift;
    $self->set_delta( -1, 0);
}

=item dir_go_north(  )

Implements the C<^> instruction. Force the IP to travel north.

=cut
sub dir_go_north {
    my $self = shift;
    $self->set_delta( 0, -1);
}

=item dir_go_south(  )

Implements the C<v> instruction. Force the IP to travel south.

=cut
sub dir_go_south {
    my $self = shift;
    $self->set_delta( 0, 1);
}

=item dir_go_away(  )

Implements the C<?> instruction. Cause the IP to travel in a random
cardinal direction ( north, south, east or west).

=cut
sub dir_go_away {
    my $self = shift;
    my $meth = qw( dir_go_east dir_go_west dir_go_north dir_go_south )[int(rand 4)];
    $self->$meth();
}

=item dir_turn_left(  )

Implements the C<[> instruction. Rotate by 90 degrees on the left the
delta of the IP which encounters this instruction.

=cut
sub dir_turn_left {
    my $self = shift;
    my $old_dx = $self->dx;
    my $old_dy = $self->dy;
    $self->set_delta( 0 + $old_dy, 0 + $old_dx * -1);
}

=item dir_turn_right(  )

Implements the C<]> instruction. Rotate by 90 degrees on the right the
delta of the IP which encounters this instruction.

=cut
sub dir_turn_right {
    my $self = shift;
    my $old_dx = $self->dx;
    my $old_dy = $self->dy;
    $self->set_delta( 0 + $old_dy * -1, 0 + $old_dx );
}

=item dir_reverse(  )

Implements the C<r> instruction. Reverse the direction of the IP, that
is, multiply the IP's delta by -1.

=cut
sub dir_reverse {
    my $self = shift;
    $self->set_delta( 0 + $self->dx * -1, 0 + $self->dy * -1 );
}


=head1 PRIVATE METHODS

=head2 get_new_id(  )

Forge a new IP id, that will distinct it from the other IPs of the program.

=cut
my $id = 0;
sub get_new_id {
    return $id++;
}

1;
__END__


=back

=head1 AUTHOR

Jerome Quelin, E<lt>jquelin@cpan.orgE<gt>


=head1 COPYRIGHT

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=head1 SEE ALSO

L<Language::Befunge>.

=cut
