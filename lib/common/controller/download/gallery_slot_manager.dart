import 'dart:collection';

import 'package:eros_fe/common/controller/download/download_task_manager.dart'
    as dtm;
import 'package:eros_fe/index.dart';
import 'package:eros_fe/store/db/entity/gallery_task.dart';

typedef TaskStatus = dtm.TaskStatus;

/// 画廊槽位管理器
/// 控制同时下载的画廊数量，实现画廊的顺序执行和顺位机制
class GallerySlotManager {
  // 构造函数
  GallerySlotManager({
    required int maxConcurrentGalleries,
    required Function(GalleryTask) onStartGallery,
    required Future<GalleryTask?> Function(int, TaskStatus) onUpdateStatus,
  })  : _maxConcurrentGalleries = maxConcurrentGalleries,
        _onStartGallery = onStartGallery,
        _onUpdateStatus = onUpdateStatus;
  // 最大同时下载画廊数
  int _maxConcurrentGalleries;

  // 当前活动画廊映射 <gid, 状态>
  final Map<int, TaskStatus> _activeGalleries = {};

  // 等待队列（按添加顺序）
  final Queue<GalleryTask> _waitingQueue = Queue();

  // 回调函数 - 启动画廊任务
  final Function(GalleryTask) _onStartGallery;

  // 回调函数 - 更新任务状态
  final Future<GalleryTask?> Function(int, TaskStatus) _onUpdateStatus;

  // 工具方法：打印系统完整状态（用于调试）
  void dumpState(String checkpoint) {
    loggerSimple.d('======= 状态检查点: $checkpoint =======');
    loggerSimple.d('最大并发画廊数: $_maxConcurrentGalleries');
    loggerSimple.d('当前活动画廊数: ${_activeGalleries.length}');
    loggerSimple.d('等待队列长度: ${_waitingQueue.length}');
    loggerSimple
        .d('剩余可用槽位: ${_maxConcurrentGalleries - _activeGalleries.length}');

    // 活动画廊详情
    if (_activeGalleries.isEmpty) {
      loggerSimple.d('活动画廊: 无');
    } else {
      loggerSimple.d('活动画廊详情:');
      _activeGalleries.forEach((gid, status) {
        loggerSimple.d(' - 画廊 $gid: 状态=$status (${status.value})');
      });
    }

    // 等待队列详情
    if (_waitingQueue.isEmpty) {
      loggerSimple.d('等待队列: 空');
    } else {
      loggerSimple.d('等待队列详情:');
      int index = 0;
      for (final task in _waitingQueue) {
        final int statusValue = task.status ?? TaskStatus.undefined.value;
        final TaskStatus taskStatus = TaskStatus.from(statusValue);
        loggerSimple
            .d(' - [$index] gid=${task.gid}, 状态=$statusValue (${taskStatus})');
        index++;
      }
    }
    loggerSimple.d('===============================');
  }

  /// 添加画廊任务到管理器
  void addGalleryTask(GalleryTask task) {
    loggerSimple
        .d('添加画廊任务: gid=${task.gid}, 标题=${task.title}, 状态=${task.status}');
    dumpState('任务添加前');

    // 检查并清理同ID任务，避免重复
    _cleanupExistingTasks(task.gid);

    // 使用TaskStatus.from创建TaskStatus对象
    final int statusValue = task.status ?? TaskStatus.undefined.value;
    final TaskStatus taskStatus = TaskStatus.from(statusValue);
    loggerSimple.d(
        '任务状态解析: gid=${task.gid}, 原始status=${task.status}, 转换后=${taskStatus}');

    // 打印状态值比较
    loggerSimple.d(
        '状态比较 - paused: ${taskStatus == TaskStatus.paused}, complete: ${taskStatus == TaskStatus.complete}');
    loggerSimple.d(
        '状态值比较 - paused: ${statusValue == TaskStatus.paused.value}, complete: ${statusValue == TaskStatus.complete.value}');

    // 如果是暂停状态，不启动下载
    if (taskStatus == TaskStatus.paused) {
      loggerSimple.d('任务为暂停状态，不启动: gid=${task.gid}');
      return;
    }

    // 如果任务已完成，不启动下载
    if (taskStatus == TaskStatus.complete) {
      loggerSimple.d(
          '任务已完成，不启动: gid=${task.gid}, 状态值=${statusValue}, complete.value=${TaskStatus.complete.value}');
      return;
    }

    // 现在，任务应该是enqueued或running状态
    loggerSimple.d('任务状态检查通过，准备启动或入队: gid=${task.gid}, 状态=${taskStatus}');

    // 如果当前活动画廊数小于最大并发数，直接激活画廊
    if (_canStartNewGallery()) {
      loggerSimple.d(
          '可以直接启动新画廊: gid=${task.gid}, 当前活动数: ${_activeGalleries.length}/${_maxConcurrentGalleries}');
      _activateGallery(task);
    } else {
      // 否则添加到等待队列
      loggerSimple.d(
          '添加到等待队列: gid=${task.gid}, 当前活动数: ${_activeGalleries.length}/${_maxConcurrentGalleries}');
      _enqueueGallery(task);
    }

    dumpState('任务添加后');
  }

