import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eros_fe/component/quene_task/quene_task.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/store/db/entity/gallery_task.dart';
import 'package:executor/executor.dart';
import 'package:get/get.dart';

/// 轮询周期间隔 单位秒
const int kPeriodSeconds = 1;

/// 速度统计周期
const int kMaxCount = 4;

/// 速度统计周期
const int kCheckMaxCount = 10;

// 无速度多少个周期后重试
const int kRetryThresholdTime = 10;

// 达到此次数后才换源下载
const int kMaxReDownloadRetries = 3;

class DownloadState {
  DownloadState();
  final RxMap<int, GalleryTask> galleryTaskMap = <int, GalleryTask>{}.obs;

  List<GalleryTask> get galleryTasks => galleryTaskMap.values.toList()
    ..sort((b, a) => (a.addTime ?? 0).compareTo(b.addTime ?? 0));

  final downloadSpeeds = <int, String>{};

  final errInfoMap = <int, String>{};

  late Executor executor;

  QueueTask queueTask = QueueTask();
  final Map<int, TaskCancelToken> taskCancelTokens = {};

  final Map<int, List<GalleryImage>> downloadMap = <int, List<GalleryImage>>{};
  final Map<int, CancelToken> cancelTokenMap = <int, CancelToken>{};
  final showKeyMap = <int, String>{};
  final showKeyCompleteMap = <int, Completer>{};

  final Map<int, Timer?> chkTimers = {};
  final Map<int, int> preComplete = {};
  final Map<int, int> curComplete = {};

  final Map<String, int> downloadCounts = {};
  final Map<int, List<int>> lastCounts = {};

  final Map<int, int> noSpeed = {};

  // 重试计数器：key: "gid_ser", value: 重试次数
  final Map<String, int> reDownloadCounts = {};

  // 画廊任务额外信息 - 新增
  final Map<int, Map<String, dynamic>> galleryTaskExtraInfo = {};
}
