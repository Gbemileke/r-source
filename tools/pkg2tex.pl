### $Id: pkg2tex.pl,v 1.3 2002/11/03 17:32:29 hornik Exp $

## Create a single pkgname-pkg.tex file from the Latex subdirectories
## Copyright (C) 1998 Douglas M. Bates <bates@stat.wisc.edu>

## This file is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.

## This file is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## A copy of the GNU General Public License is available via WWW at
## http://www.gnu.org/copyleft/gpl.html.  You can also obtain it by
## writing to the Free Software Foundation, Inc., 59 Temple Place, 
## Suite 330, Boston, MA  02111-1307  USA

## Send any bug reports to bates@stat.wisc.edu

## <NOTE>
## Could use &file_path() to make this portable.
## </NOTE>

use strict;
use FileHandle;
use Carp;
use Getopt::Long;

my $help;

my $revision = ' $Revision: 1.3 $ ';
my $version;
my $name;

($name = $0) =~ s|.*/||;
$revision =~ / ([\d\.]*) /;
$version = $1;

GetOptions("help|h" => \$help);
&usage() if $help;
&usage() if $#ARGV < 0;

my $RLIB;
if ($ENV{'RLIB'}) {
    ## Set under Windows, but also useful to override the default.
    $RLIB = $ENV{'RLIB'};
} else {
    $RLIB = "../../library";
}

for (@ARGV) {
    my $latexDir = $RLIB . "/" . $_ . "/latex/";
    carp "latex subdirectory for library $_ does not exist!\n", next
	unless -d $latexDir;
    my $out = new FileHandle "> " . $_ . "-pkg.tex" or
	croak "unable to open file $_-pkg.tex: $!\n";
    &do_header($_, $out);
    &do_tex_files($latexDir, $out);
    &do_trailer($out);
    $out->close;
}

sub do_header {
    my( $pkgname, $outfile ) = @_;
    $outfile->print("\n\\chapter\{The \\texttt\{$pkgname\} package\}\n");
}

sub foldorder {uc($a) cmp uc($b) or $a cmp $b;}
sub do_tex_files {
    my( $latexDir, $outfile ) = @_;
    my $fh = new FileHandle;
    my $fname;
    my $fline;
    my %filenames;

    opendir DIR, $latexDir or
	croak "can't open directory $latexDir: $!\n";
    foreach $fname ( grep /^[A-za-z].*\.tex$/, readdir DIR ) 
    {
	$fh->open( $latexDir . $fname ) 
	    or croak "unable to open file $_:$!\n";
	$fline = <$fh>;
	## first line is \Header{object}{...}
	$fline =~ s/\\Header\{\s*([^}]*)\}//;
	$filenames{$1} = $fname;
    }
    close $fh;

    foreach $fname (sort foldorder keys %filenames)
    {
	$fh->open( $latexDir . $filenames{$fname} ) 
	    or croak "unable to open file $_:$!\n";
	$outfile->print( <$fh> );
    }
    close $fh;
}

sub do_trailer {
    my $outfile = shift;
    $outfile->print("\\clearpage");
}

sub usage {

    print "$name version $version\n";
    print "Usage: $name [--help/-h] file ..." ;

    exit 0;
}

### Local variables: ***
### mode: perl ***
### perl-indent-level: 4 ***
### End: ***
