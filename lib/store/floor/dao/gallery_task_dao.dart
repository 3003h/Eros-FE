import 'package:floor/floor.dart';

import '../entity/gallery_task.dart';

@dao
abstract class GalleryTaskDao {
  @Query('SELECT * FROM GalleryTask')
  Future<List<GalleryTask>> findAllGalleryTasks();

  @Query('SELECT * FROM GalleryTask')
  Stream<List<GalleryTask>> listenAllGalleryTasks();

  @Query('SELECT * FROM GalleryTask WHERE gid = :gid')
  Future<GalleryTask?> findGalleryTaskByGid(int gid);

  @insert
  Future<void> insertTask(GalleryTask galleryTask);

  @insert
  Future<void> insertTasks(List<GalleryTask> galleryTasks);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertOrReplaceTasks(List<GalleryTask> galleryTasks);

  @Query('DELETE FROM GalleryTask WHERE gid = :gid')
  Future<void> deleteTaskByGid(int gid);

  @update
  Future<void> updateTask(GalleryTask galleryTask);

  @Query('UPDATE GalleryImageTask set status = :status WHERE gid = :gid')
  Future<void> updateStatusByGid(int status, int gid);
}
