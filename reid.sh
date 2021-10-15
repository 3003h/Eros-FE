#!/bin/sh
# shellcheck disable=SC2034
releaseBundleIdentifier='cn.honjow.fehv'
devBundleIdentifier='dev.cn.honjow.fehv'

archiverPath="build/ios/archive/fehviewer.xcarchive/Products/Applications/FEhViewer.app"
plistPath="$archiverPath/Info.plist"

plistKey="CFBundleIdentifier"

/usr/libexec/PlistBuddy -c "Set :$plistKey $releaseBundleIdentifier" $plistPath