#!/usr/bin/env perl

use strict;
use warnings;

use Encode;
use LWP::UserAgent;
use Glib::Object::Introspection;

my $ua = LWP::UserAgent->new(timeout => 30, env_proxy => 1);
my $response = $ua->get("http://courses.ece.tuc.gr");

Glib::Object::Introspection->setup(basename => "Notify",
                                   version => "0.7",
                                   package => "Notify");
Notify->init;
my $notification = Notify::Notification->new("Courses News");

if ($response->is_success) {
    my ($content) = $response->content =~ /Ενημέρωση(.*?)Επιλογές/s;
    $content =~ s/\<.*?\>//g;
    $content =~ s/^\s+|\s+$//g;
    $content =~ s/\n\s*/\n/g;

    my @tmp = split /\n/, $content;
    $tmp[2*$_+1] .= "\n" for 0..$#tmp/2;
    $content = join "\n", @tmp;

    $content = decode("UTF-8", $content);
    $notification->update("Courses News", $content);
} else {
    $notification->update("Courses News", "Unable to fetch page");
}

$notification->show;
