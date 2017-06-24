#!/usr/bin/env perl

use strict;
use warnings;

use WWW::YouTube::Download ();

die("No url given\n") unless (@ARGV);

my $client = WWW::YouTube::Download->new();
my $id = WWW::YouTube::Download->video_id($ARGV[0]);

$client->download($id, {fmt => 43, filename => "temp.webm"});

my $info = $client->prepare_download($id);
system("avconv -i temp.webm -vn -acodec copy \"$info->{title}.opus\"");
unlink("temp.webm");