  /// 清理已存在的相同GID任务，避免重复
  void _cleanupExistingTasks(int gid) {
    // 检查活动画廊列表
    if (_activeGalleries.containsKey(gid)) {
      loggerSimple.d('发现GID=${gid}已在活动列表中，将其移除');
      _activeGalleries.remove(gid);
    }

    // 检查等待队列
    final existingTasksInQueue =
        _waitingQueue.where((task) => task.gid == gid).toList();
    if (existingTasksInQueue.isNotEmpty) {
      loggerSimple
          .d('发现GID=${gid}在等待队列中有${existingTasksInQueue.length}个任务，将其全部移除');
      _waitingQueue.removeWhere((task) => task.gid == gid);
    }

    if (_activeGalleries.containsKey(gid) || existingTasksInQueue.isNotEmpty) {
      loggerSimple.d('已清理GID=${gid}的旧任务');
    }
  }

  /// 处理画廊状态变化
  Future<void> onGalleryStatusChanged(int gid, TaskStatus newStatus) async {
    loggerSimple.d(
        '画廊 $gid 状态变化: $newStatus (${newStatus.value}), 当前活动画廊: ${_activeGalleries.keys.join(',')}');
    dumpState('状态变化前');

    // 使用TaskStatus.from检查数据一致性
    final int statusValue = newStatus.value;
    final TaskStatus statusFromValue = TaskStatus.from(statusValue);
    loggerSimple.d(
        '状态值一致性检查: 原始状态=$newStatus, 值=$statusValue, 从值重建状态=$statusFromValue, 是否相等=${newStatus == statusFromValue}');

    // 检查旧状态
    final oldStatus = _activeGalleries[gid];
    if (oldStatus != null) {
      loggerSimple.d('画廊 $gid 旧状态: $oldStatus (${oldStatus.value})');
    } else {
      loggerSimple.d('画廊 $gid 不在活动列表中');
    }

    // 验证当前队列状态
    _validateQueueState();

    // 如果画廊暂停、完成或失败，释放槽位
    if (newStatus == TaskStatus.paused ||
        newStatus == TaskStatus.complete ||
        newStatus == TaskStatus.failed) {
      loggerSimple.d('准备释放槽位: gid=$gid, 状态=$newStatus');

      // 释放槽位前记录队列状态
      loggerSimple.d(
          '释放前队列状态: 活动=${_activeGalleries.length}/${_maxConcurrentGalleries}, 等待=${_waitingQueue.length}');

      // 释放槽位
      _activeGalleries.remove(gid);
      loggerSimple.d(
          '画廊 $gid ${newStatus}，释放槽位, 当前活动画廊数: ${_activeGalleries.length}/${_maxConcurrentGalleries}');

      // 详细记录队列状态
      loggerSimple.d('等待队列状态: ${_waitingQueue.length}个任务等待中');
      if (_waitingQueue.isNotEmpty) {
        final firstTask = _waitingQueue.first;
        loggerSimple.d('队列首位任务: gid=${firstTask.gid}, 状态=${firstTask.status}');

        // 检查队列中第一个任务的状态与枚举值一致性
        final int firstTaskStatusValue =
            firstTask.status ?? TaskStatus.undefined.value;
        final TaskStatus firstTaskStatus =
            TaskStatus.from(firstTaskStatusValue);
        loggerSimple.d(
            '队列首位状态检查: 状态值=${firstTask.status}, 转换后=${firstTaskStatus}, enqueued=${firstTaskStatus == TaskStatus.enqueued}');

        loggerSimple.d(
            '队列所有任务: ${_waitingQueue.map((t) => '${t.gid}(${t.status})').join(', ')}');
      }

      loggerSimple.d(
          '调用_checkAndStartNext前 - 活动画廊: ${_activeGalleries.length}/${_maxConcurrentGalleries}, 队列长度: ${_waitingQueue.length}');

      // 验证是否可以启动新画廊
      final bool canStartNew = _canStartNewGallery();
      loggerSimple.d('理论上能否启动新任务: $canStartNew');

      // 检查并启动下一个任务
      await _checkAndStartNext();

      loggerSimple.d(
          '_checkAndStartNext执行后 - 活动画廊: ${_activeGalleries.keys.join(',')}, 剩余等待队列: ${_waitingQueue.length}');

      // 执行后验证
      _validateQueueState();
    } else if (newStatus == TaskStatus.running) {
      // 更新为运行状态
      final bool wasInactive = !_activeGalleries.containsKey(gid);
      _activeGalleries[gid] = newStatus;
      loggerSimple.d(
          '画廊 $gid 状态更新为运行中, 是否为新添加: $wasInactive, 当前活动画廊: ${_activeGalleries.keys.join(',')}');
    } else {
      // 其他状态变化
      loggerSimple.d('画廊 $gid 状态更新为 $newStatus, 不做特殊处理');
    }

    dumpState('状态变化后');
  }

