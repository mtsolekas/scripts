#!/usr/bin/env perl

use strict;
use warnings;

die("LibreOffice not installed\n") unless (-f "/usr/bin/libreoffice");
die("No arguements\n") if ($#ARGV < 0);

my @ext = ("/*.ppt", "/*.pptx", "/*.doc", "/*.docx", "/*.odt", "/*.odp");

my @files;
push(@files, glob($ARGV[0].$_)) foreach (@ext);

foreach (@files) {
    print("Converting $_ to PDF\n");
    system("libreoffice --convert-to pdf $_ --outdir $ARGV[0]/ ". 
           "--headless >/dev/null 2>&1");
}

unlink(@files);
