#!/usr/bin/perl
use strict;
use warnings;

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

my $archiverPath = "build/ios/archive/fehviewer.xcarchive/Products/Applications";
my $desPath = "$ENV{HOME}/Public/fehv";

open(DATA, "<pubspec.yaml") or die "pubspec.yaml 文件无法打开, $!";
my @lines = <DATA>;
my $lines = join('', @lines);
close(DATA);

#print $lines;    # 输出数组内容

my $tempDir = "$desPath/temp";
my $tempDirP = "$desPath/temp/Payload";
if (!-d $tempDir) {
    mkdir($tempDir) or die "无法创建 $tempDir 目录, $!";
}
if (!-d $tempDirP) {
    mkdir($tempDirP) or die "无法创建 $tempDirP 目录, $!";
}

if ($lines =~ /version:\s+(\d+\.\d+\.\d+)\+(\d+)/) {
    my $version = "$1_$2";
    print("$version\n");
    print("$desPath\n");

    my $versionDir = "$desPath/$version";
    if (!-d $versionDir) {
        mkdir($versionDir) or die "无法创建 $versionDir 目录, $!";
    }

    rcopy($archiverPath, $tempDirP) or die $!;

    unlink("$tempDir/.DS_Store");

    my $zip = Archive::Zip->new();
    $zip->addTree($tempDir, '.');

    # Save the Zip file
    unless ( $zip->writeToFileNamed("$versionDir/feh_$version.ipa") == AZ_OK ) {
        die 'write error';
    }
}