#!/usr/bin/env perl

use strict;
use warnings;

use File::Find;

die "No arguements\n" unless @ARGV;

my (@files, @match);
find({ wanted => sub { push @files, $_ if $_ =~ /\.p[yl]$|\.[ch]$/ },
       no_chdir => 1 }, ".");

foreach (@files) {
    open my $in, "<", $_ or next;
    push @match, $_ if join("\n", <$in>) =~ /$ARGV[0]/;
    close $in;
}

print "Match found in ", $#match + 1, " file(s)\n";
print "$_\n" foreach @match;
