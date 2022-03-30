#!/bin/zsh
# shellcheck disable=SC2034
archiverPath="build/macos/Build/Products/Release/fehviewer.app";
desPath="$HOME/Public/fehv";

dmg(){
  echo "hdiutil create -fs HFS+ -srcfolder $1 -volname $2 $3.dmg"
  hdiutil create -fs HFS+ -srcfolder "$1" -volname "$2" "$3.dmg"
}

version=$1

if [ $# -eq 0 ];
then
    echo "version empty"
    exit
fi

tempDirName="macos_temp"
tempFileName="feh_$version"
tempPath="$desPath/$tempDirName";

versionDir="$desPath/macos_$version";

tempFilePath="$tempPath/$tempFileName"

rm -rf $tempPath
mkdir $tempPath

rm -rf $versionDir
mkdir $versionDir

cp -a $archiverPath $tempPath

cd $versionDir || exit
echo "cd $versionDir"
dmg $tempPath "fehviewer" $tempFileName