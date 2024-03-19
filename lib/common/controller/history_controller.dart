import 'dart:convert';

import 'package:eros_fe/common/controller/mysql_controller.dart';
import 'package:eros_fe/common/controller/webdav_controller.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/tab/controller/history_view_controller.dart';
import 'package:eros_fe/pages/tab/view/list/tab_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:throttling/throttling.dart';

class HistoryController extends GetxController {
  final List<GalleryProvider> _histories = <GalleryProvider>[];
  List<GalleryProvider> get histories {
    _histories
        .sort((a, b) => (b.lastViewTime ?? 0).compareTo(a.lastViewTime ?? 0));
    return _histories;
  }

  // 登记删除gid和删除时间，用于同步远程时筛选
  final List<HistoryIndexGid> _delHistories = <HistoryIndexGid>[];

  final EhSettingService _ehSettingService = Get.find();
  final WebdavController webdavController = Get.find();
  final MysqlController mysqlController = Get.find();

  final thrSync = Throttling(duration: const Duration(seconds: 60));
  final debSync = Debouncing(duration: const Duration(seconds: 80));

  bool get isListView =>
      _ehSettingService.listMode.value == ListModeEnum.list ||
      _ehSettingService.listMode.value == ListModeEnum.simpleList;

  void addHistory(
    GalleryProvider galleryProvider, {
    bool updateTime = true,
    bool sync = true,
  }) {
    final _hisViewController = Get.find<HistoryViewController>();

    final int nowTime = DateTime.now().millisecondsSinceEpoch;
    final _item = galleryProvider.copyWith(
      lastViewTime: updateTime ? nowTime.oN : null,
      galleryImages: <GalleryImage>[].oN,
      galleryComment: <GalleryComment>[].oN,
    );

    final _eDelFlg =
        _delHistories.firstWhereOrNull((eDel) => eDel.g == galleryProvider.gid);
    if (nowTime > (_eDelFlg?.t ?? 0)) {
      _removeHistoryDelFlg(galleryProvider.gid ?? '');
    }

    final int _curIndex = histories.indexWhere((element) {
      return element.gid == _item.gid;
    });

    if (_curIndex >= 0) {
      histories.removeAt(_curIndex);
      if (_curIndex > 0 && isListView) {
        // removeItem 动画
        _hisViewController.sliverAnimatedListKey.currentState?.removeItem(
            _curIndex,
            (context, Animation<double> animation) =>
                buildDelGallerySliverListItem(_item, _curIndex, animation));
      }

      _histories.add(_item);
      if (_curIndex > 0 && isListView) {
        // insertItem 动画
        _hisViewController.sliverAnimatedListKey.currentState?.insertItem(0);
      }

      isarHelper.addHistoryIsolate(_item);
    } else {
      _histories.add(_item);
      final insertIndex = histories.indexOf(_item);
      if (isListView) {
        _hisViewController.sliverAnimatedListKey.currentState
            ?.insertItem(insertIndex);
      }

      isarHelper.addHistoryIsolate(_item);
    }

    logger.t('add ${galleryProvider.gid} update1');
    update();

    if (sync) {
      // 节流函数 最多每分钟一次同步
      thrSync.throttle(() {
        logger.t('throttle syncHistory');
        return syncHistory();
      });

      debSync.debounce(syncHistory);
    }
  }

  void removeHistory(String gid, {bool sync = true}) {
    final _hisViewController = Get.find<HistoryViewController>();

    final _index = histories.indexWhere((element) => element.gid == gid);
    final _item = histories[_index];
    histories.removeAt(_index);
    if (isListView) {
      _hisViewController.sliverAnimatedListKey.currentState?.removeItem(
          _index,
          (context, Animation<double> animation) =>
              buildDelGallerySliverListItem(_item, _index, animation));
      update();
    } else {
      update();
    }

    isarHelper.removeHistory(gid);
    _addHistoryDelFlg(gid);

    if (sync) {
      // 节流函数 最多每分钟一次同步
      thrSync.throttle(() {
        logger.t('throttle syncHistory');
        return syncHistory();
      });

      debSync.debounce(syncHistory);
    }
  }

