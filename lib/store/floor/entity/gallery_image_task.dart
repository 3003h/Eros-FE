import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gallery_image_task.g.dart';

@CopyWith()
@Entity(tableName: 'GalleryImageTask', primaryKeys: ['gid', 'ser'])
@JsonSerializable()
class GalleryImageTask {
  GalleryImageTask({
    required this.gid,
    required this.token,
    this.href,
    this.sourceId,
    this.imageUrl,
    required this.ser,
    this.filePath,
    this.status,
  });

  factory GalleryImageTask.fromJson(Map<String, dynamic> json) =>
      _$GalleryImageTaskFromJson(json);

  Map<String, dynamic> toJson() => _$GalleryImageTaskToJson(this);

  final int gid;
  final int ser;
  final String token;
  final String? href;
  final String? sourceId;
  final String? imageUrl;
  final String? filePath;
  final int? status;

  @override
  String toString() {
    return 'GalleryImageTask{gid: $gid, ser: $ser, token: $token, href: $href, sourceId: $sourceId, imageUrl: $imageUrl, filePath: $filePath, status: $status}';
  }
}
