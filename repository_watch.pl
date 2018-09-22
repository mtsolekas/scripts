#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;
use Desktop::Notify;

sub get_dates {
    my ($user, $repo, $ua, $notification) = @_;

    my $res = $ua->get("https://github.com/$user/$repo/commits/master");
    unless ($res->is_success) {
        $notification->body("Unable to fetch page");
        $notification->show;
        exit;
    }

    my %months = (Jan => 1, Feb => 2, Mar => 3, Apr => 4,
                  May => 5, Jun => 6, Jul => 7, Aug => 8,
                  Sep => 9, Oct => 10, Nov => 11, Dec => 12);
    my ($date) = $res->content =~ /Commits on (.*)/; $date =~ s/,//;
    my @dates = split / /, $date; $dates[0] = $months{$dates[0]};
    return @dates;
}

my $config = "$ENV{HOME}/.config/repository_watch.conf";
open my $in, "<", $config or die "Couldn't open $config\n";
my @repopairs = <$in>;
close $in;

my $ua = LWP::UserAgent->new(timeout => 30, env_proxy => 1);
my $notification = Desktop::Notify->new->create(summary => "Repository Watch",
                                                timeout => -1);
my $msg;
while (each @repopairs) {
    my ($uuser, $urepo, $ouser, $orepo) = split / /, $repopairs[$_];
    $orepo =~ s/\n//;

    my @udates = get_dates($uuser, $urepo, $ua, $notification);
    my @odates = get_dates($ouser, $orepo, $ua, $notification);

    my @diff = ($udates[2] - $odates[2],
                $udates[0] - $odates[0],
                $udates[1] - $odates[1]);

    $msg .= "\n" if $_;
    $msg .= "$orepo: ";
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
