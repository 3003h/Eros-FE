import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import '../global.dart';

const _kMaxTime = Duration(days: 7);
const _kFilenameFormat = 'yyyy-MM-dd HH:mm:ss';
const _kSuffix = '.log';

class LogService extends GetxService {
  final RxList<File> _logFiles = <File>[].obs;
  List<File> get logFiles {
    return _logFiles.value;
  }

  set logFiles(val) => _logFiles.value = val;

  final _curFileName = 'eh.log'.obs;
  get curFileName => _curFileName.value;
  set curFileName(val) => _curFileName.value = val;

  final _logPath = ''.obs;
  get logPath => _logPath.value;
  set logPath(val) => _logPath.value = val;

  final Rx<Level> _logLevel = Level.error.obs;
  Level get logLevel => _logLevel.value;
  set logLevel(val) => _logLevel.value = val;

  @override
  void onInit() {
    super.onInit();

    logPath = path.join(
        GetPlatform.isAndroid ? Global.extStorePath : Global.appDocPath, 'log');
    if (!Directory(logPath).existsSync()) {
      Directory(logPath).createSync(recursive: true);
    }

    final DateTime _now = DateTime.now();
    final DateFormat formatter = DateFormat(_kFilenameFormat);
    final String _fileName = formatter.format(_now);
    curFileName = '$_fileName$_kSuffix';
  }

  Future<List<File>?> loadFiles() async {
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
          // logger.v('log file time $_timeString');

          final DateTime _nowTime = DateTime.now();
          final DateFormat formatter = DateFormat(_kFilenameFormat);

          final _fileTime = formatter.parse(_timeString);
          // final _fileTime = DateTime.parse(_timeString);
          final _diff = _nowTime.difference(_fileTime);
          if (_diff.compareTo(_kMaxTime) > 0) {
            // logger.v('delete $_fileName');
            _logFile.delete();
          }
        } catch (_) {}

        _files.add(_logFile);
      }
    }
    _files
        .sort((a, b) => path.basename(b.path).compareTo(path.basename(a.path)));
    _logFiles(_files);
  }

  void removeLogAt(int index) {
    _logFiles[index].deleteSync();
    _logFiles.removeAt(index);
  }

  void removeAll() {
    for (final _file in _logFiles) {
      _file.delete();
    }
    _logFiles.clear();
  }
}