  /// 设置最大并发画廊数
  Future<void> setMaxConcurrentGalleries(int value) async {
    int oldValue = _maxConcurrentGalleries;
    _maxConcurrentGalleries = value;

    loggerSimple.d('设置最大并发画廊数: $oldValue -> $value');

    // 如果增加了槽位，尝试启动更多任务
    if (value > oldValue) {
      loggerSimple.d('增加了槽位，尝试启动更多任务');
      await _checkAndStartNext();
    } else if (value < oldValue) {
      loggerSimple.d('减少了槽位，采用非抢占式策略，等待任务自然完成');
    }
    // 减少槽位时采用非抢占式，等待任务自然完成
  }

  /// 获取最大并发画廊数
  int get maxConcurrentGalleries => _maxConcurrentGalleries;

  /// 获取当前活动画廊数
  int get activeGalleriesCount => _activeGalleries.length;

  /// 获取等待队列长度
  int get waitingCount => _waitingQueue.length;

  /// 获取画廊是否在等待队列中
  bool isGalleryWaiting(int gid) {
    return _waitingQueue.any((task) => task.gid == gid);
  }

  /// 获取画廊是否在活动中
  bool isGalleryActive(int gid) {
    return _activeGalleries.containsKey(gid);
  }

  // 私有方法：检查是否可以启动新画廊
  bool _canStartNewGallery() {
    final bool canStart = _activeGalleries.length < _maxConcurrentGalleries;
    loggerSimple.d(
        '检查是否可启动新画廊: $canStart, 当前活动数: ${_activeGalleries.length}, 最大允许: $_maxConcurrentGalleries');

    // 如果无法启动，记录所有活动画廊的详细信息
    if (!canStart) {
      loggerSimple.d('当前活动画廊详细信息:');
      _activeGalleries.forEach((gid, status) {
        loggerSimple.d(' - 画廊 $gid: 状态=$status (${status.value})');
      });
    }

    return canStart;
  }

