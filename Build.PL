#!/usr/bin/env perl
#
# This script writes the Build utility for Language::Befunge
# $Id: Build.PL,v 1.1 2006/02/07 14:38:53 jquelin Exp $
#

use strict;
use warnings;

use Config;
use Getopt::Std;
use Module::Build;

my @programs_to_install = qw! jqbf98 !;

#---

# We need to create the object first.
my $builder = Module::Build->new
  ( module_name       => 'Language::Befunge',
    license           => 'perl',
    dist_author       => 'Jerome Quelin <jquelin@cpan.org>',
    dist_version_from => 'Befunge.pm',
    build_requires    => { 'Test::More' => 0 },
    requires          => { 'Storable'   => 0 },
    pm_files          =>
      { 'Befunge.pm'            => 'lib/Language/Befunge.pm',
        'Befunge/IP.pm'         => 'lib/Language/Befunge/IP.pm',
        'Befunge/LaheySpace.pm' => 'lib/Language/Befunge/LaheySpace.pm',
        'Befunge/lib/FOO.pm'    => 'lib/Language/Befunge/lib/FOO.pm',
        'Befunge/lib/HELO.pm'   => 'lib/Language/Befunge/lib/HELO.pm',
      },
    add_to_cleanup    =>
      [ 'Language-Befunge-*', '*~', 't/*~', 'Befunge/*~',
        'Befunge/doc/*~', 'Befunge/examples/*~','Befunge/lib/*~',
        'Befunge/bin/*~', 'MANIFEST.bak'
      ],
    #recursive_test_files => 1
  );


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
          if $builder->prompt("Do you want to install $prg?", 'y') =~ /^y/i;
    }
    @programs_to_install = @tmp;
}


$builder->script_files( [ map "Befunge/bin/$_", @programs_to_install ] );

#---

# Everything is collected, write the Build script.
$builder->create_build_script;

