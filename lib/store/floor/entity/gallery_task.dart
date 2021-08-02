import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:floor/floor.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

part 'gallery_task.g.dart';

// 1to2 update entity with new 'dirPath' field
// 2to3 update entity with new 'coverImage' field
// 3to4 update entity with new 'addTime' field
@CopyWith()
@Entity(tableName: 'GalleryTask')
class GalleryTask {
  GalleryTask({
    required this.gid,
    required this.token,
    this.url,
    required this.title,
    required this.dirPath,
    required this.fileCount,
    this.completCount,
    this.status,
    this.coverImage,
    this.addTime,
  });

  @primaryKey
  final int gid;
  final String token;
  final String? url;
  final String title;
  final String? dirPath;
  final int fileCount;
  final int? completCount;
  final int? status;
  final String? coverImage;
  final int? addTime;

  String? get realDirPath {
    if (dirPath == null) {
      return dirPath;
    }
    if (GetPlatform.isIOS) {
      final List<String> pathList = path.split(dirPath!).reversed.toList();
      // logger.v('$pathList');
      return path.join(Global.appDocPath, pathList[1], pathList[0]);
    } else {
      return dirPath;
    }
  }

  @override
  String toString() {
    return 'GalleryTask{gid: $gid, token: $token, url: $url, title: $title, dirPath: $dirPath, fileCount: $fileCount, completCount: $completCount, status: $status, coverImage: $coverImage, addTime: $addTime}';
  }
}
