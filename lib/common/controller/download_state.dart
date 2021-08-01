import 'dart:async';

import 'package:dio/dio.dart';
import 'package:executor/executor.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:get/get.dart';

class DownloadState {
  DownloadState();
  // final RxMap<String, GalleryTask> galleryTaskMap = <String, GalleryTask>{}.obs;

  final RxList<GalleryTask> galleryTaskList = <GalleryTask>[].obs;
  final RxMap<int, String> downloadSpeeds = <int, String>{}.obs;

  late Executor executor;

  final downloadMap = <String, List<GalleryImage>>{};
  final cancelTokenMap = <String, CancelToken>{};

  final Map<int, Timer?> chkTimers = {};
  final Map<int, int> preComplet = {};
  final Map<int, int> curComplet = {};

  final Map<String, int> downloadCounts = {};
  final Map<int, int> lastCounts = {};

  final retryThreshold = 2;
  final Map<int, int> noSpeed = {};
}
