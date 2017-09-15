#!/usr/bin/env perl

use strict;
use warnings;

use File::Copy;
use Audio::TagLib;

die "No path specified" unless @ARGV;
my @files = glob "$ARGV[0]/*.opus";

my $num = 0;
my $curr = "";
my ($padd, $diff, $prev);

my ($f, $artist, $title);

$| = 1;

for (@files) {
    $prev = $curr;
    ($curr) = /$ARGV[0]\/(.*)/;
    
    $diff = length($prev) - length($curr);
    $diff = 0 if $diff < 0;
    $padd = " " x $diff;

    print "\r[", ++$num, "/", $#files + 1, "] ",$curr, $padd;

    ($artist) = $curr =~ /(.*) -/; $artist =~ s/^\s+|\s+$//;
    ($title) = $curr =~ /- (.*)/; $title =~ s/^\s+|\.opus$//;

    $f = Audio::TagLib::FileRef->new($_);
    $f->tag()->setArtist(Audio::TagLib::String->new($artist));
    $f->tag()->setTitle(Audio::TagLib::String->new($title));
    $f->save;
}

$| = 0;

if ($#files < 0) {
    die "No files selected\n";
} else {
    print "\nEdited ", $#files + 1, " files\n";
}

unless ("$ARGV[0]/" =~ /Music\//) {
    print "Moving files to music directory\n";
    move($_, "$ENV{HOME}/Music/") for @files;
} else {
    print "Files already in music directory\n";
}

if (-f "$ENV{HOME}/.config/mpd/pid") {
    print "Refreshing MPD\n";
    system "mpc -q clear && mpc -q update &&
            mpc -q add / && mpc -q random on &&
            mpc -q repeat on";
} else {
    print "MPD not running\n";
}
