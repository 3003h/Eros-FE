export scripts_path=`pwd`
export release_bundle_identifier='cn.honjow.fehv'
export dev_bundle_identifier='dev2.cn.honjow.fehv'

export pub_output_path="$HOME/Public/fehv";

export macos_archiver_path="${scripts_path}/../build/macos/Build/Products/Release/fehviewer.app";

export ios_archiver_path="${scripts_path}/../build/ios/archive/fehviewer.xcarchive/Products/Applications/FEhViewer.app"

export ios_nosign_path="${scripts_path}/../build/ios/iphoneos/Eros-FE.app"

export ipa_plist_path="${ios_archiver_path}/Info.plist"

export apk_build_path="${scripts_path}/../build/app/outputs/apk/release/";

export apk_build_path_universal="${scripts_path}/../build/app/outputs/apk/releaseUniversal/";

export version=`perl version.pl`

