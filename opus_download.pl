#!/usr/bin/env perl

use strict;
use warnings;

use WWW::YouTube::Download ();

die("No url given\n") unless (@ARGV);

my $client = WWW::YouTube::Download->new();
my $id = WWW::YouTube::Download->video_id($ARGV[0]);

print("Downloading info...\n");
my $info = $client->prepare_download($id);

print("Downloading $info->{title}.$info->{suffix}...\n");
$client->download($id, {filename => "{title}.{suffix}"});

print("Converting to opus...\n");
system("ffmpeg -i \"$info->{title}.$info->{suffix}\" -vn -acodec libopus ".
       "-map_metadata -1 \"$info->{title}.opus\" >/dev/null 2>&1");

print("Removing video file...\n");
unlink("$info->{title}.$info->{suffix}");
