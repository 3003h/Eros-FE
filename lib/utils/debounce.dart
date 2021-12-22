import 'dart:async';

final Map<String, Timer> _debounceTimers = {};

/// 函数防抖
///
/// [func]: 要执行的方法
/// [durationTime]: 要迟延的时间
void vDebounce(
  Function? func, {
  Duration duration = const Duration(milliseconds: 300),
}) {
  String key = func.hashCode.toString();

  if (duration == Duration.zero) {
    _debounceTimers[key]?.cancel();
    _debounceTimers.remove(key);
    // logger.d('${func.hashCode} call');
    func?.call();
  } else {
    // logger.d('${func.hashCode} cancel');
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(duration, () {
      _debounceTimers[key]?.cancel();
      _debounceTimers.remove(key);
      func?.call();
    });
  }
}
