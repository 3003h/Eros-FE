/*import 'package:fehviewer/store/db/entity/gallery_image_task.dart';
import 'package:moor_flutter/moor_flutter.dart';

// part 'gallery_image_task_dao.g.dart';

// @UseDao(tables: [GalleryImageTask])
class GalleryImageTaskDao extends DatabaseAccessor<AppDatabase>
    with _$GalleryImageTaskMixin {

  TodosDao(MyDatabase db) : super(db);

  Stream<List<TodoEntry>> todosInCategory(Category category) {
    if (category == null) {
      return (select(todos)..where((t) => isNull(t.category))).watch();
    } else {
      return (select(todos)..where((t) => t.category.equals(category.id)))
          .watch();
    }
  }
}*/
