import 'dart:convert';

import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/history_view_controller.dart';
import 'package:fehviewer/pages/tab/view/list/tab_base.dart';
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
      lastViewTime: updateTime ? nowTime : null,
      galleryImages: [],
      galleryComment: [],
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

    // TODO
    syncHistoryMySQL();

    if (sync) {
      // 节流函数 最多每分钟一次同步
      thrSync.throttle(() {
        logger.t('throttle syncHistory');
        return syncHistoryWebDAV();
      });

      debSync.debounce(syncHistoryWebDAV);
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

    // hiveHelper.removeHistory(gid);
    isarHelper.removeHistory(gid);
    _addHistoryDelFlg(gid);

    if (sync) {
      // 节流函数 最多每分钟一次同步
      thrSync.throttle(() {
        logger.t('throttle syncHistory');
        return syncHistoryWebDAV();
      });

      debSync.debounce(syncHistoryWebDAV);
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

  Future<void> syncHistoryMySQL() async {
    logger.d('syncHistoryMySQL');
  }

  Future<void> syncHistoryWebDAV() async {
    if (!webdavController.syncHistory) {
      // logger.d('disable syncHistory');
      return;
    }

    final List<HistoryIndexGid?> listLocal = histories
        .map((e) => HistoryIndexGid(t: e.lastViewTime, g: e.gid))
        .toList();
    logger.t('listLocal ${listLocal.length} \n${listLocal.map((e) => e?.g)}');
    logger.t('${jsonEncode(listLocal)} ');

    // 下载远程列表
    final listRemote = await webdavController.getRemoteHistoryList();
    if (listRemote.isEmpty) {
      await _uploadHistories(listLocal.toList());
      return;
    }

    logger.t('listRemote size ${listRemote.length}');
    // yield true;

    // 比较远程和本地的差异
    final allGid = <HistoryIndexGid?>{...listRemote, ...listLocal};
    final diff = allGid
        .where((element) =>
            !listRemote.contains(element) || !listLocal.contains(element))
        .toList()
        .toSet();
    logger.t('diff ${diff.map((e) => e?.toJson())}');

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
    logger.t('localNewer count ${localNewer.length}');

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
    logger.t('remoteNewer ${remoteNewer.map((e) => e.g).toList()}');

    await _downloadHistories(remoteNewer.toSet().toList());

    await _uploadHistories(localNewer.toList(), listRemote: listRemote);
  }

  Future _downloadHistories(List<HistoryIndexGid> hisList) async {
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

  Future _uploadHistories(
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

  // Future<void> _uploadHistoryIndex(List<HistoryIndexGid?> gids) async {
  //   final _time = DateTime.now().millisecondsSinceEpoch;
  //   await webdavController.uploadHistoryIndex(
  //       gids.where((element) => element != null).toList(), _time);
  // }
}
