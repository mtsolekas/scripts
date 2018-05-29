#!/usr/bin/env perl

use strict;
use warnings;

use File::Path qw(make_path);

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
make_path($backup_path);
print "Backup destination: $backup_path\n";

my $total = $#files + 1;
print "Number of items to backup: $total\n";

my (@orphans, @root_files);
my $name;

for (@files) {
    s/^\///g and push @root_files, $_ and next unless /$ENV{HOME}/;
    s/$ENV{HOME}\/?//g and push @orphans, $_ and next unless -d $_;

    $name = $_;
    $name =~ s/\/$//g;
    $name =~ s/.*\///g;

    $| = 1; print "Backing up $_ to $name.tgz ... "; $| = 0;
    system "tar czf $backup_path/$name.tgz -C $_/../ $name";
    print "Done\n";
}

if (@orphans) {
    $| = 1; print "Backing up orphan files to orphans.tgz ... "; $| = 0;
    system "tar czf $backup_path/orphans.tgz -C $ENV{HOME} @orphans";
    print "Done\n";
}

if (@root_files) {
    $| = 1; print "Backing up root files to root_files.tgz ... "; $| = 0;
    system "tar czf $backup_path/root_files.tgz -C / @root_files";
    print "Done\n";
}

print "Done\n";
