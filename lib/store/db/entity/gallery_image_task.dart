import 'package:floor/floor.dart';

@Entity(tableName: 'GalleryImageTask', primaryKeys: ['gid', 'ser'])
class GalleryImageTask {
  GalleryImageTask(
      this.gid, this.token, this.imageUrl, this.ser, this.filePath);

  final int gid;
  final int ser;
  final String token;
  final String imageUrl;
  final String filePath;
}
