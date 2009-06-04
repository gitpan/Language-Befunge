#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2009 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

package Language::Befunge::Debug;

use 5.010;
use strict;
use warnings;

use base qw{ Exporter };
our @EXPORT = qw{ debug };


# -- public subs

sub debug {}

my %redef;
sub enable {
    %redef = ( debug => sub { warn @_; } );
    _redef();
}

sub disable {
    %redef = ( debug => sub {} );
    _redef();
}


# -- private subs

#
# _redef()
#
# recursively walk the symbol table, and replace subs named after %redef
# keys with the matching value of %redef.
#
# this is not really clean, but since the sub debug() is exported in
# other modules, replacing the sub in *this* module is not enough: other
# modules still refer to their local copy.
#
# also, calling sub with full name Language::Befunge::Debug::debug() has
# performance issues (10%-15%) compared to using an exported sub...
#
my %orig; # original subs
sub _redef {
    my $parent = shift;
    if ( not defined $parent ) {
        $parent = '::';
        foreach my $sub ( keys %redef ) {
            $orig{ $sub } = \&$sub;
        }
    }
    no strict   'refs';
    no warnings 'redefine';
    foreach my $ns ( grep /^\w+::/, keys %{$parent} ) {
        $ns = $parent . $ns;
        _redef($ns) unless $ns eq '::main::';
        foreach my $sub (keys %redef) {
            next                                       # before replacing, check that...
                unless exists ${$ns}{$sub}             # named sub exist...
                && \&{ ${$ns}{$sub} } == $orig{$sub};  # ... and refer to the one we want to replace
            *{$ns . $sub} = $redef{$sub};
        }
    }
}

1;

__END__

=head1 NAME

Language::Befunge::Debug - optimized debug solution for language::befunge


=head1 SYNOPSIS

    use Language::Befunge::Debug;
    debug("foo\n");     # does nothing by default
    Language::Befunge::Debug::enable();
    debug("bar\n");     # now that debug is enabled, output on STDERR
    Language::Befunge::Debug::disable();
    debug("baz\n");     # sorry dave, back to no output



=head1 DESCRIPTION

This module provides a C<debug()> subroutine, which output on STDERR if
debugging is enabled. If debugging is disabled (the default), perl will
optimize out those debugging calls.



=head1 PUBLIC API

=head2 Exported functions

The module is exporting only one function:

=over 4

=item * debug( @stuff );

If debugging is enabled (which is B<not> the default), write C<@stuff>
on STDERR.

=back


=head2 Other functions

The module also provides 2 functions to control debugging:

=over 4

=item * Language::Befunge::Debug::enable();

Request that calls to C<debug()> really start output on STDERR.


=item * Language::Befunge::Debug::disable();

Request that calls to C<debug()> stop output-ing on STDERR.


=back



=head1 SEE ALSO

L<Language::Befunge>



=head1 AUTHOR

Jerome Quelin, C<< <jquelin@cpan.org> >>

Development is discussed on C<< <language-befunge@mongueurs.net> >>



=head1 COPYRIGHT & LICENSE

Copyright (c) 2001-2009 Jerome Quelin, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

