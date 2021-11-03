import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fehviewer/common/global.dart';
import 'package:floor/floor.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

part 'gallery_task.g.dart';

/// 1to2 update entity with new 'dirPath' field
/// 2to3 update entity with new 'coverImage' field
/// 3to4 update entity with new 'addTime' field
/// 4to5 update entity with new 'coverUrl' field
/// 5to6 update entity with new 'rating', 'category', 'uploader' field
/// 6to7 8 update entity with new 'jsonString' field
/// 8to9 update entity with new 'tag' field
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
    this.coverUrl,
    this.rating,
    this.category,
    this.uploader,
    this.jsonString,
    this.tag,
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
  final String? coverUrl;
  final double? rating;
  final String? category;
  final String? uploader;
  final String? jsonString;
  final String? tag;

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
    return 'GalleryTask{gid: $gid, token: $token, url: $url, title: $title, dirPath: $dirPath, fileCount: $fileCount, completCount: $completCount, status: $status, coverImage: $coverImage, addTime: $addTime, coverUrl: $coverUrl, rating: $rating, category: $category, uploader: $uploader, jsonString: $jsonString, tag: $tag}';
  }
}