  // 强制验证队列操作
  void _validateQueueState() {
    loggerSimple.d(
        '验证队列状态 - 队列长度: ${_waitingQueue.length}, 活动画廊数: ${_activeGalleries.length}/${_maxConcurrentGalleries}');

    if (_waitingQueue.isNotEmpty &&
        _activeGalleries.length < _maxConcurrentGalleries) {
      loggerSimple.w('警告: 存在等待任务但活动画廊数未达上限!');
      loggerSimple.w('活动画廊: ${_activeGalleries.keys.join(', ')}');
      loggerSimple.w('等待任务: ${_waitingQueue.map((t) => t.gid).join(', ')}');
    }

    // 检查活动画廊中的状态
    bool hasNonRunning = false;
    _activeGalleries.forEach((gid, status) {
      if (status != TaskStatus.running) {
        hasNonRunning = true;
        loggerSimple.w('警告: 活动画廊 $gid 状态不是running而是 $status (${status.value})');
      }
    });

    // 检查队列中的任务状态
    if (_waitingQueue.isNotEmpty) {
      for (final task in _waitingQueue) {
        final int statusValue = task.status ?? TaskStatus.undefined.value;
        final TaskStatus status = TaskStatus.from(statusValue);
        if (status != TaskStatus.enqueued) {
          loggerSimple.w(
              '警告: 队列中的任务 ${task.gid} 状态不是enqueued而是 $status (${status.value})');
        }
      }
    }
  }

  // 私有方法：添加到等待队列并更新状态
  Future<void> _enqueueGallery(GalleryTask task) async {
    loggerSimple.d('准备将任务放入等待队列: gid=${task.gid}, 状态=${task.status}');

    // 添加到等待队列前记录状态
    loggerSimple.d(
        '添加前队列长度: ${_waitingQueue.length}, 活动画廊数: ${_activeGalleries.length}/${_maxConcurrentGalleries}');

    // 添加到等待队列
    _waitingQueue.add(task);

    // 更新状态为enqueued（如果当前不是）
    if (task.status != TaskStatus.enqueued.value) {
      loggerSimple.d('更新画廊 ${task.gid} 状态为enqueued, 当前状态: ${task.status}');
      await _onUpdateStatus(task.gid, TaskStatus.enqueued);
    }

    loggerSimple.d(
        '画廊 ${task.gid} 添加到等待队列，当前队列长度: ${_waitingQueue.length}, 队列内容: ${_waitingQueue.map((e) => '${e.gid}(${e.status})').join(',')}');

    // 检查并记录是否有问题
    if (_waitingQueue.isEmpty) {
      loggerSimple.e('警告：添加后队列仍然为空! gid=${task.gid}');
    }
  }

