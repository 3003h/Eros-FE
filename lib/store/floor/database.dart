import 'dart:async';

import 'package:fehviewer/utils/logger.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/gallery_task_dao.dart';
import 'dao/image_task_dao.dart';
import 'dao/tag_translat_dao.dart';
import 'entity/gallery_image_task.dart';
import 'entity/gallery_task.dart';
import 'entity/tag_translat.dart';

part 'database.g.dart';

@Database(version: 8, entities: [GalleryTask, GalleryImageTask, TagTranslat])
abstract class EhDatabase extends FloorDatabase {
  GalleryTaskDao get galleryTaskDao;

  ImageTaskDao get imageTaskDao;

  TagTranslatDao get tagTranslatDao;
}

final ehMigrations = [
  migration1to2,
  migration2to3,
  migration3to4,
  migration4to5,
  migration5to6,
  migration6to8,
  migration7to8,
];

// create migration
final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE GalleryTask ADD COLUMN dirPath TEXT');
  await database
      .execute('ALTER TABLE GalleryImageTask ADD COLUMN status INTEGER');
});

final migration2to3 = Migration(2, 3, (database) async {
  await database.execute('ALTER TABLE GalleryTask ADD COLUMN coverImage TEXT');
});

final migration3to4 = Migration(3, 4, (database) async {
  await database.execute('ALTER TABLE GalleryTask ADD COLUMN addTime INTEGER');
});

final migration4to5 = Migration(4, 5, (database) async {
  await database.execute('ALTER TABLE GalleryTask ADD COLUMN coverUrl TEXT');
});

final migration5to6 = Migration(5, 6, (database) async {
  await database.execute('ALTER TABLE GalleryTask ADD COLUMN rating REAL');
  await database.execute('ALTER TABLE GalleryTask ADD COLUMN category TEXT');
  await database.execute('ALTER TABLE GalleryTask ADD COLUMN uploader TEXT');
});

Future _addColumnJsonString(sqflite.Database database) async {
  await _addColumn(
    database,
    tabName: 'GalleryTask',
    columnName: 'jsonString',
    type: 'TEXT',
  );
}

final migration7to8 =
    Migration(7, 8, (database) => _addColumnJsonString(database));

final migration6to8 =
    Migration(6, 8, (database) => _addColumnJsonString(database));

final migration8to9 = Migration(
    8,
    9,
    (database) async => await _addColumn(
          database,
          tabName: 'GalleryTask',
          columnName: 'tag',
          type: 'TEXT',
        ));

Future _addColumn(
  sqflite.Database database, {
  required String tabName,
  required String columnName,
  required String type,
}) async {
  final columnExiste = await database.rawQuery(
      'select * from sqlite_master WHERE name=? and sql like ?',
      [tabName, '%`$columnName`%']);
  logger.i('$columnName columnExiste ${columnExiste.isNotEmpty}');
  if (columnExiste.isEmpty) {
    try {
      await database
          .execute('ALTER TABLE $tabName ADD COLUMN $columnName $type');
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }
  }
}
