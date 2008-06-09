#!perl
#
# This file is part of Language::Befunge.
# Copyright (c) 2001-2008 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

#
# Language::Befunge::Interpreter tests
#

use strict;
use warnings;

use Test::Exception;
use Test::More tests => 33;
use Language::Befunge::Interpreter;


#-- new()
# defaults
my $interp = Language::Befunge::Interpreter->new();
isa_ok($interp, "Language::Befunge::Interpreter");
is($interp->get_dimensions, 2, "default number of dimensions");
is(scalar @{$interp->get_ips()}, 0, "starts out with no IPs");
isa_ok($interp->storage, 'Language::Befunge::Storage::2D::Sparse', "storage object");
is($interp->storage->get_dims, 2, "storage has same number of dimensions");

# templates
$interp = Language::Befunge::Interpreter->new({ syntax => 'befunge98' });
isa_ok($interp, "Language::Befunge::Interpreter");
is($interp->get_dimensions, 2, "default number of dimensions");
is(scalar @{$interp->get_ips()}, 0, "starts out with no IPs");
isa_ok($interp->storage, 'Language::Befunge::Storage::2D::Sparse', "storage object");
is($interp->storage->get_dims, 2, "storage has same number of dimensions");

$interp = Language::Befunge::Interpreter->new({ syntax => 'unefunge98' });
isa_ok($interp, "Language::Befunge::Interpreter");
is($interp->get_dimensions, 1, "correct number of dimensions");
is(scalar @{$interp->get_ips()}, 0, "starts out with no IPs");
isa_ok($interp->storage, 'Language::Befunge::Storage::Generic::AoA', "storage object");
is($interp->storage->get_dims, 1, "storage has same number of dimensions");

$interp = Language::Befunge::Interpreter->new({ syntax => 'trefunge98' });
isa_ok($interp, "Language::Befunge::Interpreter");
is($interp->get_dimensions, 3, "correct number of dimensions");
is(scalar @{$interp->get_ips()}, 0, "starts out with no IPs");
isa_ok($interp->storage, 'Language::Befunge::Storage::Generic::AoA', "storage object");
is($interp->storage->get_dims, 3, "storage has same number of dimensions");

# by dims
$interp = Language::Befunge::Interpreter->new({ dims => 5 });
isa_ok($interp, "Language::Befunge::Interpreter");
is($interp->get_dimensions, 5, "correct number of dimensions");
is(scalar @{$interp->get_ips()}, 0, "starts out with no IPs");
isa_ok($interp->storage, 'Language::Befunge::Storage::Generic::AoA', "storage object");
is($interp->storage->get_dims, 5, "storage has same number of dimensions");

# special storage requirement
$interp = Language::Befunge::Interpreter->new({
    storage => 'Language::Befunge::Storage::Generic::Vec'
});
isa_ok($interp, "Language::Befunge::Interpreter");
is($interp->get_dimensions, 2, "correct number of dimensions");
is(scalar @{$interp->get_ips()}, 0, "starts out with no IPs");
isa_ok($interp->storage, 'Language::Befunge::Storage::Generic::Vec', "storage object");
is($interp->storage->get_dims, 2, "storage has same number of dimensions");

# nonsensical combinations are rejected
throws_ok(sub { Language::Befunge::Interpreter->new({ dims => 3, syntax => 'befunge98' }) },
    qr/only useful for 2-dimensional/, "LBS2S rejects non-2D");
throws_ok(sub { Language::Befunge::Interpreter->new({ storage => 'Nonexistent::Module' }) },
    qr/via package "Nonexistent::Module"/, "unfound Storage module");
throws_ok(sub { Language::Befunge::Interpreter->new({ ops => 'Nonexistent::Module' }) },
    qr/via package "Nonexistent::Module"/, "unfound Ops module");

