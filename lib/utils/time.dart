import 'logger.dart';

final Time time = Time();

class Time {
  int lastTime;

  void showTime(String tag) {
    final int nowTime = DateTime.now().millisecondsSinceEpoch;
    if (lastTime != null) {
      logger.i('showTime $tag ${nowTime - lastTime}');
    }
    lastTime = nowTime;
  }
}
