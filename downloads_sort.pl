#!/usr/bin/env perl

use strict;
use warnings;

use File::Copy;

my $config = "$ENV{HOME}/.config/downloads_sort.conf";
open my $in, "<", $config or die "Couldn't open $config\n";
my @tmp = <$in>;
close $in;

my (@src, @dst);
for (map { 2 * $_ } 0 .. $#tmp / 2) {
    $tmp[$_] =~ s/\n$//;
    $tmp[$_+1] =~ s/\n$//;

    push @src, "$ENV{HOME}/Downloads/$tmp[$_]";
    push @dst, "$ENV{HOME}/$tmp[$_+1]";
}

my $total = 0;
for my $idx (0..$#src) {
    for my $file (glob $src[$idx]) {
        move($file, $dst[$idx]);
        ++$total;
    }
}

print "Moved $total file(s)\n";
