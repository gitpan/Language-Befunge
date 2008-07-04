#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

package Language::Befunge::Wrapping;

use strict;
use warnings;

use base qw{ Class::Accessor::Fast };

# -- CONSTRUCTOR

#
# provided by Class::Accessor::Fast
#


# -- PUBLIC METHODS

#
# $wrapping->wrap( $storage, $ip );
#
# Wrap $ip in $storage according to this module wrapping algorithm. Note
# that $ip is already out of bounds, ie, it has been moved once by LBI.
# As a side effect, $ip will have its position changed.
#
# LBW implements a wrapping that dies. It's meant to be overridden by
# other wrapping classes.
#
sub wrap { die 'wrapping not implemented in LBW'; }

1;
__END__


=head1 NAME

Language::Befunge::Wrapping - base wrapping class


=head1 DESCRIPTION

C<LBW> implements a wrapping that dies. It's meant to be overridden by
other wrapping classes.



=head1 CONSTRUCTOR

=head2 LBW->new;

Creates a new wrapping object.


=head1 PUBLIC METHODS

=head2 $wrapping->wrap( $storage, $ip )

Wrap C<$ip> in C<$storage> according to this module wrapping algorithm.
See L<DESCRIPTION> for an overview of the algorithm used.

Note that C<$ip> is already out of bounds, ie, it has been moved once by
LBI.

As a side effect, $ip will have its position changed.



=head1 SEE ALSO

L<Language::Befunge>.


=head1 AUTHOR

Jerome Quelin, C<< <jquelin@cpan.org> >>


=head1 COPYRIGHT & LICENSE

Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

