source ./para.sh
cd $scripts_path/../ios && pod update && pod install && cd $scripts_path
flutter build ipa --release -t lib/main.firebase.dart && sh reid.sh && sh zip.sh $version && sh dsym.sh
