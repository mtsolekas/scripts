#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent ();

my $ua = LWP::UserAgent->new(timeout => 60,
                             env_proxy => 1,
                             show_progress => 1);

my $response = $ua->get("http://gluonhq.com/download/scene-builder-jar/");
die("Download failed\n") unless ($response->is_success());

my $target = $ENV{HOME}."/Workspace/SceneBuilder.jar";
unlink($target) if (-f $target);

open(my $out, ">", $target);
print ($out $response->content);
close($out);
