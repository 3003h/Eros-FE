import 'package:isar/isar.dart';

import '../../index.dart';
import 'entity/gallery_image_task.dart';
import 'entity/gallery_task.dart';
import 'entity/tag_translat.dart';
import 'entity/tag_translate_info.dart';
import 'entity/view_history.dart';

final List<CollectionSchema<dynamic>> schemas = [
  ViewHistorySchema,
  TagTranslatSchema,
  GalleryTaskSchema,
  GalleryImageTaskSchema,
  TagTranslateInfoSchema,
];

Future<Isar> openIsar() async {
  final dirPath = Global.appSupportPath;

  final isar = await Isar.open(
    schemas,
    directory: dirPath,
  );

  return isar;
}
