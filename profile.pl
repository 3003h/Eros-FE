#!/usr/bin/perl
use strict;
use warnings;

my $devicesId = "cd3af462";

open(DATA, "<pubspec.yaml") or die "pubspec.yaml 文件无法打开, $!";
my @lines = <DATA>;
my $lines = join('', @lines);
close(DATA);

if ($lines =~ /version:\s+(\d+\.\d+\.\d+)\+(\d+)/) {
    my $apkName = "feh-v$1+$2-profile.apk";
    system("flutter run --profile --purge-persistent-cache --use-application-binary=build/app/outputs/apk/profile/$apkName -d $devicesId");
}