import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/gallery_task_dao.dart';
import 'dao/image_task_dao.dart';
import 'dao/tag_translat_dao.dart';
import 'entity/gallery_image_task.dart';
import 'entity/gallery_task.dart';
import 'entity/tag_translat.dart';

part 'database.g.dart';

@Database(version: 7, entities: [GalleryTask, GalleryImageTask, TagTranslat])
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
  migration6to7,
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

final migration6to7 = Migration(6, 7, (database) async {
  await database.execute('ALTER TABLE GalleryTask ADD COLUMN jsonString TEXT');
});
