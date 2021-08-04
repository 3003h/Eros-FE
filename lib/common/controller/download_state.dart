import 'dart:async';

import 'package:dio/dio.dart';
import 'package:executor/executor.dart';
import 'package:fehviewer/component/quene_task/quene_task.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:get/get.dart';

const int kRetryThreshold = 5;

class DownloadState {
  DownloadState();
  final RxMap<int, GalleryTask> galleryTaskMap = <int, GalleryTask>{}.obs;

  List<GalleryTask> get galleryTasks => galleryTaskMap.values.toList();
  final downloadSpeeds = <int, String>{};

  late Executor executor;

  QueueTask queueTask = QueueTask();
  final Map<int, TaskCancelToken> taskCanceltokens = {};

  final downloadMap = <int, List<GalleryImage>>{};
  final cancelTokenMap = <int, CancelToken>{};

  final Map<int, Timer?> chkTimers = {};
  final Map<int, int> preComplet = {};
  final Map<int, int> curComplet = {};

  final Map<String, int> downloadCounts = {};
  final Map<int, List<int>> lastCounts = {};

  final Map<int, int> noSpeed = {};
}
