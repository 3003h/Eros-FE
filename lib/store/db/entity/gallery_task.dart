import 'package:floor/floor.dart';

@Entity(tableName: 'GalleryTask')
class GalleryTask {
  GalleryTask(this.gid, this.token, this.url, this.title, this.fileCount);

  @primaryKey
  final int gid;
  final String token;
  final String url;
  final String title;
  final int fileCount;
}
