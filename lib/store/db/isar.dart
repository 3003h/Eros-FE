import 'package:fehviewer/store/db/entity/gallery_task.dart';
import 'package:isar/isar.dart';

import '../../fehviewer.dart';
import 'entity/gallery_image_task.dart';
import 'entity/tag_translat.dart';
import 'entity/view_history.dart';

Future<Isar> openIsar() async {
  final dirPath = Global.appSupportPath;

  final isar = await Isar.open(
     [
      ViewHistorySchema,
      TagTranslatSchema,
      GalleryTaskSchema,
      GalleryImageTaskSchema,
    ],
    directory: dirPath,
  );

  return isar;
}
