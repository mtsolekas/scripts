#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;

my $ua = LWP::UserAgent->new(timeout => 30, env_proxy => 1);
my $response = $ua->get("http://courses.ece.tuc.gr");

if ($response->is_success) {
    my ($news) = $response->content =~ /Ενημέρωση(.*?)Επιλογές/s;

    if ($news) {
        $news =~ s/<[^>]*>//g;
        $news =~ s/^\s+|\s+$//g;
        $news =~ s/\n\s*/\n/g;
        $news =~ s/(\n[0-9])/\n$1/g;
    } else {
        $news = "Service unavailable";
    }

    system "notify-send", "Courses News", "$news";
} else {
    system "notify-send", "Courses News", "Unable to fetch page";
}
