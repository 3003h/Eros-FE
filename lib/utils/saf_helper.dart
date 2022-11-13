import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:shared_storage/shared_storage.dart' as ss;

const kSafCacheDir = 'saf_cache';

Future<String> safCacheSingle(Uri cacheUri, {bool overwrite = false}) async {
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

Future<String> safCache(Uri cacheUri, {bool overwrite = false}) async {
  const columns = <ss.DocumentFileColumn>[
    ss.DocumentFileColumn.displayName,
    ss.DocumentFileColumn.size,
    ss.DocumentFileColumn.lastModified,
    ss.DocumentFileColumn.id,
    ss.DocumentFileColumn.mimeType,
  ];

  final cachePath = await _makeExternalStorageTempPath(cacheUri);
  logger.d('cache to cachePath: $cachePath');

  final Stream<ss.DocumentFile> onNewFileLoaded =
      ss.listFiles(cacheUri, columns: columns);

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
      logger.e('safCache error', e, stack);
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

String safMakeUriString({String path = '', bool isTreeUri = false}) {
  path = path.replaceAll(RegExp(r'^(/storage/emulated/\d+/|/sdcard/)'), '');

  String uri = '';
  String base =
      'content://com.android.externalstorage.documents/tree/primary%3A';
  String documentUri = '/document/primary%3A' +
      path.replaceAll('/', '%2F').replaceAll(' ', '%20');
  if (isTreeUri) {
    uri = base + path.replaceAll('/', '%2F').replaceAll(' ', '%20');
  } else {
    var pathSegments = path.split('/');
    var fileName = pathSegments[pathSegments.length - 1];
    var directory = path.split('/$fileName')[0];
    uri = base +
        directory.replaceAll('/', '%2F').replaceAll(' ', '%20') +
        documentUri;
  }
  return uri;
}
