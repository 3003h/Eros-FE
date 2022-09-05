import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fehviewer/store/db/entity/gallery_task.dart';
import 'package:fehviewer/store/db/entity/view_history.dart';
import 'package:fehviewer/store/db/isar.dart';
import 'package:isar/isar.dart';

import '../../fehviewer.dart';
import 'entity/gallery_image_task.dart';
import 'entity/tag_translat.dart';

class IsarHelper {
  late final Isar isar;

  Future<void> initIsar() async {
    isar = await openIsar();
  }

  Future<List<GalleryProvider>> getAllHistory() async {
    final viewHistorys =
        await isar.viewHistorys.where().anyLastViewTime().findAll();
    final _historys = viewHistorys
        .map((e) => GalleryProvider.fromJson(
            jsonDecode(e.galleryProviderText) as Map<String, dynamic>))
        .toList();
    return _historys;
  }

  Future<GalleryProvider?> getHistory(String gid) async {
    final _gid = int.tryParse(gid) ?? 0;
    final viewHistory = await isar.viewHistorys.get(_gid);
    if (viewHistory == null) {
      return null;
    }
    return GalleryProvider.fromJson(
        jsonDecode(viewHistory.galleryProviderText) as Map<String, dynamic>);
  }

  Future<void> addHistory(GalleryProvider galleryProvider) async {
    final gid = int.tryParse(galleryProvider.gid ?? '0') ?? 0;
    final lastViewTime = galleryProvider.lastViewTime ?? 0;

    await isar.writeTxn((isar) async {
      await isar.viewHistorys.put(ViewHistory(
          gid: gid,
          lastViewTime: lastViewTime,
          galleryProviderText: jsonEncode(galleryProvider)));
    });
  }

  Future<void> removeHistory(String gid) async {
    final _gid = int.tryParse(gid) ?? 0;
    await isar.writeTxn((isar) async {
      await isar.viewHistorys.delete(_gid);
    });
  }

  Future<void> cleanHistory() async {
    await isar.writeTxn((isar) async {
      await isar.viewHistorys.where().deleteAll();
    });
  }

  Future<void> addHistorys(List<GalleryProvider> allHistory,
      {bool replaceOnConflict = true}) async {
    final viewHistorys = allHistory
        .map((e) => ViewHistory(
            gid: int.tryParse(e.gid ?? '0') ?? 0,
            lastViewTime: e.lastViewTime ?? 0,
            galleryProviderText: jsonEncode(e)))
        .toList();

    await isar.writeTxn((isar) async {
      await isar.viewHistorys
          .putAll(viewHistorys, replaceOnConflict: replaceOnConflict);
    });
  }

  Future<void> putAllTagTranslate(List<TagTranslat> tagTranslates,
      {bool replaceOnConflict = true}) async {
    await isar.writeTxn((isar) async {
      final count = await isar.tagTranslats
          .putAll(tagTranslates, replaceOnConflict: replaceOnConflict);
      // logger.d('add count $count');
    });
  }

  Future<List<String?>> findAllTagNamespace() async {
    final rult = await isar.tagTranslats
        .where()
        .distinctByNamespace()
        .nameProperty()
        .findAll();
    return rult;
  }

  Future<TagTranslat?> findTagTranslate(String key, {String? namespace}) async {
    if (namespace != null && namespace.isNotEmpty) {
      final rult = await isar.tagTranslats
          .where()
          .keyEqualTo(key)
          .filter()
          .namespaceEqualTo(namespace)
          .findAll();
      return rult.lastOrNull;
    } else {
      final rult = await isar.tagTranslats.where().keyEqualTo(key).findAll();
      return rult.lastOrNull;
    }
  }

  Future<List<TagTranslat>> findTagTranslateContains(
      String text, int limit) async {
    final rult = await isar.tagTranslats
        .filter()
        .keyContains(text)
        .or()
        .nameContains(text)
        .limit(limit)
        .findAll();

    logger.d('rult.len ${rult.length}');

    return rult;
  }

  Future<void> removeAllTagTranslate() async {
    await isar.writeTxn((isar) async {
      final count = await isar.tagTranslats.where().deleteAll();
      logger.d('delete count $count');
    });
  }

  Future<List<GalleryTask>> findAllGalleryTasks() async {
    final taks = await isar.galleryTasks.where().findAll();
    return taks;
  }

  Future<GalleryTask?> findGalleryTaskByGid(int gid) async {
    return await isar.galleryTasks.get(gid);
  }

  Future<void> putGalleryTask(GalleryTask galleryTask,
      {bool replaceOnConflict = true}) async {
    await isar.writeTxn((isar) async {
      await isar.galleryTasks
          .put(galleryTask, replaceOnConflict: replaceOnConflict);
    });
  }

  Future<void> putAllGalleryTasks(List<GalleryTask> galleryTasks,
      {bool replaceOnConflict = true}) async {
    await isar.writeTxn((isar) async {
      await isar.galleryTasks
          .putAll(galleryTasks, replaceOnConflict: replaceOnConflict);
    });
  }

  Future<void> removeGalleryTask(int gid) async {
    await isar.writeTxn((isar) async {
      await isar.galleryTasks.delete(gid);
    });
  }

  Future<List<GalleryImageTask>> findImageTaskAllByGid(int gid) async {
    return await isar.galleryImageTasks.where().findAll();
  }

  Future<void> putImageTask(GalleryImageTask imageTask,
      {bool replaceOnConflict = true}) async {
    await isar.writeTxn((isar) async {
      await isar.galleryImageTasks
          .put(imageTask, replaceOnConflict: replaceOnConflict);
    });
  }

  Future<void> putAllImageTask(List<GalleryImageTask> imageTasks,
      {bool replaceOnConflict = true}) async {
    await isar.writeTxn((isar) async {
      await isar.galleryImageTasks
          .putAll(imageTasks, replaceOnConflict: replaceOnConflict);
    });
  }

  Future<void> removeImageTask(int gid) async {
    await isar.writeTxn((isar) async {
      await isar.galleryImageTasks.where().anyGid().deleteAll();
    });
  }

  Future<void> updateImageTaskStatus(int gid, int ser, int status) async {
    await isar.writeTxn((isar) async {
      final tasks = await isar.galleryImageTasks.getByGidSer(gid, ser);
      if (tasks != null) {
        await isar.galleryImageTasks
            .put(tasks.copyWith(status: status), replaceOnConflict: true);
      }
    });
  }

  Future<List<GalleryImageTask>> finaAllTaskByGidAndStatus(
      int gid, int status) async {
    return await isar.galleryImageTasks
        .where()
        .gidEqualTo(gid)
        .filter()
        .statusEqualTo(status)
        .findAll();
  }
}
