# $Id: LaheySpace.pm,v 1.8 2006/02/14 15:44:47 jquelin Exp $
#
# Copyright (c) 2002-2003 Jerome Quelin <jquelin@cpan.org>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package Language::Befunge::LaheySpace;
require 5.006;

=head1 NAME

Language::Befunge::LaheySpace - a LaheySpace representation.


=head1 SYNOPSIS



=head1 DESCRIPTION


=cut


# Modules we rely upon.
use strict;
use warnings;
use Carp;     # This module can't explode :o)



=head1 CONSTRUCTOR

=head2 new(  )

Creates a new Lahey Space.

=cut
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = 
      { xmin   => 0, # the upper-left x-coordinate
        ymin   => 0, # the upper-left y-coordinate
        xmax   => 0, # the bottom-right x-coordinate
        ymax   => 0, # the bottom-right y-coordinate
        torus  => [],
      };
    bless $self, $class;
    return $self;
}




=head1 PUBLIC METHODS

=head2 clear(  )

Clear the torus.

=cut
sub clear {
    my $self = shift;
    $self->{xmin} = 0;
    $self->{ymin} = 0;
    $self->{xmax} = 0;
    $self->{ymax} = 0;
    $self->{torus} = [];
}


=head2 store( code, [x, y] )

Store the given code at the specified coordinates. If the coordinates
are omitted, then the code is stored at the Origin(0, 0) coordinates.

Return the width and height of the code inserted.

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
    my $maxy = $#lines + $y - $self->{ymin};
    my $maxlen = 0;
    foreach my $i ( 0..$#lines ) {
        my $len = length $lines[$i];
        $maxlen < $len and $maxlen = $len;
    }
    my $maxx = $maxlen + $x - 1 + $self->{xmin};

    # Enlarge torus.
    $self->set_min( $x, $y );
    $self->set_max( $maxx, $maxy );

    # Store code.
    foreach my $j ( 0..$#lines  ) {
        $lines[$j] .= " " x $maxlen;
        $lines[$j] = substr $lines[$j], 0, $maxlen;
        my @chars = map { ord } split //, $lines[$j];
        splice @{ $self->{torus}[ $j + $y - $self->{ymin} ] }, $x - $self->{xmin}, $maxlen, @chars;
    }

    return ($maxlen, scalar( @lines ) );
}

=head2 store_binary( code, [x, y] )

Store the given code at the specified coordinates. If the coordinates
are omitted, then the code is stored at the Origin(0, 0) coordinates.

Return the width and height of the code inserted.

This is binary insertion, that is, EOL and FF sequences are stored in
Funge-space instead of causing the dimension counters to be reset and
incremented.

=cut
sub store_binary {
    my ($self, $code, $x, $y) = @_;
    $x ||= 0;
    $y ||= 0;

    # The torus is an array of arrays of numbers.
    # Each number is the ordinal value of the character
    # held in this cell.

    # Fetch min/max values.
    my $maxy = $y - $self->{ymin};
    my $maxlen = length $code;
    my $maxx = $maxlen + $x - 1 + $self->{xmin};

    # Enlarge torus.
    $self->set_min( $x, $y );
    $self->set_max( $maxx, $maxy );

    # Store code.
    my @chars = map { ord } split //, $code;
    splice @{ $self->{torus}[ $y - $self->{ymin} ] }, $x - $self->{xmin}, $maxlen, @chars;

    return ($maxlen, 1 );
}

=head2 get_char( x, y )


Return the character stored in the torus at the specified location. If
the value is not between 0 and 255 (inclusive), get_char will return a
string that looks like "<np-0x4500>".

B</!\> As in Befunge, code and data share the same playfield, the
character returned can be either an instruction B<or> raw data.  No
guarantee is made that the return value is printable.

=cut
sub get_char {
	my $self = shift;
	my ($x,$y) = @_;
	my $ord = $self->get_value($x,$y);
	# reject invalid ascii
	return sprintf("<np-0x%x>",$ord) if ($ord < 0 || $ord > 255);
	return chr($ord);
}

