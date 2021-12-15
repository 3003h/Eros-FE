#!/bin/zsh

# shellcheck disable=SC2034
buildPath="build/app/outputs/apk/release/";
buildPathUniversal="build/app/outputs/apk/releaseUniversal/";
desPath="$HOME/Public/fehv";

#flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi
flutter build apk
cp -R $buildPath $buildPathUniversal
flutter build apk --split-per-abi