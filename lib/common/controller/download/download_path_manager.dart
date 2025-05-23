import 'dart:io';

import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/utils/saf_helper.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_storage/shared_storage.dart' as ss;

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? await getAndroidDefaultDownloadPath()
    : (GetPlatform.isWindows
        ? path.join((await getDownloadsDirectory())!.path, 'fehviewer')
        : path.join(Global.appDocPath, 'Download'));

Future<String> getAndroidDefaultDownloadPath() async {
  final downloadPath = path.join(Global.extStorePath, 'Download');

  final dir = Directory(downloadPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return downloadPath;
}

class DownloadPathManager {
  DownloadPathManager(this.ehSettingService);
  final EhSettingService ehSettingService;

  Future<String> getGalleryDownloadPath({String dirName = ''}) async {
    late final String saveDirPath;
    late final Directory savedDir;

    if (ehSettingService.downloadLocatino.isNotEmpty) {
      // 自定义路径
      logger.t('自定义下载路径');
      saveDirPath = path.join(ehSettingService.downloadLocatino, dirName);
      savedDir = Directory(saveDirPath);
    } else if (!GetPlatform.isIOS) {
      saveDirPath = path.join(await defDownloadPath, dirName);
      savedDir = Directory(saveDirPath);
      logger.d('无自定义下载路径, 使用默认路径 $saveDirPath');
    } else {
      logger.d('iOS');
      // iOS 记录的为相对路径 不记录doc的实际路径
      saveDirPath = path.join('Download', dirName);
      savedDir = Directory(path.join(Global.appDocPath, saveDirPath));
    }

    if (dirName.isEmpty) {
      return saveDirPath;
    }

    if (saveDirPath.isContentUri) {
      await checkSafPath(saveDownloadPath: true);

      final galleryDirUrl = '${ehSettingService.downloadLocatino}%2F$dirName';
      final uri = Uri.parse(galleryDirUrl);
      final exists = await ss.exists(uri) ?? false;

      if (exists) {
        return galleryDirUrl;
      }

      logger.d('galleryDirUrl $galleryDirUrl');
      final parentUri = Uri.parse(ehSettingService.downloadLocatino);
      try {
        final result = await ss.createDirectory(parentUri, dirName);
        if (result != null) {
          return result.uri.toString();
        } else {
          showToast('createDirectory failed');
          throw Exception('createDirectory failed');
        }
      } catch (e, s) {
        logger.e('create Directory failed', error: e, stackTrace: s);
        showToast('create Directory failed, $galleryDirUrl');
        rethrow;
      }
    } else {
      // 判断下载路径是否存在
      final bool hasExisted = savedDir.existsSync();
      // 不存在就新建路径
      if (!hasExisted) {
        savedDir.createSync(recursive: true);
      }
      return saveDirPath;
    }
  }

  Future<void> updateCustomDownloadPath() async {
    final customDownloadPath = ehSettingService.downloadLocatino;
    logger.d('customDownloadPath:$customDownloadPath');
    if (!GetPlatform.isAndroid ||
        customDownloadPath.isEmpty ||
        customDownloadPath.isContentUri) {
      return;
    }

    final uri = safMakeUri(path: customDownloadPath, isTreeUri: true);
    ehSettingService.downloadLocatino = uri.toString();
    // 这里需要提供一个回调或引用以恢复任务
    // restoreGalleryTasks();

    logger.d('updateCustomDownloadPath $uri');
  }

  Future<void> allowMediaScan(bool allow) async {
    final downloadPath = await getGalleryDownloadPath();

    if (Platform.isAndroid) {
      final uriList = await ss.persistedUriPermissions();
      logger.d('uriList:\n${uriList?.map((e) => e.toString()).join('\n')}');
      if (uriList == null || uriList.isEmpty) {
        logger.e('allowMediaScan uriList is null');
      }
    }

    final pathList = <String>[];

    logger.t('allowMediaScan $pathList');

    pathList.add(downloadPath);

    for (final dirPath in pathList) {
      logger.t('media path: $dirPath');
      if (dirPath.isContentUri) {
        // SAF 方式
        if (allow) {
          final file = await ss.findFile(Uri.parse(dirPath), '.nomedia');
          if (file != null) {
            logger.d('delete: ${file.uri}');
            await ss.delete(file.uri);
          }
        } else {
          final file = await ss.findFile(Uri.parse(dirPath), '.nomedia');
          if (file == null) {
            final result = await ss.createFileAsString(
              Uri.parse(dirPath),
              mimeType: '',
              displayName: '.nomedia',
              content: '',
            );
            logger.d('create nomedia result: ${result?.uri}');
          }
        }
      } else {
        // 文件路径方式
        final File noMediaFile = File(path.join(dirPath, '.nomedia'));

        if (allow && await noMediaFile.exists()) {
          logger.d('delete $noMediaFile');
          noMediaFile.delete(recursive: true);
        } else if (!allow && !await noMediaFile.exists()) {
          logger.d('create $noMediaFile');
          noMediaFile.create(recursive: true);
        }
      }
    }
  }

  Future<void> checkSafPath(
      {String? uri, bool saveDownloadPath = false}) async {
    if (Platform.isAndroid) {
      final String checkUri = uri ?? ehSettingService.downloadLocatino;
      Future<void> openDocumentTree() async {
        // final uri =
        //     await ss.openDocumentTree(initialUri: Uri.tryParse(checkUri));

        final uri =
            await showSAFPermissionRequiredDialog(uri: Uri.parse(checkUri));

        logger.d('uri $uri');

        if (uri != null && saveDownloadPath) {
          ehSettingService.downloadLocatino = uri.toString();
        }
      }

      final uriList = await ss.persistedUriPermissions();
      if (uriList == null || uriList.isEmpty) {
        logger.e('persisted uriList is null');
        await openDocumentTree();
      } else {
        if (!uriList.any((element) => element.uri.toString() == checkUri)) {
          logger.e('uriList not contains $checkUri');
          await openDocumentTree();
        }
      }

      // await showSAFPermissionRequiredDialog(uri: Uri.parse(checkUri));

      // await safCreateDirectory(Uri.parse(checkUri));
    }
  }
}
