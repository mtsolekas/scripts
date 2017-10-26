#!/usr/bin/env perl

use strict;
use warnings;

use File::Find;

die "No arguments\n" unless @ARGV;

my @files;
find({ wanted => sub { push @files, $_ if /\.p[yl]$|\.[ch]$/ }, no_chdir => 1 },
     ".");

for my $f (@files) {
    open my $in, "<", $f or next;
    my @contents = <$in>;
    close $in;

    print "$f:\n" if join("\n", @contents) =~ /$ARGV[0]/;

    my $line_num = 0;
    for my $line (@contents) {
        ++$line_num;
        $line =~ s/^\s*//;
        print "    line $line_num: $line" if $line =~ /$ARGV[0]/;
    }
}
