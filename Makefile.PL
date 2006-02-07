#!/usr/bin/env perl
#
# This script writes the Makefile for Language::Befunge
# $Id: Makefile.PL,v 1.4 2006/02/07 14:38:53 jquelin Exp $
#

use strict;
use warnings;

use Config;
use ExtUtils::MakeMaker;
use Getopt::Std;

my @programs_to_install = qw! jqbf98 !;

#---

# Allow us to suppress all program installation with the -n (library only)
# option.  This is for those that don't want to mess with the configuration
# section of this file.
our $opt_n;
die "Usage: $0 [-n]\n" unless getopts('n');
@programs_to_install = () if $opt_n;


# Check where should we install the programs.
if (@programs_to_install) {
    print <<EOT;

   Note that you can avoid these questions by passing
   the '-n' option to 'Makefile.PL'.

This package comes with a Befunge interpreter (jqbf98) that I can try
to install in $Config{sitebin}.
EOT

    my @tmp;
    foreach my $prg (@programs_to_install) {
        push @tmp, $prg 
          if prompt("Do you want to install $prg?", 'y') =~ /^y/i;
    }
    @programs_to_install = @tmp;
}

#---

# Write Makefile.
WriteMakefile(
    NAME          => 'Language::Befunge',
    VERSION_FROM  => 'Befunge.pm',
    EXE_FILES     => [ map "Befunge/bin/$_", @programs_to_install ],
    PREREQ_PM     => { Storable => 0, 'Test::More' => 0 },
    clean         => { FILES => '*~ t/*~ Befunge/*~ Befunge/doc/*~ '
                       . 'Befunge/examples/*~ Befunge/lib/*~'
                       . 'Befunge/bin/*~ MANIFEST.bak' },
    ABSTRACT_FROM => 'Befunge.pm',
    AUTHOR        => 'Jerome Quelin, <jquelin@cpan.org>',
);
