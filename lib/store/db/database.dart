import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/gallery_task_dao.dart';
import 'dao/image_task_dao.dart';
import 'entity/gallery_image_task.dart';
import 'entity/gallery_task.dart';

part 'database.g.dart';

@Database(version: 1, entities: [GalleryTask, GalleryImageTask])
abstract class AppDatabase extends FloorDatabase {
  GalleryTaskDao get galleryTaskDao;
  ImageTaskDao get imageTaskDao;
}