  void _addHistoryDelFlg(String gid) {
    final int nowTime = DateTime.now().millisecondsSinceEpoch;
    final _del = HistoryIndexGid(t: nowTime, g: gid);
    _delHistories.add(_del);
    hiveHelper.addHistoryDel(_del);
  }

  void _removeHistoryDelFlg(String gid) {
    _delHistories.removeWhere((element) => element.g == gid);
    hiveHelper.removeHistoryDel(gid);
  }

  void cleanHistory() {
    histories.clear();
    update();
    // hiveHelper.cleanHistory();
    isarHelper.cleanHistory();
  }

  @override
  void onInit() {
    super.onInit();

    // _histories.addAll(hiveHelper.getAllHistory());
    // _delHistories.addAll(hiveHelper.getAllHistoryDel());
    initHistories();
  }

  Future<void> initHistories() async {
    // 历史迁移
    await historyMigration();
    final histories = await isarHelper.getAllHistory();
    _histories.addAll(histories);
  }

  Future<void> historyMigration() async {
    final isMigrationed = hiveHelper.getViewHistoryMigration();
    logger.t('historyMigration $isMigrationed');
    if (!isMigrationed) {
      logger.d('start history Migration');
      // await isarHelper.addHistoriesAsync(hiveHelper.getAllHistory());
      await isarHelper.addHistoriesIsolate(hiveHelper.getAllHistory());
      hiveHelper.setViewHistoryMigration(true);
    }
  }

  // Future<void> removeRemoteHistory(String gid) async {
  //   // 发送云端标记该画廊为删除 不直接删除云端信息
  //   webdavController.updateRemoveFlg(gid);
  // }

  /// 同步历史记录
  Future<void> syncHistory() async {
    final List<HistoryIndexGid?> listLocal = histories
        .map((e) => HistoryIndexGid(t: e.lastViewTime, g: e.gid))
        .toList();
    logger.t('listLocal ${listLocal.length} \n${listLocal.map((e) => e?.g)}');
    logger.t('${jsonEncode(listLocal)} ');

    syncHistoryMySQL(listLocal);
    syncHistoryWebDAV(listLocal);
  }

  /// 通过mysql同步历史记录
  Future<void> syncHistoryMySQL(List<HistoryIndexGid?> listLocal) async {
    await _syncHistoryCallback(
      enable: mysqlController.syncHistory,
      listLocal: listLocal,
      getRemoteList: mysqlController.getHistoryList,
      uploadLocalHistories: _uploadHistoriesMySQL,
      downloadRemoteHistories: _downloadHistoriesMySQL,
    );
  }

  /// 通过webdav同步历史记录
  Future<void> syncHistoryWebDAV(List<HistoryIndexGid?> listLocal) async {
    await _syncHistoryCallback(
      enable: webdavController.syncHistory,
      listLocal: listLocal,
      getRemoteList: webdavController.getRemoteHistoryList,
      uploadLocalHistories: _uploadHistoriesWebDAV,
      downloadRemoteHistories: _downloadHistoriesWebDAV,
    );
  }

  Future<void> _downloadHistoriesMySQL(List<HistoryIndexGid> hisList) async {
    final _list = await mysqlController
        .downloadHistoryList(hisList.map((e) => e.g).toList());
    for (final _image in _list) {
      if (_image != null) {
        final ori =
            histories.firstWhereOrNull((element) => element.gid == _image.gid);
        if (ori != null &&
            (_image.lastViewTime ?? 0) <= (ori.lastViewTime ?? 0)) {
          continue;
        }
        addHistory(_image, updateTime: false, sync: false);
      }
    }
  }

  Future<void> _uploadHistoriesMySQL(
    List<HistoryIndexGid?> localHisList, {
    List<HistoryIndexGid?>? listRemote,
  }) async {
    for (final his in localHisList) {
      logger.d('his ${his?.g}');
      final GalleryProvider? _his =
          histories.firstWhereOrNull((element) => element.gid == his?.g);

      if (_his != null) {
        await mysqlController.uploadHistory(_his);
      }
    }
  }

