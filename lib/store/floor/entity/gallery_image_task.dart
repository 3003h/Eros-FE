import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:floor/floor.dart';

part 'gallery_image_task.g.dart';

@CopyWith()
@Entity(tableName: 'GalleryImageTask', primaryKeys: ['gid', 'ser'])
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
