# $Id: LaheySpace.pm,v 1.4 2002/04/10 07:49:43 jquelin Exp $
#
# Copyright (c) 2002 Jerome Quelin <jquelin@cpan.org>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package Language::Befunge::LaheySpace;
require v5.6;

=head1 NAME

Language::Befunge::LaheySpace - a LaheySpace representation.


=head1 SYNOPSIS



=head1 DESCRIPTION


=cut

# A little anal retention ;-)
use strict;
use warnings;

# Modules we relied upon.
use Carp;     # This module can't explode :o)

# Variables of the module.
our $AUTOLOAD;
our $subs;

BEGIN {
    my @subs = split /\|/, 
      $subs = 'xmin|xmax|ymin|ymax';
    use subs @subs;
}

# Private variables of the module.


=head1 CONSTRUCTOR

=head2 new(  )

Creates a new Lahey Space.

=cut
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = 
      { xmin   => 0, # the upper-left x-coordinate
        xmax   => 0, # the bottom-right x-coordinate
        ymin   => 0, # the upper-left y-coordinate
        ymax   => 0, # the bottom-right y-coordinate
        torus  => [],
      };
    bless $self, $class;
    return $self;
}

=head1 ACCESSORS

Those accessors are private, and are not meant to be used from outside
this module (the torus won't enlarge if used directly). You've been
warned.

=pod

All the following accessors are autoloaded.

=head2 xmin( [x] )

Get or set the current minimum x-coordinate of the torus.

=head2 xmax( [x] )

Get or set the current minimum x-coordinate of the torus.

=head2 ymin( [y] )

Get or set the current minimum y-coordinate of the torus.

=head2 ymax( [y] )

Get or set the current minimum y-coordinate of the torus.

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


=head1 PUBLIC METHODS

=head2 clear(  )

Clear the torus.

=cut
sub clear {
    my $self = shift;
    $self->xmin(0);
    $self->ymin(0);
    $self->xmax(0);
    $self->ymax(0);
    $self->{torus} = [];
}


=head2 store( code, [x, y] )

Store the given code at the specified coordinates. If the coordinates
are omitted, then the code is stored at the Origin(0, 0) coordinates.

Return the widht and height of the code inserted.

=cut
sub store {
    my ($self, $code, $x, $y) = @_;
    $x ||= 0;
    $y ||= 0;

    # The torus is an array of arrays of numbers.
    # Each number is the ordinal value of the character
    # held in this cell.

    my @lines = split $/, $code;

    # Fetch min/max values.
    my $maxy = $#lines + $y;
    my $maxlen = 0;
    foreach my $i ( 0..$#lines ) {
        my $len = length $lines[$i];
        $maxlen < $len and $maxlen = $len;
    }
    my $maxx = $maxlen + $x - 1 + $self->xmin;

    # Enlarge torus.
    $self->set_min( $x, $y );
    $self->set_max( $maxx, $maxy );

    # Store code.
    foreach my $j ( 0..$#lines  ) {
        $lines[$j] .= " " x $maxlen;
        $lines[$j] = substr $lines[$j], 0, $maxlen;
        my @chars = map { ord } split //, $lines[$j];
        splice @{ $self->{torus}[ $j + $y - $self->ymin ] }, $x - $self->xmin, $maxlen, @chars;
    }

    return ($maxlen, scalar( @lines ) );
}


=head2 get_value( x, y )warn "apres: ",$self->xmax,",",$self->ymax,"\n";


Return the number stored in the torus at the specified location. If
the value hasn't yet been set, it defaults to the ordinal value of a
space (ie, #32).

B</!\> As in Befunge, code and data share the same playfield, the
number returned can be either an instruction B<or> a data (or even
both... Eh, that's Befunge! :o) ).

=cut
sub get_value {
    my ($self, $x, $y) = @_;
    my $val = 32;               # Default to space.

    if ( $y >= $self->ymin and $y <= $self->ymax ) {
        # The line is one of the current mapped lines.
        my $line = $self->{torus}[ $y - $self->ymin];
        if ( defined $line and $x >= $self->xmin and $x <= scalar( @$line ) ) {
            # The column may be mapped on this line.
            $val = $line->[ $x - $self->xmin];
            defined $val or $val = 32;
        }
    }
    return $val;
}
    


=head2 set_value( x, y, value )

Write the supplied value in the torus at the specified location.

B</!\> As in Befunge, code and data share the same playfield, the
number stored can be either an instruction B<or> a data (or even
both... Eh, that's Befunge! :o) ).

=cut
sub set_value {
    my ($self, $x, $y, $val) = @_;

    # Ensure we can set the value.
    $self->set_min( $x, $y );
    $self->set_max( $x, $y );
    $self->{torus}[$y][$x] = $val;
}

=head2 move_ip_forward( ip )

Move the given ip forward, according to its delta.

=cut
sub move_ip_forward {
    my ($self, $ip) = @_;

    # Fetch the current position of the IP.
    my $x = $ip->curx;
    my $y = $ip->cury;

    # Now, let's move the IP.
    $x += $ip->dx;
    $y += $ip->dy;


    # Check out-of-bounds. Please note that we're in a
    # Lahey-space, and if we need to wrap, we perform a
    # Lahey-space wrapping. That is, the play field is limited to
    # real code, and we do _not_ perform wrapping on all the
    # addressable space.
    $x = $self->xmin + ($x - $self->xmax) - 1 if $x > $self->xmax;
    $x = $self->xmax - ($x - $self->xmin) - 1 if $x < $self->xmin;
    $y = $self->ymin + ($y - $self->ymax) - 1 if $y > $self->ymax;
    $y = $self->ymax - ($y - $self->ymin) - 1 if $y < $self->ymin;

    # Store new position.
    $ip->set_pos( $x, $y );
}


=head2 rectangle( x, y, w, h )

Return a string containing the data/code in the specified rectangle.

=cut
sub rectangle {
    my ($self, $x, $y, $w, $h) = @_;

    # Ensure we have enough data.
    $self->set_min( $x, $y );
    $self->set_max( $x+$w, $y+$h );

    # Fetch the data.
    my $data = "";
    foreach my $i ( $y-$self->ymin .. $y-$self->ymin+$h-1 ) {
#          warn ">$i<\n";
#          use Dumpvalue;
#          my $d = new Dumpvalue;
#          $d->dumpValue( \$self);
        $data .= join "", 
          map { chr } 
            ( @{ $self->{torus}[$i] } )[ $x-$self->xmin .. $x-$self->xmin+$w-1 ];
        $data .= "\n";
    }

    return $data;
}


=head1 PRIVATE METHODS

=head2 set_min( x, y )

Set the current minimum coordinates. If the supplied values are bigger
than the actual minimum, then nothing is done.

=cut
sub set_min {
    my ($self, $x, $y) = @_;

    # Check if we need to enlarge the torus.
    $self->enlarge_y( $y - $self->ymin ) if $y < $self->ymin;
    $self->enlarge_x( $x - $self->xmin ) if $x < $self->xmin;
}


=head2 set_max( x, y )

Set the current maximum coordinates. If the supplied values are smaller
than the actual maximum, then nothing is done.

=cut
sub set_max {
    my ($self, $x, $y) = @_;

    # Check if we need to enlarge the torus.
    $self->enlarge_y( $y - $self->ymax ) if $y > $self->ymax;
    $self->enlarge_x( $x - $self->xmax ) if $x > $self->xmax;
}


=head2 enlarge_x( dx )

Enlarge the torus on its x coordinate. If the delta is positive, add
columns after the last column; if negative, before the first column;
if nul, nothing is done.

=cut
sub enlarge_x {
    my ($self, $delta) = @_;

    if ( $delta < 0 ) {
        # Insert columns _before_ the Lahey space.
        $delta = -$delta;
        map { splice @$_, 0, 0, (32) x $delta } @{ $self->{torus} };
        $self->xmin( $self->xmin - $delta );
    } else {
        # Insert columns _after_ the Lahey space.
        map { splice @$_, scalar(@$_), 0, (32) x $delta } @{ $self->{torus} };
        $self->xmax( $self->xmax + $delta );
    }
}


=head2 enlarge_y( dy )

Enlarge the torus on its y coordinate. If the delta is positive, add
lines after the last one; if negative, before the first line; if nul,
nothing is done.

=cut
sub enlarge_y {
    my ($self, $delta) = @_;

    if ( scalar @{ $self->{torus} } == 0 ) {
        $self->{torus} = [ map { [] } 0..abs($delta) ];
        $delta > 0 ?
          $self->ymax( $self->ymax + $delta )
          : $self->ymin( $self->ymin + $delta );
        return;
    }

    if ( $delta < 0 ) {
        # Insert rows _before_ the Lahey space.
        $delta = -$delta;
        unshift @{ $self->{torus} }, [ (32) x ($self->xmax - $self->xmin + 1) ] for 1..$delta;
        $self->ymin( $self->ymin - $delta );
    } else {
        # Insert rows _after_ the Lahey space.
        push @{ $self->{torus} }, [ (32) x ($self->xmax - $self->xmin + 1 ) ] for 1..$delta;
        $self->ymax( $self->ymax + $delta );
    }
}


1;
__END__


=head1 AUTHOR

Jerome Quelin, E<lt>jquelin@cpan.orgE<gt>


=head1 COPYRIGHT

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=head1 SEE ALSO

L<Language::Befunge>.

=cut
