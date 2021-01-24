import 'package:floor/floor.dart';

@Entity(tableName: 'GalleryTask')
class GalleryTask {
  GalleryTask(
      {this.gid,
      this.token,
      this.url,
      this.title,
      this.fileCount,
      this.completCount,
      this.status});

  @primaryKey
  final int gid;
  final String token;
  final String url;
  final String title;
  final int fileCount;
  final int completCount;
  final int status;

  @override
  String toString() {
    return 'GalleryTask{gid: $gid, token: $token, url: $url, title: $title, fileCount: $fileCount, completCount: $completCount, status: $status}';
  }
}
