import 'dart:io';

import 'package:collection/collection.dart';
import 'package:eros_fe/index.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:saf/saf.dart';
import 'package:shared_storage/shared_storage.dart' as ss;

const kSafCacheDir = 'saf_cache';

const kDocumentFileColumns = <ss.DocumentFileColumn>[
  ss.DocumentFileColumn.displayName,
  ss.DocumentFileColumn.size,
  ss.DocumentFileColumn.lastModified,
  ss.DocumentFileColumn.id,
  ss.DocumentFileColumn.mimeType,
];

Future<String> safCacheSingle_Old(Uri cacheUri,
    {bool overwrite = false}) async {
  logger.d('safCacheSingle: $cacheUri');

  // await safTest(cacheUri);

  final exists = await ss.exists(cacheUri) ?? false;
  if (!exists) {
    throw Exception('safCacheSingle: $cacheUri not exists');
  }
  final ss.DocumentFile? domFile = await cacheUri.toDocumentFile();
  final domSize = domFile?.size;
  logger.d('dom size: $domSize');

  final cachePath = await _makeExternalStorageTempPath(cacheUri);
  final file = File(cachePath);
  if (!file.existsSync() || overwrite || file.lengthSync() != domSize) {
    final bytes = await domFile?.getContent();
    if (bytes != null) {
      file.writeAsBytesSync(bytes);
    }
  }

  return cachePath;
}

Future<({String? cachePath, String parentPath})> safCacheSingle(Uri cacheUri,
    {bool overwrite = false}) async {
  final pathSegments = cacheUri.pathSegments;
  logger.d('pathSegments: \n${pathSegments.join('\n')}');

  if (!pathSegments.last.startsWith('primary:')) {
    throw Exception('safCacheSingle: $cacheUri not primary');
  }

  final pathList = pathSegments.last.replaceFirst('primary:', '').split('/');
  final filePath = pathList.join('/');
  final parentPath = pathList.sublist(0, pathList.length - 1).join('/');
  final fileName = pathList.last;

  logger.d('parentPath: $parentPath, fileName: $fileName');

  final saf = Saf(parentPath);
  bool? isGranted = await saf.getDirectoryPermission(isDynamic: false);
  if (isGranted == null || !isGranted) {
    await Saf.releasePersistedPermissions();
    await saf.getDirectoryPermission(isDynamic: false);
  }

  final cachePath = await saf.singleCache(filePath: filePath);
  logger.d('cachePath: $cachePath');

  return (cachePath: cachePath, parentPath: parentPath);
}

Future<String?> safCreateDocumentFileFromPath(
  Uri parentUri, {
  required String sourceFilePath,
  required String? displayName,
  required String? mimeType,
  bool checkPermission = true,
}) async {
  final pathSegments = parentUri.pathSegments;
  logger.d('pathSegments: \n${pathSegments.join('\n')}');

  if (!pathSegments.last.startsWith('primary:')) {
    throw Exception('safCreateDocumentFileFromPath: $parentUri not primary');
  }

  final treePath = pathSegments.last.replaceFirst('primary:', '');

  logger.d('treePath: $treePath, sourceFilePath: $sourceFilePath');

  final saf = Saf(treePath);

  if (checkPermission) {
    bool? isGranted = await saf.getDirectoryPermission(isDynamic: true);
    if (isGranted == null || !isGranted) {
      await Saf.releasePersistedPermissions();
      await saf.getDirectoryPermission(isDynamic: true);
    }
  }

  final documentFileUri = await saf.createDocumentFileFromPath(
    sourceFilePath: sourceFilePath,
    displayName: displayName,
    mimeType: mimeType,
  );
  logger.d('documentFileUri: $documentFileUri');

  return documentFileUri;
}

Future<String> safCache(Uri cacheUri, {bool overwrite = false}) async {
  final cachePath = await _makeExternalStorageTempPath(cacheUri);
  logger.d('cache to cachePath: $cachePath');

  final Stream<ss.DocumentFile> onNewFileLoaded =
      ss.listFiles(cacheUri, columns: kDocumentFileColumns);

  await for (final ss.DocumentFile documentFile in onNewFileLoaded) {
    logger.d(
        'documentFile \n${documentFile.uri}\n${documentFile.name} \n${documentFile.size} \n'
        '${documentFile.lastModified} \n${documentFile.id} \n${documentFile.type}');
    try {
      final bytes = await ss.getDocumentContent(documentFile.uri);
      final file = File(path.join(cachePath, documentFile.name));
      if (bytes != null && bytes.isNotEmpty) {
        if (overwrite) {
          await file.writeAsBytes(bytes);
        } else {
          if (!file.existsSync()) {
            await file.writeAsBytes(bytes);
          }
        }
      }
    } catch (e, stack) {
      logger.e('safCache error', error: e, stackTrace: stack);
    }
  }

  return cachePath;
}

Future<String> _makeExternalStorageTempPath(Uri uri) async {
  final extPath = (await pp.getExternalCacheDirectories())?.firstOrNull;

  final documentFile = await uri.toDocumentFile();
  if (documentFile == null) {
    logger.e('documentFile is null');
    throw Exception('documentFile is null');
  }
  logger.d('documentFile id: ${documentFile.id}');

  if (extPath == null) {
    logger.e('extPath is null');
    throw Exception('getExternalStorageDirectory is null');
  }

  final cachePath = path.join(
    extPath.path,
    kSafCacheDir,
    _makeDirectoryPathToName(documentFile.id ?? ''),
  );

  final parentDir = Directory(path.dirname(cachePath));
  if (!parentDir.existsSync()) {
    parentDir.createSync(recursive: true);
  }

  logger.d('cache to cachePath: $cachePath');

  return cachePath;
}

