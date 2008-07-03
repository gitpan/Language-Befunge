package Language::Befunge::lib::TEST;

use strict;
use warnings;
use Test::Builder;

my $Tester = Test::Builder->new();

sub new { return bless {}, shift; }

# P = plan()
# num -
sub P {
    my ( $self, $interp ) = @_;
    my $tests = $interp->get_curip()->spop();
    $Tester->plan( $tests ? ( tests => $tests ) : 'no_plan' );
}

# O = ok()
# 0gnirts bool -
sub O {
    my ( $self, $interp ) = @_;
    my $ip = $interp->get_curip();

    # pop the args and output the test result
    my $ok  = $ip->spop();
    my $msg = $ip->spop_gnirts();
    $Tester->ok( $ok, $msg );
}

# I = is()
# 0gnirts expected got -
sub I {
    my ( $self, $interp ) = @_;
    my $ip = $interp->get_curip();

    my ( $got, $expected ) = ( $ip->spop(), $ip->spop() );
    my $msg = $ip->spop_gnirts();
    $Tester->is_eq( $got, $expected, $msg );
}

'ok';

__END__

=head1 NAME

Language::Befunge::IP::lib::TEST - a Befunge extension to run tests

=head1 SYNOPSIS

    P - plan
    O - ok
    I - is

=head1 DESCRIPTION

This extension provide a way for Befunge test programs to easily produce
valid TAP output.

=head1 FUNCTIONS

=head2 new

Create a new TEST instance.

=head2 P

Pops a number off the TOSS, and use it for the plan.

If the number is zero, then the number of tests run is listed at the
end of the test script (i.e. C<no_plan>).

=head2 O

Pop a value and a message off the TOSS.

If the value is zero, outputs a C<not ok>, otherwise a C<ok>.

=head2 I

Pop two values and a message off the TOSS.

If the two values are equel, the test passes, otherwise it fails.

=head1 SEE ALSO

L<Language::Befunge>.

=head1 AUTHOR

Philippe Bruhat (BooK) - C<< <book@cpan.org> >>.

=head1 COPYRIGHT

Copyright 2008 Philippe Bruhat (BooK), All Rights Reserved.
 
=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

