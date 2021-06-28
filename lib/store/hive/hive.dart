import 'dart:convert';

import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

const historyBox = 'history_box';

// ignore: avoid_classes_with_only_static_members
class HiveHelper {
  HiveHelper();
  static final _historyBox = Hive.box<String>(historyBox);

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(historyBox);
  }

  List<GalleryItem> getAll() {
    final _historys = <GalleryItem>[];
    for (final val in _historyBox.values) {
      _historys.add(GalleryItem.fromJson(jsonDecode(val)));
    }
    _historys
        .sort((a, b) => (a.lastViewTime ?? 0).compareTo(b.lastViewTime ?? 0));
    return _historys;
  }

  GalleryItem getHistory(String gid) {
    final itemText = _historyBox.get(gid) ?? '{}';
    return GalleryItem.fromJson(jsonDecode(itemText));
  }

  Future<void> addHistory(GalleryItem galleryItem) async {
    final gid = galleryItem.gid;
    await _historyBox.put(gid, jsonEncode(galleryItem));

    logger.v(_historyBox.keys);

    logger.v('${getHistory(_historyBox.keys.last).toJson()}');
  }

  Future<void> removeHistory(String gid) async {
    _historyBox.delete(gid);
  }

  Future<int> cleanHistory() async {
    return await _historyBox.clear();
  }
}
