#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

package Language::Befunge::lib::BASE;

use strict;
use warnings;

use Math::BaseCalc;

sub new { return bless {}, shift; }

my @digits = ( 0 .. 9, 'a'..'z' );

# -- outputs

#
# B( $n )
#
# Output top of stack in binary.
#
sub B { 
	my ($self, $lbi) = @_;
	printf "%b", $lbi->get_curip->spop;
}


#
# H( $n )
#
# Output top of stack in binary.
#
sub H {
	my ($self, $lbi) = @_;
	printf "%x", $lbi->get_curip->spop;
}


#
# N( $n, $b )
#
# Output $n in base $b.
#
sub N {
	my ($self, $lbi) = @_;
	my $ip = $lbi->get_curip;
	my $b = $ip->spop;
	my $n = $ip->spop;
	if ( $b == 0 || $b == 1 || $b > scalar(@digits) ) {
		# bases 0 and 1 are not valid.
		# bases greater than 36 require too much chars.
		$ip->dir_reflect;
		return;
	}
	my $bc = Math::BaseCalc->new(digits=> [ @digits[0..$b-1] ]);
	print $bc->to_base( $n );
}

#
# O( $n )
#
# Output top of stack in octal.
#
sub O {
	my ($self, $lbi) = @_;
	printf "%o", $lbi->get_curip->spop;
}


# -- input

#
# $n = I( $b )
#
# Input value in specified base, and push it on the stack.
#
sub I {
    my ($self, $lbi) = @_;
    my $ip = $lbi->get_curip;
    my $in = $lbi->get_input;
    return $ip->dir_reverse unless defined $in;
    my $b = $ip->spop;
    if ( $b == 0 || $b == 1 || $b > scalar(@digits) ) {
		# bases 0 and 1 are not valid.
		# bases greater than 36 require too much chars.
		$ip->dir_reflect;
		return;
	}
	my $bc = Math::BaseCalc->new(digits=> [ @digits[0..$b-1] ]);
    
    $ip->spush( $bc->to_base( $in ) );
}



1;

__END__


=head1 NAME

Language::Befunge::IP::lib::BASE - Non-standard math bases extension



=head1 DESCRIPTION


The BASE fingerprint (0x42415345) allows numbers to be output-ed in whatever
base you want. Note that bases are limited to base 36 maximum for practical
reasons (missing chars to represent high numbers)



=head1 FUNCTIONS

=head2 new

Create a new BASE instance.


=head2 Output

=over 4

=item B( $n )

Output top of stack in binary.


=item H( $n )

Output top of stack in hexa.


=item N( $n, $b )

Output C<$n> in base C<$b>.


=item O( $n )

Output top of stack in octal.


=back


=head2 Input

=over 4

=item $n = I( $b )

Input value in specified base, and push it on the stack.

=back



=head1 SEE ALSO

L<Language::Befunge>, L<http://www.rcfunge98.com/rcsfingers.html#BASE>.



=head1 AUTHOR

Jerome Quelin, C<< <jquelin@cpan.org> >>


=head1 COPYRIGHT & LICENSE

Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
