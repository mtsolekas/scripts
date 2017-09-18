#!/usr/bin/env perl

use strict;
use warnings;

use File::Find;

die "No arguments\n" unless @ARGV;

my (@files, @match);
find({ wanted => sub { push @files, $_ if /\.p[yl]$|\.[ch]$/ }, no_chdir => 1 },
     ".");

for (@files) {
    open my $in, "<", $_ or next;
    push @match, $_ if join("\n", <$in>) =~ /$ARGV[0]/;
    close $in;
}

print "Match found in ", $#match + 1, " file(s)\n";
print "$_\n" for @match;
