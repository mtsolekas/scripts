#!/usr/bin/env perl

use strict;
use warnings;

die("LibreOffice not installed\n") unless (-f "/usr/bin/libreoffice");
die("No arguements\n") if ($#ARGV < 0);

my @files = glob($ARGV[0]."/*.ppt");
push(@files, glob($ARGV[0]."/*.pptx"));
push(@files, glob($ARGV[0]."/*.doc"));
push(@files, glob($ARGV[0]."/*.docx"));
push(@files, glob($ARGV[0]."/*.odt"));
push(@files, glob($ARGV[0]."/*.odp"));

foreach (@files) {
    print("Converting $_ to PDF\n");
    system("libreoffice --convert-to pdf $_ --outdir $ARGV[0]/ ". 
           "--headless >/dev/null 2>&1");
}

unlink(@files);
