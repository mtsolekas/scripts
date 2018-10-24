#!/usr/bin/env perl

use strict;
use warnings;
use threads;

use Time::Local;
use LWP::UserAgent;
use Desktop::Notify;

sub get_dates {
    my ($user, $repo) = @_;

    my $ua = LWP::UserAgent->new(timeout => 30, env_proxy => 1);

    my $url = "https://api.github.com/repos/$user/$repo/git/refs/heads/master";
    my $resp = $ua->get($url);
    return unless ($resp->is_success);

    ($url) = $resp->content =~ /"url".*"url"[^"]*"([^"]*)"/;
    $resp = $ua->get($url);
    return unless ($resp->is_success);

    my ($date) = $resp->content =~ /"date".*"date"[^"]*"([^T]*)/;
    my ($year, $month, $day) = split /-/, $date;
    $date = timegm(1, 1, 1, $day, $month - 1, $year);
    return $date;
}

my $config = "$ENV{HOME}/.config/repository_watch.conf";
open my $in, "<", $config or die "Couldn't open $config\n";

my @repos;
for (<$in>) {
    $_ =~ s/^\s+|\s+$//g;
    next if /^#|^$/;
    $_ =~ s/\s+/ /g and push @repos, $_;
}

close $in;

my $msg;
for (@repos) {
    my ($repo, $up_user, $or_user) = split / /, $_;
    my $up_thr = threads->create({ "context" => "scalar" }, "get_dates",
                                 $up_user, $repo);
    my $or_thr = threads->create({ "context" => "scalar" }, "get_dates",
                                 $or_user, $repo);

    $msg .= "\n" if $msg;
    $msg .= "$repo: ";

    my $up_date = $up_thr->join();
    my $or_date = $or_thr->join();

    unless ($up_date && $or_date) {
        $msg .= "Unable to fetch commits";
        next;
    } elsif ($up_date > $or_date) {
        $msg .= "New commits available";
    } else {
        $msg .= "No new commits";
    }
}

my $notification = Desktop::Notify->new->create(summary => "Repository Watch",
                                                timeout => -1);
$notification->body($msg);
$notification->show;
