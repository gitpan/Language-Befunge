# $Id: FOO.pm,v 1.1 2002/04/13 09:37:56 jquelin Exp $
#
# Copyright (c) 2002 Jerome Quelin <jquelin@cpan.org>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package Language::Befunge::lib::FOO;

=head1 NAME

Language::Befunge::IP::lib::FOO - a Befunge extension to print foo


=head1 SYNOPSIS

    P - print "foo"

=head1 DESCRIPTION

This extension is just an example of the Befunge extension mechanism
of the Language::Befunge interpreter.

=cut

# A little anal retention ;-)
use strict;
use warnings;

=head1 FUNCTIONS

=head2 P

Output C<foo>.

=cut
sub P {
    print "foo";
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