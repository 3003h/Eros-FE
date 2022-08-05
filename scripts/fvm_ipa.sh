source ./para.sh
cd $scripts_path/../ios && pod update && pod install --repo-update && cd $scripts_path
fvm flutter pub upgrade
fvm flutter build ipa --release && sh reid.sh && sh zip.sh $version && sh dsym.sh
