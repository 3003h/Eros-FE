import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import '../../fehviewer.dart';

const _kMaxTime = Duration(days: 7);
const _kSuffix = '.log';

class LogService extends GetxController {
  final logFiles = <File>[].obs;

  final _curFileName = 'eh.log'.obs;
  String get curFileName => _curFileName.value;
  set curFileName(String val) => _curFileName.value = val;

  final _logPath = ''.obs;
  String get logPath => _logPath.value;
  set logPath(String val) => _logPath.value = val;

  final Rx<Level> _logLevel = Level.error.obs;
  Level get logLevel => _logLevel.value;
  set logLevel(Level val) => _logLevel.value = val;

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
          // print('log file time $_timeString');

          final DateTime _nowTime = DateTime.now();
          final DateFormat formatter = DateFormat(kFilenameFormat);

          final _fileTime = formatter.parse(_timeString);
          // final _fileTime = DateTime.parse(_timeString);
          final _diff = _nowTime.difference(_fileTime);
          // print('diff $_diff');
          if (_diff.compareTo(_kMaxTime) > 0) {
            // logger.v('delete $_fileName');
            _logFile.delete();
          }
          // update();
        } catch (e, stack) {}

        _files.add(_logFile);
      }
    }
    _files
        .sort((a, b) => path.basename(b.path).compareTo(path.basename(a.path)));
    logFiles(_files);

    for (final _logfile in logFiles) {
      final ctx = await _logfile.length();
      if (ctx < 8) {
        _logfile.deleteSync();
        logFiles.remove(_logfile);
      }
    }
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
