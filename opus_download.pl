#!/usr/bin/env perl

use strict;
use warnings;

use WWW::YouTube::Download ();

die("No url given\n") unless (@ARGV);

my $client = WWW::YouTube::Download->new();
my $id = WWW::YouTube::Download->video_id($ARGV[0]);

print("Downloading info\n");
my $info = $client->prepare_download($id);

print("Downloading $info->{title}\n");
$client->download($id, {fmt => 43, filename => "temp.webm"});

print("Converting to opus\n");
system("avconv -i temp.webm -vn -acodec libopus \"$info->{title}.opus\"");
unlink("temp.webm");
