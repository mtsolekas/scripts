#!/usr/bin/env perl

use strict;
use warnings;

use File::Copy;

my $config = "$ENV{HOME}/.config/downloads_sort.conf";
open my $in, "<", $config or die "Couldn't open $config\n";
my @tmp = <$in>;
close $in;

my (@src, @dst);
foreach (0..$#tmp/2) {
    $tmp[2*$_] =~ s/\n$//;
    $tmp[2*$_+1] =~ s/\n$//;

    push @src, "$ENV{HOME}/Downloads/$tmp[2*$_]";
    push @dst, "$ENV{HOME}/$tmp[2*$_+1]";
}

my $total = 0;
foreach my $idx (0..$#src) {
    foreach my $file (glob $src[$idx]) {
        move($file, $dst[$idx]);
        ++$total;
    }
}

print "Moved $total file(s)\n";
