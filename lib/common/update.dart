import 'dart:io';

import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/const/storages.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/utils/storage.dart';
import 'package:path/path.dart' as path;

Future<void> dataUpdate() async {
  if (!Global.isFirstOpen && !Global.isDBinappSupportPath) {
    // 不是第一次打开并且DB不位于 appSupport
    // 迁移DB数据
    logger.d('迁移DB数据');
    await moveDB();
    StorageUtil().setBool(IS_DB_IN_SUPPORT_DIR, true);
  }
}

/// 升级兼容处理 把数据库文件从doc目录移动到appSupport
Future<void> moveDB() async {
  final Directory appDocDir = Directory(Global.appDocPath);
  final Stream<FileSystemEntity> entityList =
      appDocDir.list(recursive: false, followLinks: false);
  await for (final FileSystemEntity entity in entityList) {
//文件、目录和链接都继承自FileSystemEntity
//FileSystemEntity.type静态函数返回值为FileSystemEntityType
//FileSystemEntityType有三个常量：
//Directory、FILE、LINK、NOT_FOUND
//FileSystemEntity.isFile .isLink .isDerectory可用于判断类型
// logger.d(entity.path);
    if (entity.path.endsWith('.db')) {
      final File _dbFile = File(entity.path);
      final String fileName =
          _dbFile.path.substring(_dbFile.path.lastIndexOf(path.separator) + 1);
// logger.d(join(appSupportPath, fileName));
      _dbFile.copySync(path.join(Global.appSupportPath, fileName));
      _dbFile.deleteSync();
    } else if (entity.path.endsWith('ie0_ps1')) {
      final Directory _ieDir = Directory(entity.path);
      final Directory _ieDirNew = Directory(
          _ieDir.path.replaceAll(Global.appDocPath, Global.appSupportPath));
      logger.d(_ieDirNew.path);
      final Stream<FileSystemEntity> _ieList =
          _ieDir.list(recursive: false, followLinks: false);
      await for (final FileSystemEntity _ieEntity in _ieList) {
// logger.d(_ieEntity.path);
        final File _cookieFile = File(_ieEntity.path);
        final String _cookieFileName = _cookieFile.path
            .substring(_cookieFile.path.lastIndexOf(path.separator) + 1);
// logger.d('to  ' + join(appSupportPath, _cookieFileName));
        _cookieFile.copySync(path.join(Global.appSupportPath, _cookieFileName));
        _cookieFile.deleteSync();
      }
      _ieDir.deleteSync();
    }
  }
  Global.creatDirs();
}
