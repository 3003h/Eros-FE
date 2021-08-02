import 'dart:async';

import 'package:dio/dio.dart';
import 'package:executor/executor.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:get/get.dart';

const int kRetryThreshold = 20;

class DownloadState {
  DownloadState();
  final RxMap<int, GalleryTask> galleryTaskMap = <int, GalleryTask>{}.obs;

  List<GalleryTask> get galleryTasks => galleryTaskMap.values.toList();
  final RxMap<int, String> downloadSpeeds = <int, String>{}.obs;

  late Executor executor;

  final downloadMap = <String, List<GalleryImage>>{};
  final cancelTokenMap = <String, CancelToken>{};

  final Map<int, Timer?> chkTimers = {};
  final Map<int, int> preComplet = {};
  final Map<int, int> curComplet = {};

  final Map<String, int> downloadCounts = {};
  final Map<int, List<int>> lastCounts = {};

  final Map<int, int> noSpeed = {};
}
