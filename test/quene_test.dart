import 'dart:async';

import 'package:fehviewer/component/quene_task/quene_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quene task', () async {
    QueueTask _queueTask = QueueTask();

    TaskCancelToken cancelToken = TaskCancelToken();
    TaskCancelToken cancelToken2 = TaskCancelToken();

    _queueTask.add(_doTask, taskName: 'task1');
    _queueTask.add(_doTask, taskName: 'task2');
    _queueTask.add(_doTask, taskName: 'task3');
    _queueTask.add(
      _doTask,
      taskCancelToken: cancelToken,
    );
    _queueTask.add(
      _doTask,
      taskName: 'c1',
      taskCancelToken: cancelToken,
    );
    _queueTask.add(
      _doTask,
      taskName: 'c2',
      taskCancelToken: cancelToken2,
    );

    cancelToken.cancel();

    await Future.delayed(Duration(seconds: 15));
  });
}

Future _doTask({String? name}) async {
  await Future.delayed(Duration(seconds: 2));
  print('触发执行 $name');
  return;
}
