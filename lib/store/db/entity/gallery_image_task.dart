import 'package:floor/floor.dart';

@Entity(tableName: 'GalleryImageTask', primaryKeys: ['gid', 'ser'])
class GalleryImageTask {
  GalleryImageTask({
    this.gid,
    this.token,
    this.href,
    this.imageUrl,
    this.ser,
    this.filePath,
  });

  final int gid;
  final int ser;
  final String token;
  final String href;
  final String imageUrl;
  final String filePath;

  @override
  String toString() {
    return 'GalleryImageTask{gid: $gid, ser: $ser, token: $token, href: $href, imageUrl: $imageUrl, filePath: $filePath}';
  }
}
