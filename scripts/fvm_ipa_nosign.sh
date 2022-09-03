source ./para.sh
cd $scripts_path/../ios && pod update && pod install --repo-update && cd $scripts_path
fvm flutter pub upgrade
fvm flutter build ios --release --no-codesign && sh thin-payload.sh ${ios_nosign_path}
