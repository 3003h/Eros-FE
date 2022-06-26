
import 'dart:io';

import 'package:archive_async/archive_async.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<AsyncArchive, AsyncInputStream>> readAsyncArchive(String filePath) async {
  final file = await File(filePath).open(mode: FileMode.read);

  final fileLength = await file.length();

  final loaderHandle = LoaderHandle(fileLength, (AsyncInputStream ais, int offset, int length) async {
    await file.setPosition(offset);
    final buff = (await file.read(length)).buffer.asUint8List();
    return buff;
  });

  final inputStream = AsyncInputStream(debounceLoader(loaderHandle));

  final AsyncArchive archive = await AsyncZipDecoder().decodeBuffer(inputStream);
  return Tuple2(archive, inputStream);
}