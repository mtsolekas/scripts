#!/usr/bin/env perl

use strict;
use warnings;

use File::Copy;
use Audio::TagLib;

die "No path specified\n" unless @ARGV;
my @files = glob "$ARGV[0]/*.opus";

my $num = 0;
my $skip = 0;
my $curr = "";
my ($padd, $diff, $prev);

my ($f, $artist, $title, $prev_artist, $prev_title);

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
    $prev_artist = $f->tag()->artist()->toCString();
    $prev_title = $f->tag()->title()->toCString();

    ++$skip and next if ($prev_artist eq $artist and $prev_title eq $title);

    $f->tag()->setArtist(Audio::TagLib::String->new($artist));
    $f->tag()->setTitle(Audio::TagLib::String->new($title));
    $f->save;
}

$| = 0;

if ($#files < 0) {
    die "No files selected\n";
} else {
    print "\nEdited ", $#files + 1 - $skip, " files($skip skipped)\n";
}

unless ("$ARGV[0]/" =~ /Music\//) {
    print "Moving files to music directory\n";
    move($_, "$ENV{HOME}/Music/") for @files;
} else {
    print "Files already in music directory\n";
}

if ($#files + 1 != $skip and -f "$ENV{HOME}/.config/mpd/pid") {
    print "Refreshing MPD\n";
    system "mpc -q clear && mpc -q update &&
            mpc -q add / && mpc -q random on &&
            mpc -q repeat on";
} else {
    print "Refreshing MPD not required\n";
}
