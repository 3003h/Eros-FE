import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:eros_fe/common/global.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as path;

part 'gallery_task.g.dart';

@CopyWith()
@JsonSerializable()
@Collection()
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
    this.downloadOrigImage,
    this.showKey,
  });

  factory GalleryTask.fromJson(Map<String, dynamic> json) =>
      _$GalleryTaskFromJson(json);

  Map<String, dynamic> toJson() => _$GalleryTaskToJson(this);

  // @primaryKey
  @Index(unique: true, replace: true)
  final Id gid;
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
  final bool? downloadOrigImage;
  final String? showKey;

  String? get realDirPath {
    if (dirPath == null) {
      return dirPath;
    }
    if (GetPlatform.isIOS) {
      final List<String> pathList = path.split(dirPath!).reversed.toList();
      // logger.t('$pathList');
      return path.join(Global.appDocPath, pathList[1], pathList[0]);
    } else {
      return dirPath;
    }
  }

  @override
  String toString() {
    return 'GalleryTask{gid: $gid, token: $token, url: $url, title: $title, dirPath: $dirPath, fileCount: $fileCount, completCount: $completCount, status: $status, coverImage: $coverImage, addTime: $addTime, coverUrl: $coverUrl, rating: $rating, category: $category, uploader: $uploader, jsonString: $jsonString, tag: $tag, downloadOrigImage: $downloadOrigImage, showKey: $showKey}';
  }
}