String _makeDirectoryPathToName(String path) {
  return path.replaceAll('/', '_').replaceAll(':', '_');
}

Uri safMakeUri({
  String path = '',
  String device = 'primary',
  String? tree,
  bool isTreeUri = false,
}) {
  final _path =
      path.replaceAll(RegExp(r'^(/storage/emulated/\d+/|/sdcard/)'), '');
  final _tree =
      tree?.replaceAll(RegExp(r'^(/storage/emulated/\d+/|/sdcard/)'), '');

  final pathSegments = _path.split("/");
  final treePath =
      _tree ?? pathSegments.sublist(0, pathSegments.length - 1).join("/");

  const scheme = 'content';
  const host = 'com.android.externalstorage.documents';

  final documentPathSegments = [
    '$device:$treePath',
    'document',
    '$device:$_path',
  ];

  Uri uri = Uri(
    scheme: scheme,
    host: host,
    pathSegments: [
      'tree',
      if (isTreeUri) '$device:$_path' else ...documentPathSegments,
    ],
  );

  final url = uri.toString();
  final urlWithReplace = url.replaceAll('$device:', '$device%3A');

  return Uri.parse(urlWithReplace);
}

Future<void> safCreateDirectory(Uri uri, {bool documentToTree = false}) async {
  final List<ss.UriPermission>? persistedUriList =
      await ss.persistedUriPermissions();
  logger.d('persistedUriList:\n\n${persistedUriList?.join('\n')}');
  if (persistedUriList == null || persistedUriList.isEmpty) {
    logger.e('persistedUriList is null');
    showToast('persistedUriList is null');
    return;
  }
  // if (persistedUriList.any((e) => e.uri == uri)) {
  //   logger.d('persistedUriList contains uri');
  //   return;
  // }

  if (uri.scheme != 'content' ||
      uri.host != 'com.android.externalstorage.documents') {
    logger.e('uri $uri is not saf uri');
    throw Exception('uri $uri is not saf uri');
  }

  final pathSegments = uri.pathSegments;
  // 路径必须是 tree 开头
  if (pathSegments[0] != 'tree') {
    logger.e('uri $uri is not saf tree uri');
    throw Exception('uri $uri is not saf tree uri');
  }

  logger.d('pathSegments:\n\n${pathSegments.join('\n')}');

  late final String path;
  if (pathSegments.length == 2) {
    logger.d('from tree uri: [${pathSegments[1]}]');
    path = pathSegments[1];
  } else if (pathSegments.length == 4) {
    logger.d('from tree_document uri: [${pathSegments[1]}]');
    if (!documentToTree) {
      path = pathSegments[1];
    } else {
      path = pathSegments[3];
    }
  } else {
    logger.e('uri $uri is not saf uri');
    throw Exception('uri $uri is not saf uri');
  }

  logger.t('device path: [$path]');

  final pathList = path.split(':');
  if (pathList.length != 2) {
    logger.e('uri $uri is not external saf tree uri');
    throw Exception('uri $uri is not external saf tree uri');
  }

  logger.t('path split:\n\n${pathList.join('\n')}');

  final device = pathList[0];
  logger.d('device: $device');

  final dirPath = pathList[1];
  final dirPathList = dirPath.split('/');

  logger.d('dirPathList:\n\n${dirPathList.join('\n')}');

  for (int i = dirPathList.length - 1; i > 0; i--) {
    final dirName = dirPathList[i];
    final parentPath = dirPathList.sublist(0, i).join('/');
    final parentUri =
        safMakeUri(path: parentPath, device: device, isTreeUri: true);

    final childDocumentFile = await ss.findFile(parentUri, dirName);
    if (childDocumentFile != null && (childDocumentFile.isDirectory ?? false)) {
      logger.d('childDocumentFile is directory');
      continue;
    }

    logger.t('dirName: $dirName');
    logger.d('parentPath: $parentPath');
    logger.d('parentUri: $parentUri');
    if (!persistedUriList.any(
        (element) => element.uri == parentUri && element.isWritePermission)) {
      if (parentPath == 'Download' || parentPath == 'Android') {
        continue;
      }
      logger.d('parentUri: $parentUri not persisted');
      showToast('parentUri: $parentUri not persisted');
      await ss.openDocumentTree(initialUri: parentUri);
    }

    for (int j = i; j < dirPathList.length; j++) {
      final dirName = dirPathList[j];
      final parentPath = dirPathList.sublist(0, j).join('/');
      final parentUri = safMakeUri(path: parentPath, isTreeUri: true);

      logger.t(
          '#########\nparentUri: ${parentUri.toString()} \nchildDocumentFile dirName: $dirName');

      final documentFile = await ss.findFile(parentUri, dirName);
      if (documentFile != null) {
        // logger.d('isDirectory ${documentFile.isDirectory}');
        // logger.d('safCreateDirectory: ${documentFile.id} exists');
        continue;
      } else {
        logger.d('safCreateDirectory: $parentUri => $dirName not exists');
        if (!persistedUriList.any((element) => element.uri == parentUri)) {
          logger.d('parentUri: $parentUri not persisted');
          showToast('parentUri: $parentUri not persisted');
          return;
        }
        await ss.createDirectory(parentUri, dirName);
      }
    }
  }
}
