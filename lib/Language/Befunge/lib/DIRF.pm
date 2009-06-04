#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2009 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

package Language::Befunge::lib::DIRF;

use strict;
use warnings;

sub new { return bless {}, shift; }


#
# C( $directory )
#
# chdir $directory
#
sub C {
    my ($self, $interp) = @_;
    my $ip = $interp->get_curip;

    # pop the values
    my $dir = $ip->spop_gnirts;

    chdir $dir or $ip->dir_reverse;
}

#
# M( $directory )
#
# mkdir $directory
#
sub M {
    my ($self, $interp) = @_;
    my $ip = $interp->get_curip;

    # pop the values
    my $dir = $ip->spop_gnirts;

    mkdir $dir or $ip->dir_reverse;
}


#
# R( $directory )
#
# rmdir $directory
#
sub R {
    my ($self, $interp) = @_;
    my $ip = $interp->get_curip;

    # pop the values
    my $dir = $ip->spop_gnirts;

    rmdir $dir or $ip->dir_reverse;
}


1;

__END__


=head1 NAME

Language::Befunge::IP::lib::DIRF - directory operations



=head1 DESCRIPTION

The DIRF fingerprint (0x44495246) allows to do directory operations.



=head1 FUNCTIONS

=head2 new

Create a new DIRF instance.


=head2 directory operations

=over 4

=item * C( $directory )

chdir C<$directory>.

=item * M( $directory )

mkdir C<$directory>.

=item * R( $directory )

rmdir C<$directory>.


=back



=head1 SEE ALSO

L<Language::Befunge>, L<http://www.rcfunge98.com/rcsfingers.html#DIRF>.



=head1 AUTHOR

Jerome Quelin, C<< <jquelin@cpan.org> >>


=head1 COPYRIGHT & LICENSE

Copyright (c) 2001-2009 Jerome Quelin, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
