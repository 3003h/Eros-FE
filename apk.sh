#!/bin/zsh

# shellcheck disable=SC2034
buildPath="build/app/outputs/apk/release/";
desPath="$HOME/Public/fehv";

flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi
