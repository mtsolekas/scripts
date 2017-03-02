#!/usr/bin/env perl

use strict;
use warnings;

use Encode ();
use HTTP::Tiny ();
use Glib::Object::Introspection ();

my $response = HTTP::Tiny->new->get("http://courses.ece.tuc.gr");

Glib::Object::Introspection->setup(basename => "Notify",
                                   version => "0.7",
                                   package => "Notify");
Notify->init;
my $notification = Notify::Notification->new("Courses News");

if ($response->{success}) {
    my ($content) = $response->{content} =~ /Ενημέρωση(.*?)Επιλογές/s;
    $content =~ s/\<.*?\>//g;
    $content =~ s/^\s+|\s+$//g;
    $content =~ s/\n\s*/\n/g;

    my @temp = split(/\n/, $content);
    foreach (0..$#temp/2) {
        $temp[2*$_+1] .= "\n";
    }
    $content = join("\n", @temp);

    $content = Encode::decode("UTF-8", $content);
    $notification->update("Courses News", $content);
} else {
    $notification->update("Courses News", "Unable to fetch page");
}

$notification->show();
