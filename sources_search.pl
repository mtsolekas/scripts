#!/usr/bin/env perl

use strict;
use warnings;

use File::Find ();

die("No arguements\n") if ($#ARGV < 0);

my @files;
File::Find::find(sub { push(@files, $File::Find::name)
                       if ($File::Find::name =~ /\.p[yl]$|\.[ch]$/) }, ".");

my @match;
foreach (@files) {
    open(my $in, "<", $_) or next;
    push(@match, $_) if(join("\n", <$in>) =~ /$ARGV[0]/);
    close($in);
}

print("Match found in ", $#match+1, " file(s)\n");
print("$_\n") foreach (@match);
