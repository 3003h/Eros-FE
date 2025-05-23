import 'dart:convert';
import 'dart:io';

import 'package:eros_fe/index.dart';
import 'package:eros_fe/store/db/entity/gallery_image_task.dart';
import 'package:eros_fe/store/db/entity/gallery_task.dart';
import 'package:eros_fe/utils/saf_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:saf/saf.dart';
import 'package:shared_storage/shared_storage.dart' as ss;

class StorageAdapter {
  /// 写入元数据文件，用于恢复任务
  Future<void> writeTaskInfoFile(GalleryTask? galleryTask) async {
    if (galleryTask == null) {
      return;
    }

    final imageTaskList =
        (await isarHelper.findImageTaskAllByGidIsolate(galleryTask.gid))
            .map((e) => e.copyWith(imageUrl: ''))
            .toList();

    String jsonImageTaskList = await compute(jsonEncode, imageTaskList);
    String jsonGalleryTask =
        await compute(jsonEncode, galleryTask.copyWith(dirPath: ''));
    logger.t('writeTaskInfoFile:\n$jsonGalleryTask\n$jsonImageTaskList');

    final dirPath = galleryTask.realDirPath;
    if (dirPath == null || dirPath.isEmpty) {
      return;
    }

    final info = '$jsonGalleryTask\n$jsonImageTaskList';
    final infoBytes = Uint8List.fromList(utf8.encode(info));

    if (dirPath.isContentUri) {
      // SAF
      final infoDomFile = await ss.findFile(Uri.parse(dirPath), '.info');
      if (infoDomFile?.name != null) {
        await ss.delete(Uri.parse('$dirPath%2F.info'));
      }
      ss.createFileAsBytes(
        Uri.parse(dirPath),
        mimeType: '',
        displayName: '.info',
        bytes: infoBytes,
      );
    } else {
      final File infoFile = File(path.join(dirPath, '.info'));
      infoFile.writeAsString(info);
    }
  }

  /// 从.info文件加载任务信息
  Future<void> loadInfoFile(File infoFile, String dirPath) async {
    logger.d('infoFile: ${infoFile.path}');
    final info = infoFile.readAsStringSync();
    final infoList =
        info.split('\n').where((element) => element.trim().isNotEmpty).toList();
    if (infoList.length < 2) {
      return;
    }

    final taskJsonString = infoList[0];
    final imageJsonString = infoList[1];

    try {
      final galleryTask = GalleryTask.fromJson(
              jsonDecode(taskJsonString) as Map<String, dynamic>)
          .copyWith(dirPath: dirPath);
      final galleryImageTaskList = <GalleryImageTask>[];

      final imageList = jsonDecode(imageJsonString) as List<dynamic>;
      for (final img in imageList) {
        final galleryImageTask =
            GalleryImageTask.fromJson(img as Map<String, dynamic>);
        galleryImageTaskList.add(galleryImageTask);
      }

      await isarHelper.putAllImageTaskIsolate(galleryImageTaskList);
      await isarHelper.putGalleryTaskIsolate(galleryTask);
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
  }

  /// 使用SAF恢复下载任务
  Future<void> restoreGalleryTasksWithSAF(
      String currentDownloadPath, Function? loadInfoFileCallback) async {
    logger.d('restoreGalleryTasksWithSAF $currentDownloadPath');
    final uri = Uri.parse(currentDownloadPath);
    final pathSegments = uri.pathSegments;
    logger.d('pathSegments: \n${pathSegments.join('\n')}');

    if (!pathSegments.last.startsWith('primary:')) {
      throw Exception('safCacheSingle: $uri not primary');
    }

    final safTreePath = pathSegments.last.replaceFirst('primary:', '');
    final saf = Saf(safTreePath);

    // 申请Tree权限
    bool? isGranted = await saf.getDirectoryPermission(isDynamic: true);
    if (isGranted == null || !isGranted) {
      await Saf.releasePersistedPermissions();
      await saf.getDirectoryPermission(isDynamic: false);
    }

    // await saf.cache();

    final filePaths = await saf.getFilesPath() ?? [];
    logger.d('filePaths: \n${filePaths.join('\n')}');

    for (final fiPath in filePaths) {
      final directoryName = path.basename(fiPath);
      logger.d('directoryName: $directoryName');

      if (directoryName.startsWith('.')) {
        continue;
      }

      final subSafPath = path.join(safTreePath, directoryName);
      final subSaf = Saf(subSafPath);

      final infoFilePath = path.join(fiPath, '.info');
      final cachePath = await subSaf.singleCache(
        filePath: infoFilePath,
        treePath: safTreePath,
      );
      logger.d('cachePath: $cachePath');
      final infoFile = File(cachePath ?? '');
      if (infoFile.existsSync() && loadInfoFileCallback != null) {
        await Function.apply(loadInfoFileCallback, [
          infoFile,
          safMakeUri(path: fiPath, tree: safTreePath).toString(),
        ]);
      }
      subSaf.clearCache();
    }
    await saf.clearCache();
  }

  /// 从文件系统恢复下载任务
  Future<void> restoreGalleryTasksWithPath(
      String currentDownloadPath, Function? loadInfoFileCallback) async {
    if (loadInfoFileCallback == null) {
      return;
    }

    final directory = Directory(GetPlatform.isIOS
        ? path.join(Global.appDocPath, currentDownloadPath)
        : currentDownloadPath);

    await for (final fs in directory.list()) {
      final infoFile = File(path.join(fs.path, '.info'));
      if (fs is Directory && infoFile.existsSync()) {
        await Function.apply(loadInfoFileCallback, [infoFile, fs.path]);
      }
    }
  }
}
