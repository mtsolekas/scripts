#!/usr/bin/env perl

use strict;
use warnings;

die("LibreOffice not installed\n") unless (-f "/usr/bin/libreoffice");
die("No arguements\n") unless (@ARGV);

my @ext = ("/*.ppt", "/*.pptx", "/*.doc", "/*.docx", "/*.odt", "/*.odp");
my @files = map(glob($ARGV[0].$_), @ext);

foreach (@files) {
    print("Converting $_ to PDF\n");
    system("libreoffice --convert-to pdf $_ --outdir $ARGV[0]/ ".
           "--headless >/dev/null 2>&1");
}

unlink(@files);
