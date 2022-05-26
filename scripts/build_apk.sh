#!/bin/zsh
source ./para.sh

echo $apk_build_path
echo $apk_build_path_universal


#flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi
flutter build apk -t lib/main.firebase.dart
cp -R $apk_build_path $apk_build_path_universal
flutter build apk --split-per-abi -t lib/main.firebase.dart
cp $apk_build_path_universal/*.apk $apk_build_path/*