source ./para.sh
cd ${scripts_path}/../macos && pod update && pod install && cd $scripts_path
flutter build macos --release && sh dmg.sh $version