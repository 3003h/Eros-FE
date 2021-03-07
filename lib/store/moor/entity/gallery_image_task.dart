import 'package:moor/moor.dart';

class GalleryImageTask extends Table {
  IntColumn get gid => integer()();
  TextColumn get token => text()();
  IntColumn get ser => integer()();
  TextColumn get href => text()();
}
