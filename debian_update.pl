#!/usr/bin/env perl

use strict;
use warnings;

use Net::Ping ();

my $p = Net::Ping->new();
die("Host unreachable\n") unless ($p->ping("httpredir.debian.org") &&
                                  $p->ping("security.debian.org"));
$p->close();

my $auto = "";
$auto = $ARGV[0] if ($#ARGV >= 0 && $ARGV[0] eq "-y");

die("Error updating package cache\n") if (system("sudo apt-get update"));
system("sudo apt-get clean && sudo apt-get dist-upgrade --purge $auto &&
        sudo apt-get autoremove --purge $auto");
