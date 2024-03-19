import 'dart:async';
import 'dart:collection';

import 'package:eros_fe/utils/logger.dart';

typedef WorkTask = Function({String? name});

class QueueTask {
  QueueTask({this.maxThread = 1});
  final int maxThread;

  ///当前任务队列
  final Queue<_TaskInfo> _queue = Queue();

  ///是否工作中
  int _taskCount = 0;

  void add(
    WorkTask workTask, {
    TaskCancelToken? taskCancelToken,
    String? taskName,
  }) {
    _queue.add(_TaskInfo(
      workTask,
      taskName: taskName,
      taskCancelToken: taskCancelToken,
    ));
    _exec();
  }

  void cancel(String taskName) {}

  Future<void> _exec() async {
    if (_taskCount >= maxThread) {
      return;
    }
    if (_queue.isEmpty) {
      return;
    }

    for (int i = 0; i < maxThread; i++) {
      if (_queue.isEmpty) {
        continue;
      }

      _TaskInfo _taskInfo = _queue.removeFirst();
      if (_taskInfo.taskCancelToken != null &&
          _taskInfo.taskCancelToken!.isCancelled) {
        logger.d('task ${_taskInfo.taskName} isCancelled');
        continue;
      }

      _taskCount += 1;
      await _taskInfo.workTask.call(name: _taskInfo.taskName);
      _taskCount -= 1;
    }
    _exec();
  }
}

class _TaskInfo {
  _TaskInfo(this.workTask, {this.taskName, this.taskCancelToken});
  String? taskName;
  WorkTask workTask;
  final TaskCancelToken? taskCancelToken;
}

class TaskCancelToken {
  TaskCancelToken() {
    _completer = Completer();
  }
  late Completer _completer;

  bool isCancelled = false;

  void cancel() {
    isCancelled = true;
    _completer.complete();
  }
}
