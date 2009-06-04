#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2009 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

package Language::Befunge::lib::FOO;

use strict;
use warnings;

sub new { return bless {}, shift; }

sub P {
    print "foo";
}

1;
__END__

=head1 NAME

Language::Befunge::IP::lib::FOO - a Befunge extension to print foo


=head1 SYNOPSIS

    P - print "foo"

=head1 DESCRIPTION

This extension is just an example of the Befunge extension mechanism
of the Language::Befunge interpreter.


=head1 FUNCTIONS

=head2 new

Create a FOO instance.


=head2 P

Output C<foo>.


=head1 SEE ALSO

L<Language::Befunge>.


=head1 AUTHOR

Jerome Quelin, E<lt>jquelin@cpan.orgE<gt>


=head1 COPYRIGHT & LICENSE

Copyright (c) 2001-2009 Jerome Quelin, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
