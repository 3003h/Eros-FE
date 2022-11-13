import 'dart:io';

import 'package:fehviewer/fehviewer.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:shared_storage/shared_storage.dart' as ss;

const kSafCacheDir = 'saf_cache';

Future<String> safCache(Uri cacheUri) async {
  const columns = <ss.DocumentFileColumn>[
    ss.DocumentFileColumn.displayName,
    ss.DocumentFileColumn.size,
    ss.DocumentFileColumn.lastModified,
    ss.DocumentFileColumn.id,
    ss.DocumentFileColumn.mimeType,
  ];

  final extPath = await pp.getExternalStorageDirectory();
  if (extPath == null) {
    logger.e('extPath is null');
    throw Exception('getExternalStorageDirectory is null');
  }

  final parentDocumentFile = await cacheUri.toDocumentFile();
  if (parentDocumentFile == null) {
    logger.e('parentDocumentFile is null');
    throw Exception('parentDocumentFile is null');
  }
  logger.d('parentDocumentFile id: ${parentDocumentFile.id}');

  final cachePath = path.join(
    extPath.path,
    kSafCacheDir,
    _makeDirectoryPathToName(parentDocumentFile.id ?? ''),
  );
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
      if (bytes != null && bytes.isNotEmpty && !file.existsSync()) {
        await file.create(recursive: true);
        await file.writeAsBytes(bytes);
      }
    } catch (e, stack) {
      logger.e('safCache error', e, stack);
    }
  }

  return cachePath;
}

String _makeDirectoryPathToName(String path) {
  return path.replaceAll('/', '_').replaceAll(':', '_');
}
