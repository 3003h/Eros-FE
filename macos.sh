cd macos && pod update && pod install && cd ..
flutter build macos --release && perl dmg.pl