  // 私有方法：检查并启动下一个任务
  Future<void> _checkAndStartNext() async {
    loggerSimple.d(
        '开始检查并启动下一个任务, 当前队列长度: ${_waitingQueue.length}, 活动画廊数: ${_activeGalleries.length}/${_maxConcurrentGalleries}');
    dumpState('启动检查前');

    // 记录关键状态信息用于调试
    loggerSimple.d('*** 状态关键信息 ***');
    loggerSimple.d('最大并发画廊数: $_maxConcurrentGalleries');
    loggerSimple.d('当前活动画廊数: ${_activeGalleries.length}');
    loggerSimple.d('等待队列长度: ${_waitingQueue.length}');
    loggerSimple
        .d('是否有槽位可用: ${_activeGalleries.length < _maxConcurrentGalleries}');

    // 直接检查是否有异常：有槽位但队列为空
    if (_activeGalleries.length < _maxConcurrentGalleries &&
        _waitingQueue.isEmpty) {
      loggerSimple.d('有空闲槽位但等待队列为空，无需启动新任务');
      return;
    }

    // 直接检查是否有异常：活动数已达上限
    if (_activeGalleries.length >= _maxConcurrentGalleries) {
      loggerSimple.d('活动画廊数已达上限，无法启动新任务');
      loggerSimple.d('活动画廊: ${_activeGalleries.keys.join(', ')}');
      return;
    }

    // 调试输出所有队列内容
    if (_waitingQueue.isNotEmpty) {
      loggerSimple.d(
          '等待队列内容: ${_waitingQueue.map((t) => '${t.gid}(${t.status})').join(', ')}');

      // 检查所有队列中任务的状态
      for (final task in _waitingQueue) {
        final int taskStatusValue = task.status ?? TaskStatus.undefined.value;
        final TaskStatus taskStatus = TaskStatus.from(taskStatusValue);
        loggerSimple.d(
            '队列任务状态检查: gid=${task.gid}, 状态值=${task.status}, 转换后=${taskStatus}, enqueued=${taskStatus == TaskStatus.enqueued}');

        // 增加一个额外检查：如果队列中的任务状态不是enqueued，记录警告
        if (taskStatus != TaskStatus.enqueued) {
          loggerSimple.w(
              '警告: 队列中的任务状态不是enqueued，这可能导致任务不被启动! gid=${task.gid}, 状态=${taskStatus}');
        }
      }
    } else {
      loggerSimple.d('等待队列为空，无法启动新任务');
      return;
    }

    // 调试输出所有活动画廊
    if (_activeGalleries.isNotEmpty) {
      loggerSimple.d(
          '活动画廊内容: ${_activeGalleries.entries.map((e) => '${e.key}(${e.value})').join(', ')}');
    }

    final bool canStart = _canStartNewGallery();
    loggerSimple.d('能否启动新画廊: $canStart');

    if (!canStart) {
      loggerSimple.d(
          '无法启动新画廊，当前活动数已达上限 ${_activeGalleries.length}/${_maxConcurrentGalleries}');
      return;
    }

    loggerSimple.d(
        '准备启动新任务, 当前空闲槽位: ${_maxConcurrentGalleries - _activeGalleries.length}');

    int startedCount = 0;
    int processingCount = 0;
    int errorCount = 0;

    // 保存开始前状态用于对比
    final int activeCountBefore = _activeGalleries.length;
    final int waitingCountBefore = _waitingQueue.length;

    // 设置前的队列快照，用于后续比较
    final List<int> queueGidsBeforeStart =
        _waitingQueue.map((t) => t.gid).toList();
    loggerSimple.d('启动前队列任务GID: $queueGidsBeforeStart');

    while (_canStartNewGallery() && _waitingQueue.isNotEmpty) {
      processingCount++;

      try {
        final nextTask = _waitingQueue.removeFirst();
        loggerSimple.d(
            '从队列中取出任务: gid=${nextTask.gid}, title=${nextTask.title}, 状态=${nextTask.status}');

        // 使用TaskStatus.from检查任务状态
        final int nextTaskStatusValue =
            nextTask.status ?? TaskStatus.undefined.value;
        final TaskStatus taskStatus = TaskStatus.from(nextTaskStatusValue);
        loggerSimple.d(
            '待启动任务状态检查: gid=${nextTask.gid}, 状态值=${nextTask.status}, 转换后=${taskStatus}, enqueued=${taskStatus == TaskStatus.enqueued}');

        // 关键：检查任务状态是否是enqueued，如果不是，它可能不会被启动
        if (taskStatus != TaskStatus.enqueued) {
          loggerSimple.w(
              '警告: 待启动任务状态不是enqueued，这可能导致任务不被正确启动! gid=${nextTask.gid}, 状态=${taskStatus}');
        }

        // 检查这个任务是否已经被激活或被添加到其他状态
        if (_activeGalleries.containsKey(nextTask.gid)) {
          loggerSimple.w(
              '警告：任务 ${nextTask.gid} 已经在活动画廊中，状态为 ${_activeGalleries[nextTask.gid]}');
          continue;
        }

        _activateGallery(nextTask);
        startedCount++;
        loggerSimple.d('成功激活任务 gid=${nextTask.gid}');
      } catch (e) {
        errorCount++;
        loggerSimple.e('启动任务出错: $e');
      }
    }

    loggerSimple.d(
        '_checkAndStartNext完成, 启动了 $startedCount 个新任务, 处理了 $processingCount 个任务, 错误 $errorCount 个');
    loggerSimple.d(
        '剩余队列: ${_waitingQueue.length}个, 当前活动: ${_activeGalleries.length}/${_maxConcurrentGalleries}');

    // 检查是否有异常情况：有空闲槽位，有等待任务，但没有启动任何任务
    if (startedCount == 0 &&
        _canStartNewGallery() &&
        _waitingQueue.isNotEmpty) {
      logger.e('严重错误: 有空闲槽位和等待任务，但没有启动任何新任务!');
      logger.e(
          '空闲槽位: ${_maxConcurrentGalleries - _activeGalleries.length}, 等待任务: ${_waitingQueue.length}');

      // 详细检查等待队列中的第一个任务
      if (_waitingQueue.isNotEmpty) {
        final firstTask = _waitingQueue.first;
        final int statusValue = firstTask.status ?? TaskStatus.undefined.value;
        loggerSimple.e('队列首位任务: gid=${firstTask.gid}, 状态值=$statusValue');
        loggerSimple.e('首位任务详情: ${firstTask.toString()}');

        // 检查此任务状态是否是enqueued的
        final TaskStatus firstTaskStatus = TaskStatus.from(statusValue);
        loggerSimple.e('队列首位任务状态对象: $firstTaskStatus');
        loggerSimple
            .e('是否是enqueued状态: ${firstTaskStatus == TaskStatus.enqueued}');
        logger.e(
            '是否是任何其他状态: paused=${firstTaskStatus == TaskStatus.paused}, running=${firstTaskStatus == TaskStatus.running}, complete=${firstTaskStatus == TaskStatus.complete}');
      }
    }

    // 检查状态变化
    final int activeDiff = _activeGalleries.length - activeCountBefore;
    final int waitingDiff = waitingCountBefore - _waitingQueue.length;

    if (activeDiff != startedCount || waitingDiff != startedCount) {
      logger.e(
          '状态不一致: 启动任务数=$startedCount, 活动画廊增加=$activeDiff, 等待队列减少=$waitingDiff');
    }

    // 对比队列内容变化
    final List<int> queueGidsAfterStart =
        _waitingQueue.map((t) => t.gid).toList();
    loggerSimple.d('启动后队列任务GID: $queueGidsAfterStart');

    dumpState('启动检查后');
  }

