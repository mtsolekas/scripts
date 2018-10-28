#!/usr/bin/env perl

use strict;
use warnings;

use File::Path;

my $config_path = "$ENV{HOME}/.config/data_backup.conf";
open my $in, "<", $config_path or die "Couldn't open $config_path\n";

my ($backup_path, @files, @orphans, @root_files);
for (<$in>) {
    $_ =~ s/^\s+|\s+$//g;
    next if /^#|^$/;

    s/\/+$//g and $backup_path = $_ and next unless $backup_path;
    s/^\///g and push @root_files, $_ and next unless /$ENV{HOME}/;
    s/$ENV{HOME}\/?//g and push @orphans, $_ and next unless -d $_;
    push @files, $_;
}

close $in;

die "Backup path not found\n" unless -d $backup_path;

my @time = localtime;
my ($year, $month, $day) = ($time[5] + 1900, $time[4] + 1, $time[3]);

$backup_path .= "/$year-$month-$day";
File::Path::make_path($backup_path);
print "Backup destination: $backup_path\n";

my $total = $#root_files + $#orphans + $#files + 3;
print "Number of items to backup: $total\n";

for (@files) {
    my $name = $_;
    $name =~ s/\/$//g;
    $name =~ s/.*\///g;

    $| = 1; print "Backing up $_ to $name.tgz ... "; $| = 0;
    system "tar czf $backup_path/$name.tgz -C $_/../ $name";
    print "Done\n";
}

if (@orphans) {
    print "Backing up orphan files to orphans.tgz ... ";
    system "tar czf $backup_path/orphans.tgz -C $ENV{HOME}/ @orphans";
    print "Done\n";
}

if (@root_files) {
    print "Backing up root files to root_files.tgz ... ";
    system "tar czf $backup_path/root_files.tgz -C / @root_files";
    print "Done\n";
}

print "Done\n";
