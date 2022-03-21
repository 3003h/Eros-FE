import 'dart:convert';

import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String historyBox = 'history_box';
const String historyDelBox = 'history_del_box';
const String searchHistoryBox = 'search_history_box';
const String configBox = 'config_box';

const String searchHistoryKey = 'search_history';
const String layoutConfigKey = 'config_layout';

class HiveHelper {
  HiveHelper();
  static final _historyBox = Hive.box<String>(historyBox);
  static final _historyDelBox = Hive.box<String>(historyDelBox);
  static final _searchHistoryBox = Hive.box<String>(searchHistoryBox);
  static final _configBox = Hive.box<String>(configBox);

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(
      historyBox,
      compactionStrategy: (int entries, int deletedEntries) {
        logger.v('entries $entries');
        return entries > 10;
      },
    );
    await Hive.openBox<String>(
      historyDelBox,
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

    await Hive.openBox<String>(configBox);
  }

  List<GalleryProvider> getAllHistory() {
    final _historys = <GalleryProvider>[];
    for (final val in _historyBox.values) {
      _historys.add(
          GalleryProvider.fromJson(jsonDecode(val) as Map<String, dynamic>));
    }
    _historys
        .sort((a, b) => (a.lastViewTime ?? 0).compareTo(b.lastViewTime ?? 0));
    return _historys;
  }

  GalleryProvider getHistory(String gid) {
    final itemText = _historyBox.get(gid) ?? '{}';
    return GalleryProvider.fromJson(
        jsonDecode(itemText) as Map<String, dynamic>);
  }

  Future<void> addHistory(GalleryProvider galleryProvider) async {
    final gid = galleryProvider.gid;
    await _historyBox.put(gid, jsonEncode(galleryProvider));

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

  Future<void> addHistoryDel(HistoryIndexGid gi) async {
    final gid = gi.g;
    await _historyDelBox.put(gid, jsonEncode(gi));
  }

  List<HistoryIndexGid> getAllHistoryDel() {
    final _delHistorys = <HistoryIndexGid>[];
    for (final val in _historyDelBox.values) {
      _delHistorys.add(
          HistoryIndexGid.fromJson(jsonDecode(val) as Map<String, dynamic>));
    }
    return _delHistorys;
  }

  Future<void> removeHistoryDel(String gid) async {
    _historyDelBox.delete(gid);
  }

  Future<void> setSearchHistory(List<String> searchTexts) async {
    await _searchHistoryBox.put(searchHistoryKey, jsonEncode(searchTexts));
  }

  Future<void> setEhLayout(EhLayout ehLayout) async {
    await _configBox.put(layoutConfigKey, jsonEncode(ehLayout));
  }

  EhLayout getEhLayout() {
    final val = _configBox.get(layoutConfigKey, defaultValue: '{}');
    return EhLayout.fromJson(jsonDecode(val ?? '{}') as Map<String, dynamic>);
  }
}