  // 私有方法：激活画廊
  void _activateGallery(GalleryTask task) {
    loggerSimple
        .d('正在激活画廊: gid=${task.gid}, title=${task.title}, 当前状态=${task.status}');

    // 激活前记录状态
    loggerSimple.d(
        '激活前活动画廊: ${_activeGalleries.length}/${_maxConcurrentGalleries}, keys=[${_activeGalleries.keys.join(', ')}]');

    // 分配槽位给画廊
    _activeGalleries[task.gid] = TaskStatus.running;

    // 激活后记录状态
    loggerSimple.d(
        '激活后活动画廊: ${_activeGalleries.length}/${_maxConcurrentGalleries}, keys=[${_activeGalleries.keys.join(', ')}]');

    // 执行回调
    loggerSimple.d('调用启动回调前: gid=${task.gid}');
    _onStartGallery(task);
    logger.d(
        '调用启动回调后: gid=${task.gid}, 当前活动画廊数: ${_activeGalleries.length}/${_maxConcurrentGalleries}');

    // 检查并记录是否有问题
    if (!_activeGalleries.containsKey(task.gid)) {
      logger.e('警告：激活回调后画廊不在活动列表中! gid=${task.gid}');
    }
  }

  /// 重置槽位管理器的状态
  /// 清空活动画廊列表和等待队列
  void resetState() {
    loggerSimple.d('重置槽位管理器状态');

    // 记录重置前状态
    final activeGalleriesCopy = Map<int, TaskStatus>.from(_activeGalleries);
    final waitingQueueSize = _waitingQueue.length;

    // 清空活动画廊列表
    _activeGalleries.clear();

    // 清空等待队列
    _waitingQueue.clear();

    loggerSimple.d(
        '槽位状态已重置, 原活动画廊: ${activeGalleriesCopy.keys.join(',')}，原等待队列长度: $waitingQueueSize');

    dumpState('重置后');
  }
}
