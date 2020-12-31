import 'dart:io';

import 'package:flutter_vibrate/flutter_vibrate.dart';

class VibrateUtil {
  static void light() {
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.light);
    }
  }

  static void heavy() {
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.heavy);
    }
  }

  static void success() {
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.success);
    }
  }

  static void error() {
    if (Platform.isIOS) {
      Vibrate.feedback(FeedbackType.error);
    }
  }
}