=head2 get_value( x, y )


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

    if ( $y >= $self->{ymin} and $y <= $self->{ymax} ) {
        # The line is one of the current mapped lines.
        my $line = $self->{torus}[ $y - $self->{ymin}];
        if ( defined $line and $x >= $self->{xmin} and $x <= scalar( @$line ) ) {
            # The column may be mapped on this line.
            $val = $line->[ $x - $self->{xmin}];
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
    $self->{torus}[$y-$self->{ymin}][$x-$self->{xmin}] = $val;
}


=head2 move_ip_forward( ip )

Move the given ip forward, according to its delta.

=cut
sub move_ip_forward {
    my ($self, $ip) = @_;

    # Fetch the current position of the IP.
    my $x = $ip->get_curx;
    my $y = $ip->get_cury;

    my ($dx, $dy) = ($ip->get_dx, $ip->get_dy);
    # Now, let's move the IP.
    $x += $dx;
    $y += $dy;

    if($self->out_of_bounds($x, $y)) {
        # Check out-of-bounds. Please note that we're in a
        # Lahey-space, and if we need to wrap, we perform a
        # Lahey-space wrapping. Funge98 says we should walk 
        # our current trajectory in reverse, until we hit the
        # other side of LaheySpace, and then continue along
        # the same path.
        do {
            $x -= $dx;
            $y -= $dy;
        } until($self->out_of_bounds($x, $y));

        # Now that we've hit the wall, walk back into the
        # valid code range.
        $x += $dx;
        $y += $dy;
    }

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
    foreach my $i ( $y-$self->{ymin} .. $y-$self->{ymin}+$h-1 ) {
        $data .= join "", 
          map { chr } 
            ( @{ $self->{torus}[$i] } )[ $x-$self->{xmin} .. $x-$self->{xmin}+$w-1 ];
        $data .= "\n";
    }

    return $data;
}


=head2 labels_lookup(  )

Parse the Lahey space to find sequences such as C<;:(\w[^\s;])[^;]*;>
and return a hash reference whose keys are the labels and the values
an anonymous array with four values: a vector describing the absolute
position of the character B<just after> the trailing C<;>, and a
vector describing the velocity that lead to this label.

This method will only look in the four cardinal directions.

This allow to define some labels in the source code, to be used by
C<Inline::Befunge> (and maybe some exstensions).

=cut
sub labels_lookup {
    my $self = shift;
    my $labels = {};
    
  Y: foreach my $y ( 0 .. $#{$self->{torus}} ) {
      X: foreach my $x ( 0 .. $#{ $self->{torus}[$y] } ) {
            next X unless $self->{torus}[$y][$x] == ord(";");
            # Found a semicolon, let's try...
            VEC: foreach my $vec ( [1,0], [-1,0], [0,1], [0,-1] ) {
                my ($lab, $labx, $laby) = $self->labels_try( $x, $y, @$vec );
                defined($lab) or next VEC;
                
                # How exciting, we found a label!
                exists $labels->{$lab} 
                  and croak "Help! I found two labels '$lab' in the funge space";
                $labels->{$lab} = [$labx+$self->{xmin}, $laby+$self->{ymin}, @$vec];
            }
        }
    }

    return $labels;
}


=head1 PRIVATE METHODS

=head2 set_min( x, y )

Set the current minimum coordinates. If the supplied values are bigger
than the actual minimum, then nothing is done.

=cut
sub set_min {
    my ($self, $x, $y) = @_;

    # Check if we need to enlarge the torus.
    $self->enlarge_y( $y - $self->{ymin} ) if $y < $self->{ymin};
    $self->enlarge_x( $x - $self->{xmin} ) if $x < $self->{xmin};
}


=head2 set_max( x, y )

Set the current maximum coordinates. If the supplied values are smaller
than the actual maximum, then nothing is done.

=cut
sub set_max {
    my ($self, $x, $y) = @_;

    # Check if we need to enlarge the torus.
    $self->enlarge_y( $y - $self->{ymax} ) if $y > $self->{ymax};
    $self->enlarge_x( $x - $self->{xmax} ) if $x > $self->{xmax};
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
        $self->{xmin} -= $delta;
    } else {
        # Insert columns _after_ the Lahey space.
        map { splice @$_, scalar(@$_), 0, (32) x $delta } @{ $self->{torus} };
        $self->{xmax} += $delta;
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
        if ( $delta > 0 ) {
          $self->{ymax} += $delta;
        } else {
          $self->{ymin} += $delta;
        }
        return;
    }

    if ( $delta < 0 ) {
        # Insert rows _before_ the Lahey space.
        $delta = -$delta;
        unshift @{ $self->{torus} }, [ (32) x ($self->{xmax} - $self->{xmin} + 1) ] for 1..$delta;
        $self->{ymin} -= $delta;
    } else {
        # Insert rows _after_ the Lahey space.
        push @{ $self->{torus} }, [ (32) x ($self->{xmax} - $self->{xmin} + 1 ) ] for 1..$delta;
        $self->{ymax} += $delta;
    }
}


=head2 out_of_bounds( x, y )

Return true if a location is out of bounds.

=cut
sub out_of_bounds {
    my ($self, $x, $y) = @_;
    return 1 if $x > $self->{xmax};
    return 1 if $x < $self->{xmin};
    return 1 if $y > $self->{ymax};
    return 1 if $y < $self->{ymin};
    return 0;
}


=head2 labels_try( x, y, dx, dy )

Try in the specified direction if the funge space matches a label
definition. Return undef if it wasn't a label definition, or the name
of the label if it was a valid label.

=cut
sub labels_try {
    my ($self, $x, $y, $dx, $dy) = @_;
    my $comment = "";

    # Fetch the whole comment stuff.
    do {
        # Calculate the next cell coordinates.
        $x += $dx; $y += $dy;
        $x = 0 if $x > ($self->{xmax} - $self->{xmin});
        $y = 0 if $y > ($self->{ymax} - $self->{ymin});
        $x = ($self->{xmax} - $self->{xmin}) if $x < 0;
        $y = ($self->{ymax} - $self->{ymin}) if $y < 0;
        $comment .= chr( $self->{torus}[$y][$x] );
    } while ( $comment !~ /;.$/ );

    # Check if the comment matches the pattern.
    $comment =~ /^:(\w[^\s;]*)[^;]*;.$/;
    return ($1, $x, $y);
}

1;
__END__


=head1 BUGS

The funge-space representation (a 2-D array) is incredibly wasteful.
Given the difficulty of writing large befunge programs, this should
not be noticeable.


=head1 AUTHOR

Jerome Quelin, E<lt>jquelin@cpan.orgE<gt>


=head1 COPYRIGHT

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=head1 SEE ALSO

L<Language::Befunge>.

=cut
