import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import '../../index.dart';

const _kMaxTime = Duration(days: 7);
const _kSuffix = '.log';

class LogService extends GetxController {
  final logFiles = <File>[].obs;

  // 添加自动滚动控制
  final _autoScroll = true.obs;
  bool get autoScroll => _autoScroll.value;
  set autoScroll(bool val) => _autoScroll.value = val;

  final _curFileName = 'eh.log'.obs;
  String get curFileName => _curFileName.value;
  set curFileName(String val) => _curFileName.value = val;

  final _logPath = ''.obs;
  String get logPath => _logPath.value;
  set logPath(String val) => _logPath.value = val;

  final Rx<Level> _logLevel = Level.error.obs;
  Level get logLevel => _logLevel.value;
  set logLevel(Level val) => _logLevel.value = val;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool val) => _isLoading.value = val;

  @override
  void onInit() {
    super.onInit();

    logPath = path.join(
        GetPlatform.isAndroid ? Global.extStorePath : Global.appDocPath, 'log');
    if (!Directory(logPath).existsSync()) {
      Directory(logPath).createSync(recursive: true);
    }

    final DateTime _now = DateTime.now();
    final DateFormat formatter = DateFormat(kFilenameFormat);
    final String _fileName = formatter.format(_now);
    curFileName = '$_fileName$_kSuffix';

    loadFiles();
  }

  Future<void> loadFiles() async {
    isLoading = true;
    logFiles.value = await compute(loadFilesIsolate, logPath);
    isLoading = false;
    logger.d('loadFiles');
  }

  Future<void> refreshFiles() async {
    logFiles.value = await compute(loadFilesIsolate, logPath);
    isLoading = false;
  }

  void removeLogAt(int index) {
    logFiles[index].deleteSync();
    logFiles.removeAt(index);
  }

  void removeAll() {
    for (final _file in logFiles) {
      _file.delete();
    }
    logFiles.clear();
  }
}

// isolate
Future<List<File>> loadFilesIsolate(String logPath) async {
  print('loadFiles log');
  List<File> _files = [];
  final Directory appDocDir = Directory(logPath);
  final Stream<FileSystemEntity> entityList =
      appDocDir.list(recursive: false, followLinks: false);
  await for (final FileSystemEntity entity in entityList) {
    if (entity.path.endsWith(_kSuffix)) {
      final File _logFile = File(entity.path);

      try {
        // 超过最大时间的文件删除
        final _fileName = path.basename(_logFile.path);

        final _timeString = _fileName.replaceAll(_kSuffix, '');
        final DateTime _nowTime = DateTime.now();
        final DateFormat formatter = DateFormat(kFilenameFormat);

        final _fileTime = formatter.parse(_timeString);
        final _diff = _nowTime.difference(_fileTime);
        if (_diff.compareTo(_kMaxTime) > 0) {
          _logFile.delete();
        }
      } catch (e, stack) {}

      _files.add(_logFile);
    }
  }
  _files.sort((a, b) => path.basename(b.path).compareTo(path.basename(a.path)));

  for (final _logfile in _files) {
    final ctx = await _logfile.length();
    if (ctx < 8) {
      _logfile.deleteSync();
    }
  }

  return _files;
}
