#!/usr/bin/env perl

use strict;
use warnings;

use File::Copy;

my $config = "$ENV{HOME}/.config/downloads_sort.conf";
open my $in, "<", $config or die "Couldn't open $config\n";

my (@src, @dst);
for (<$in>) {
    $_ =~ s/^\s+//;
    $_ =~ s/\s+$//;
    unless ($_ =~ /^#|^$/) {
        push @src, "$ENV{HOME}/Downloads/$_" and next if $#src == $#dst;
        push @dst, "$ENV{HOME}/$_" if $#src != $#dst;
    }
}

close $in;

my $total = 0;
for my $idx (0..$#src) {
    for my $file (glob $src[$idx]) {
        move($file, $dst[$idx]);
        ++$total;
    }
}

print "Moved $total file(s)\n";
