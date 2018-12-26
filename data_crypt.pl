#!/usr/bin/env perl

use strict;
use warnings;

my $usage = "USAGE:\n  Encrypt: data_crypt.pl -e output input\n"
            . "  Decrypt: data_crypt.pl -d input\n";

die "No arguments\n$usage" unless @ARGV;

if ($ARGV[0] eq "-e") {
    die "Output file must be specified\n" unless $ARGV[1];
    die "Input file/directory must be specified\n" unless $ARGV[2];
    die "Input file/directory must exist\n" unless -e $ARGV[2];

    system "tar cvf .tmp_archive $ARGV[2] &&
            gpg -o $ARGV[1] -c .tmp_archive &&
            rm -rf .tmp_archive $ARGV[2]";
} elsif ($ARGV[0] eq "-d") {
    die "Input file must be specified\n" unless $ARGV[1];
    die "Input file/directory must exist\n" unless $ARGV[1];

    system "gpg -o .tmp_archive -d $ARGV[1] &&
            tar xvf .tmp_archive &&
            rm -rf .tmp_archive $ARGV[1]"
} else {
    die "Invalid flag\n$usage";
}
