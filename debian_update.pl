#!/usr/bin/env perl

use strict;
use warnings;

use Net::Ping ();

my $p = Net::Ping->new();
die("Host unreachable\n") unless ($p->ping("deb.debian.org"));
$p->close();

my $auto = "";
$auto = $ARGV[0] if (@ARGV && $ARGV[0] eq "-y");

die("Error updating package cache\n") if (system("sudo apt-get update"));
system("sudo apt-get clean &&
        sudo apt-get dist-upgrade --no-install-recommends --purge $auto &&
        sudo apt-get autoremove --purge $auto");
