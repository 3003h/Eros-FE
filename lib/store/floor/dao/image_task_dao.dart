import 'package:floor/floor.dart';

import '../entity/gallery_image_task.dart';

@dao
abstract class ImageTaskDao {
  @Query('SELECT * FROM GalleryImageTask')
  Future<List<GalleryImageTask>> findAllImageTasks();

  @Query('SELECT * FROM GalleryImageTask WHERE gid = :gid')
  Future<List<GalleryImageTask>> findAllGalleryTaskByGid(int gid);

  @Query('SELECT * FROM GalleryImageTask WHERE gid = :gid and ser = :ser')
  Future<GalleryImageTask?> findGalleryTaskByKey(int gid, int ser);

  @insert
  Future<void> insertImageTask(GalleryImageTask galleryImageTask);

  @insert
  Future<void> insertImageTasks(List<GalleryImageTask> galleryImageTasks);

  @update
  Future<void> updateImageTask(GalleryImageTask galleryImageTask);

  @Query('DELETE FROM GalleryImageTask WHERE gid = :gid')
  Future<void> deleteImageTaskByGid(int gid);

  @Query('SELECT * FROM GalleryImageTask WHERE gid = :gid AND status = :status')
  Future<List<GalleryImageTask>> countImageTaskByGidAndStatus(
      int gid, int status);
}
