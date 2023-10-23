source ./para.sh
cd $scripts_path/../ios && pod update && pod install && cd $scripts_path
flutter build ipa --release && sh reid.sh && sh zip.sh $version
