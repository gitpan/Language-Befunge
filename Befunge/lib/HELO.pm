# $Id: HELO.pm,v 1.2 2002/04/14 13:14:16 jquelin Exp $
#
# Copyright (c) 2002 Jerome Quelin <jquelin@cpan.org>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package Language::Befunge::lib::HELO;

=head1 NAME

Language::Befunge::IP::lib::HELO - a Befunge extension to print Hello world!


=head1 SYNOPSIS

    P - print "Hello world!\n"
    S - store the gnirts "Hello world!\n"0 on the TOSS

=head1 DESCRIPTION

This extension is just an example of the Befunge extension mechanism
of the Language::Befunge interpreter.

=cut

# A little anal retention ;-)
use strict;
use warnings;

=head1 FUNCTIONS

=head2 P

Output C<Hello world!\n>.

=cut
sub P {
    print "Hello world!\n";
}

=head2 S

Store the gnirts "Hello world!\n"0 on the TOSS.

=cut
sub S {
    my $interp = shift;
    $interp->curip->spush( reverse map { ord } split //, "Hello world!\n".chr(0) );
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
