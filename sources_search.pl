#!/usr/bin/env perl

use strict;
use warnings;

use File::Find;
use Term::ANSIColor;

die "No arguments\n" unless @ARGV;

my @files;
find({ wanted => sub { push @files, $_ if /\.p[yl]$|\.[ch]$/ }, no_chdir => 1 },
     ".");

for my $f (@files) {
    open my $in, "<", $f or next;
    my @contents = <$in>;
    close $in;

    print color("bold");
    print "$f:\n" if join("\n", @contents) =~ /$ARGV[0]/;
    print color("reset");

    my $line_num = 0;
    for my $line (@contents) {
        ++$line_num;
        $line =~ s/^\s*//;
        print "\tline $line_num: $line" if $line =~ /$ARGV[0]/;
    }
}
