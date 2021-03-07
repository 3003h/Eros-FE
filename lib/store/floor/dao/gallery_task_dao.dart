import 'package:floor/floor.dart';

import '../entity/gallery_task.dart';

@dao
abstract class GalleryTaskDao {
  @Query('SELECT * FROM GalleryTask')
  Future<List<GalleryTask>> findAllGalleryTasks();

  @Query('SELECT * FROM GalleryTask WHERE gid = :gid')
  Future<GalleryTask?> findGalleryTaskByGid(int gid);

  @insert
  Future<void> insertTask(GalleryTask galleryTask);
}
