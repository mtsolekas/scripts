#!/usr/bin/env perl

use strict;
use warnings;

die "No arguments\n" unless @ARGV;

unless (-f "$ENV{HOME}/.config/mpd/pid") {
    system "mpd && mpc -q clear && mpc -q update &&
            mpc -q add / && mpc -q random on &&
            mpc -q repeat on";
}

system "mpc -q $ARGV[0]";
