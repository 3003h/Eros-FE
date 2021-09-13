#!/bin/zsh
# shellcheck disable=SC2034
archiverPath="build/ios/archive/fehviewer.xcarchive/Products/Applications/FEhViewer.app";
desPath="$HOME/Public/fehv";

version=$1

if [ $# -eq 0 ];
then
    echo "version empty"
    exit
fi

tempFileName="feh_$version.ipa"
tempDir="$desPath/temp";
tempDirP="$desPath/temp/Payload";

versionDir="$desPath/$version";

tempFilePath="$tempDir/$tempFileName"

rm -rf $tempDir
mkdir $tempDir
mkdir $tempDirP
rm -rf $versionDir
mkdir $versionDir

cp -r $archiverPath $tempDirP

cd $tempDir || exit
zip -qro $tempFilePath "Payload" && mv $tempFilePath $versionDir
