#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;
use Desktop::Notify;

sub get_dates {
    my ($user, $repo, $ua, $notification) = @_;

    my $url = "https://api.github.com/repos/$user/$repo/git/refs/heads/master";
    my $resp = $ua->get("$url/refs/heads/master");
    unless ($resp->is_success) {
        $notification->body("Unable to fetch page");
        $notification->show;
        exit;
    }

    ($url) = $resp->content =~ /"url".*"url"[^"]*"([^"]*)"/;
    $resp = $ua->get($url);
    unless ($resp->is_success) {
        $notification->body("Unable to fetch page");
        $notification->show;
        exit;
    }

    my ($date) = $resp->content =~ /"date".*"date"[^"]*"([^T]*)/;
    return split /-/, $date;
}

my $config = "$ENV{HOME}/.config/repository_watch.conf";
open my $in, "<", $config or die "Couldn't open $config\n";
my @repos = <$in>;
close $in;

my $ua = LWP::UserAgent->new(timeout => 30, env_proxy => 1);
my $notification = Desktop::Notify->new->create(summary => "Repository Watch",
                                                timeout => -1);
my $msg;
while (each @repos) {
    my ($up_user, $up_repo, $or_user, $or_repo) = split / /, $repos[$_];
    $or_repo =~ s/\n//;

    my @up_dates = get_dates($up_user, $up_repo, $ua, $notification);
    my @or_dates = get_dates($or_user, $or_repo, $ua, $notification);

    my @diff = ($up_dates[0] - $or_dates[0],
                $up_dates[1] - $or_dates[1],
                $up_dates[2] - $or_dates[2]);

    $msg .= "\n" if $_;
    $msg .= "$or_repo: ";
    if ($diff[0] > 0
        || ($diff[0] == 0 && $diff[1] > 0)
        || ($diff[0] == 0 && $diff[1] == 0 && $diff[2] > 0)) {
        $msg .= "New commits available"
    } else {
        $msg .= "No new commits"
    }
}

$notification->body($msg);
$notification->show;
