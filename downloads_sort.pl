#!/usr/bin/env perl

use strict;
use warnings;

use File::Copy;

my $config = "$ENV{HOME}/.config/downloads_sort.conf";
open my $in, "<", $config or die "Couldn't open $config\n";

my @tmp;
for (<$in>) {
    $_ =~ s/^\s+//;
$_ =~ s/\s+$//;
    push @tmp, $_ unless $_ =~ /^#|^$/;
}

close $in;

my (@src, @dst);
for (map { 2 * $_ } 0 .. $#tmp / 2) {
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
