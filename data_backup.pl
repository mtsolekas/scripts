#!/usr/bin/env perl

use File::Copy::Recursive qw(rcopy);

my $config_path = "$ENV{HOME}/.config/data_backup.conf";
open my $in, "<", $config_path or die "Couldn't open $config_path\n";
my $backup_path = <$in>; chomp $backup_path;
my @files = <$in>; chomp @files;
close $in;

die "Backup path not found\n" unless -d $backup_path;

my @time = localtime;
my $day = $time[3];
my $month = $time[4] + 1;
my $year = $time[5] + 1900;

$backup_path .= "/$year-$month-$day";
print "Backup destination: $backup_path\n";

my $total = $#files + 1;
print "Number of items to backup: $total\n";

for (@files) {
    $| = 1; print "Copying $_ ... "; $| = 0;
    rcopy($_, "$backup_path/$_") and print "Done\n" or print "FAIL\n";
}

print "Done\n";
