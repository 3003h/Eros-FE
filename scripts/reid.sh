#!/bin/sh
# shellcheck disable=SC2034

plist_key="CFBundleIdentifier"

/usr/libexec/PlistBuddy -c "Set :${plist_key} ${release_bundle_identifier}" ${ipa_plist_path}