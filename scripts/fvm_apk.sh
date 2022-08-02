#!/bin/zsh
source ./para.sh

echo $apk_build_path
echo $apk_build_path_universal

fvm flutter pub upgrade
#flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi
fvm flutter build apk
cp -R $apk_build_path $apk_build_path_universal
fvm flutter build apk --split-per-abi
cp $apk_build_path_universal/*.apk $apk_build_path/*