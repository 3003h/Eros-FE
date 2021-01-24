import 'package:fehviewer/store/db/entity/gallery_task.dart';
import 'package:floor/floor.dart';

@dao
abstract class ImageTaskDao {
  @Query('SELECT * FROM GalleryImageTask')
  Future<List<GalleryTask>> findAllGalleryTasks();

  @Query('SELECT * FROM GalleryImageTask WHERE gid = :gid')
  Stream<GalleryTask> findGalleryTaskById(int gid);

  @insert
  Future<void> insertPerson(GalleryTask galleryTask);
}
