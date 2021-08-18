import 'dart:convert';

import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String historyBox = 'history_box';
const String searchHistoryBox = 'search_history_box';

const String searchHistoryKey = 'search_history';

// ignore: avoid_classes_with_only_static_members
class HiveHelper {
  HiveHelper();
  static final _historyBox = Hive.box<String>(historyBox);
  static final _searchHistoryBox = Hive.box<String>(searchHistoryBox);

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(
      historyBox,
      compactionStrategy: (int entries, int deletedEntries) {
        logger.v('entries $entries');
        return entries > 10;
      },
    );
    await Hive.openBox<String>(searchHistoryBox,
        compactionStrategy: (int entries, int deletedEntries) {
      logger.v('entries $entries');
      return entries > 20;
    });
  }

  List<GalleryItem> getAllHistory() {
    final _historys = <GalleryItem>[];
    for (final val in _historyBox.values) {
      _historys
          .add(GalleryItem.fromJson(jsonDecode(val) as Map<String, dynamic>));
    }
    _historys
        .sort((a, b) => (a.lastViewTime ?? 0).compareTo(b.lastViewTime ?? 0));
    return _historys;
  }

  GalleryItem getHistory(String gid) {
    final itemText = _historyBox.get(gid) ?? '{}';
    return GalleryItem.fromJson(jsonDecode(itemText) as Map<String, dynamic>);
  }

  Future<void> addHistory(GalleryItem galleryItem) async {
    final gid = galleryItem.gid;
    await _historyBox.put(gid, jsonEncode(galleryItem));

    logger.v('${_historyBox.keys}');
    // _historyBox.compact();
    logger.v('${getHistory(_historyBox.keys.last as String).toJson()}');
  }

  Future<void> removeHistory(String gid) async {
    _historyBox.delete(gid);
  }

  Future<int> cleanHistory() async {
    return await _historyBox.clear();
  }

  List<String> getAllSearchHistory() {
    final rult = <String>[];
    final String? val =
        _searchHistoryBox.get(searchHistoryKey, defaultValue: '[]');
    for (final dynamic his in jsonDecode(val ?? '[]') as List<dynamic>) {
      final String _his = his as String;
      rult.add(_his);
    }
    return rult;
  }

  Future<void> setSearchHistory(List<String> searchTexts) async {
    await _searchHistoryBox.put(searchHistoryKey, jsonEncode(searchTexts));
  }
}
