# This -*- perl -*- script writes the Makefile for Language::Befunge
# $Id: Makefile.PL,v 1.2 2003/02/22 10:31:28 jquelin Exp $

#------------------------------------------#
#          Configuration section.          #
#------------------------------------------#

my @programs_to_install = qw! jqbf98 !;


# /!\ You should not modify anything below this line /!\ #


#---------------------------------#
#          Main program.          #
#---------------------------------#

# The modules.
use strict;
use Config;
use ExtUtils::MakeMaker;
use Getopt::Std;

# The vars.
use vars qw($opt_n);


# Allow us to suppress all program installation with the -n (library only)
# option.  This is for those that don't want to mess with the configuration
# section of this file.
die "Usage: $0 [-n]\n" unless ( getopts("n") );
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
          if prompt("Do you want to install $prg?", "y") =~ /^y/;
    }
    @programs_to_install = @tmp;
}


# Check for non-standard modules that are used by this library.
$| = 1;
my $missing_modules = 0;

print "Checking for Storable...";
eval {
    require Storable;
    Storable->VERSION(0);
};
if ($@) {
    print " failed\n";
    $missing_modules++;
    print <<EOT;
$@
The Storable module must be installed. I need it for the Befunge
interpreter to be Concurrent Befunge!

EOT
    sleep(2);  # Don't hurry too much
} else {
    print " ok\n";
}

# Warn user.
print <<EOT if $missing_modules;
The missing modules can be obtained from CPAN.  Visit
<URL:http://www.perl.com/CPAN/> to find a CPAN site near you.

EOT

print "\n";

WriteMakefile(
    NAME          => 'Language::Befunge',
    VERSION_FROM  => 'Befunge.pm',
    EXE_FILES     => [ map "Befunge/bin/$_", @programs_to_install ],
    PREREQ_PM     => { Storable => 0 },
    clean         => { FILES => "*~ t/*~ Befunge/*~ Befunge/doc/*~ Befunge/examples/*~ Befunge/lib/*~ Befunge/bin/*~ MANIFEST.bak" },
    ABSTRACT_FROM => 'Befunge.pm', # retrieve abstract from module
    AUTHOR        => 'Jerome Quelin, <jquelin@cpan.org>',
);
