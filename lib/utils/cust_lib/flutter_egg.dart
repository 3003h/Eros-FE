library flutter_egg;

import 'package:flutter/material.dart';

typedef OnTapCallBack = void Function(int tapNum, int neededNum);

/// 隐藏彩蛋,多次点击后触发
class Egg extends StatefulWidget {
  Egg({
    this.child,
    this.neededNum = 5,
    this.interval = const Duration(seconds: 1),
    this.onTrigger,
    this.onTap,
  });

  final Widget? child;

  /// 总共需要点击的次数
  final int neededNum;

  /// 两次点击的间隔
  final Duration interval;
  final OnTapCallBack? onTrigger;
  final OnTapCallBack? onTap;

  @override
  _EggState createState() => _EggState();
}

class _EggState extends State<Egg> {
  List<DateTime> tapTimeList = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // behavior: HitTestBehavior.opaque,
      onTap: handleOnTap,
      child: AbsorbPointer(child: widget.child),
    );
  }

  void handleOnTap() {
    DateTime? lastPressedAt = tapTimeList.length > 0 ? tapTimeList.last : null;
    final DateTime now = DateTime.now();

    // 不超过点击间隔,tapTimeList 添加当前点击时刻
    if (lastPressedAt != null &&
        (now.difference(lastPressedAt) < widget.interval)) {
      tapTimeList.add(now);
//      $warn('再按 ${widget.neededNum - tapTimeList.length}次');

      // 到达条件,触发隐藏功能
      if (tapTimeList.length >= widget.neededNum) {
        if (widget.onTrigger != null) {
          widget.onTrigger!(tapTimeList.length, widget.neededNum);
        }
        // 清空记录点击列表
        tapTimeList.clear();
      }
    } else {
      // 两次点击间隔超过 时长限制，重新计时
      tapTimeList.clear();
      tapTimeList.add(now);
    }

    // 每次都触发的 tap 事件
    if (widget.onTap != null) {
      widget.onTap!(tapTimeList.length, widget.neededNum);
    }
  }
}
