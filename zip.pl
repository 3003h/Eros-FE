#!/usr/bin/perl
use strict;
use warnings;

open(DATA, "<pubspec.yaml") or die "pubspec.yaml 文件无法打开, $!";
my @lines = <DATA>;
my $lines = join('', @lines);
close(DATA);

if ($lines =~ /version:\s+(\d+\.\d+\.\d+)\+(\d+)/) {
    my $version = "$1_$2";
    `./zip.sh $version`;
}