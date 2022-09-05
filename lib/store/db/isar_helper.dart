import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fehviewer/store/db/entity/view_history.dart';
import 'package:fehviewer/store/db/isar.dart';
import 'package:isar/isar.dart';

import '../../fehviewer.dart';
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

  Future<void> addAllTagTranslate(List<TagTranslat> tagTranslates,
      {bool replaceOnConflict = true}) async {
    await isar.writeTxn((isar) async {
      await isar.tagTranslats
          .putAll(tagTranslates, replaceOnConflict: replaceOnConflict);
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
    return await isar.tagTranslats
        .filter()
        .keyContains(text)
        .or()
        .nameContains(text)
        .limit(limit)
        .findAll();
  }
}
