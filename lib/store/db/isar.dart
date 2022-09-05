import 'package:isar/isar.dart';

import '../../fehviewer.dart';
import 'entity/view_history.dart';
import 'entity/tag_translat.dart';

Future<Isar> openIsar() async {
  final dirPath = Global.appSupportPath;

  final isar = await Isar.open(
    schemas: [ViewHistorySchema, TagTranslatSchema],
    directory: dirPath,
  );

  return isar;
}