  Future<void> _downloadHistoriesWebDAV(List<HistoryIndexGid> hisList) async {
    webdavController.initExecutor();
    for (final gid in hisList) {
      webdavController.webDAVExecutor.scheduleTask(() async {
        if (gid.g != null) {
          final _image =
              await webdavController.downloadHistory('${gid.g!}_${gid.t}');
          if (_image != null) {
            final ori = histories
                .firstWhereOrNull((element) => element.gid == _image.gid);
            if (ori != null && (gid.t ?? 0) <= (ori.lastViewTime ?? 0)) {
              return;
            }
            addHistory(_image, updateTime: false, sync: false);
          }
        }
      });
    }

    await webdavController.webDAVExecutor.join(withWaiting: true);
  }

  Future<void> _uploadHistoriesWebDAV(
    List<HistoryIndexGid?> localHisList, {
    List<HistoryIndexGid?>? listRemote,
  }) async {
    webdavController.initExecutor();
    for (final his in localHisList) {
      webdavController.webDAVExecutor.scheduleTask(() async {
        final GalleryProvider? _his =
            histories.firstWhereOrNull((element) => element.gid == his?.g);

        final _oriRemote =
            listRemote?.firstWhereOrNull((element) => element?.g == his?.g);

        if (_his != null) {
          final upload = webdavController.uploadHistory(_his);
          final delete = webdavController.deleteHistory(_oriRemote);
          await Future.wait([upload, delete]);
        }
      });
    }
    await webdavController.webDAVExecutor.join(withWaiting: true);
  }

  Future<void> _syncHistoryCallback({
    bool enable = false,
    required List<HistoryIndexGid?> listLocal,
    required Future<List<HistoryIndexGid>> Function() getRemoteList,
    required Future<void> Function(
      List<HistoryIndexGid?>, {
      List<HistoryIndexGid?>? listRemote,
    }) uploadLocalHistories,
    required Future<void> Function(List<HistoryIndexGid>)
        downloadRemoteHistories,
  }) async {
    logger.d('syncHistoryCallback');
    if (!enable) {
      return;
    }

    // 下载远程列表
    final listRemote = await getRemoteList();
    if (listRemote.isEmpty) {
      await uploadLocalHistories(listLocal);
      return;
    }

    logger.d('listRemote ${listRemote.length}');

    // 比较远程和本地的差异
    // final combinedList = <HistoryIndexGid?>{...listRemote, ...listLocal};
    // final diff = combinedList
    //     .where((element) =>
    //         !listRemote.contains(element) || !listLocal.contains(element))
    //     .toList()
    //     .toSet();

    // 本地时间更大的画廊
    final localNewer = listLocal.where(
      (eLocal) {
        if (eLocal == null) {
          return false;
        }
        final _eRemote =
            listRemote.firstWhereOrNull((eRemote) => eRemote.g == eLocal.g);
        if (_eRemote == null) {
          return true;
        }

        return (eLocal.t ?? 0) > (_eRemote.t ?? 0);
      },
    );

    // 远程时间更大的画廊
    final remoteNewer = listRemote.where(
      (eRemote) {
        final _eLocal = listLocal
            .firstWhereOrNull((eLocal) => (eLocal?.g ?? '') == eRemote.g);

        final _eDelFlg = _delHistories
            .firstWhereOrNull((eDel) => (eDel.g ?? '') == eRemote.g);

        if (_eDelFlg != null) {
          return (eRemote.t ?? 0) > (_eDelFlg.t ?? 0);
        }

        if (_eLocal == null) {
          return true;
        }

        return (eRemote.t ?? 0) > (_eLocal.t ?? 0);
      },
    );

    logger.d('localNewer ${localNewer.length} ${localNewer.map((e) => e?.g)}');

    await downloadRemoteHistories(remoteNewer.toSet().toList());

    await uploadLocalHistories(localNewer.toList(), listRemote: listRemote);
  }
}
