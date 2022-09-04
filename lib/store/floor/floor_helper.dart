import 'dart:convert';

import 'package:fehviewer/store/floor/entity/view_history.dart';

import '../../fehviewer.dart';
import 'dao/view_history_dao.dart';

class FloorHelper {
  FloorHelper();
  late final ViewHistoryDao viewHistoryDao;

  Future<void> initviewHistoryDao() async {
    viewHistoryDao = (await Global.getDatabase()).viewHistoryDao;
  }

  Future<List<GalleryProvider>> getAllHistory() async {
    final viewHistorys = await viewHistoryDao.findAllViewHistorys();
    final _historys = viewHistorys
        .map((e) => GalleryProvider.fromJson(
            jsonDecode(e.galleryProviderText) as Map<String, dynamic>))
        .toList();
    return _historys;
  }

  Future<GalleryProvider?> getHistory(String gid) async {
    final _gid = int.tryParse(gid) ?? 0;
    final viewHistory = await viewHistoryDao.findViewHistory(_gid);
    if (viewHistory == null) {
      return null;
    }
    return GalleryProvider.fromJson(
        jsonDecode(viewHistory.galleryProviderText) as Map<String, dynamic>);
  }

  Future<void> addHistory(GalleryProvider galleryProvider) async {
    final gid = int.tryParse(galleryProvider.gid ?? '0') ?? 0;
    final lastViewTime = galleryProvider.lastViewTime ?? 0;

    await viewHistoryDao.insertOrReplaceHistory(ViewHistory(
        gid: gid,
        lastViewTime: lastViewTime,
        galleryProviderText: jsonEncode(galleryProvider)));
  }

  Future<void> removeHistory(String gid) async {
    final _gid = int.tryParse(gid) ?? 0;
    await viewHistoryDao.deleteViewHistory(_gid);
  }

  Future<void> cleanHistory() async {
    await viewHistoryDao.deleteAllViewHistory();
  }
}
