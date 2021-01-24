import 'package:fehviewer/store/db/entity/gallery_image_task.dart';
import 'package:floor/floor.dart';

@dao
abstract class GalleryTaskDao {
  @Query('SELECT * FROM GalleryTask')
  Future<List<GalleryImageTask>> findAllGalleryTasks();

  @Query('SELECT * FROM GalleryTask WHERE gid = :gid')
  Stream<GalleryImageTask> findGalleryTaskById(int gid);

  @insert
  Future<void> insertPerson(GalleryImageTask galleryImageTask);
}
