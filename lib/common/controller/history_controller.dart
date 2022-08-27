import 'dart:convert';

import 'package:executor/executor.dart';
import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/controller/history_view_controller.dart';
import 'package:fehviewer/pages/tab/view/tab_base.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:throttling/throttling.dart';

class HistoryController extends GetxController {
  final List<GalleryProvider> _historys = <GalleryProvider>[];
  List<GalleryProvider> get historys {
    _historys
        .sort((a, b) => (b.lastViewTime ?? 0).compareTo(a.lastViewTime ?? 0));
    return _historys;
  }

  // 登记删除gid和删除时间，用于同步远程时筛选
  final List<HistoryIndexGid> _delHistorys = <HistoryIndexGid>[];

  final EhConfigService _ehConfigService = Get.find();
  final WebdavController webdavController = Get.find();

  final thrSync = Throttling(duration: const Duration(seconds: 60));
  final debSync = Debouncing(duration: const Duration(seconds: 80));

  final executor = Executor(concurrency: 1);

  bool get isListView =>
      _ehConfigService.listMode.value == ListModeEnum.list ||
      _ehConfigService.listMode.value == ListModeEnum.simpleList;

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
        _delHistorys.firstWhereOrNull((eDel) => eDel.g == galleryProvider.gid);
    if (nowTime > (_eDelFlg?.t ?? 0)) {
      _removeHistoryDelFlg(galleryProvider.gid ?? '');
    }

    final int _curIndex = historys.indexWhere((element) {
      return element.gid == _item.gid;
    });

    if (_curIndex >= 0) {
      historys.removeAt(_curIndex);
      if (_curIndex > 0 && isListView) {
        // removeItem 动画
        _hisViewController.sliverAnimatedListKey.currentState?.removeItem(
            _curIndex,
            (context, Animation<double> animation) =>
                buildDelGallerySliverListItem(_item, _curIndex, animation));
      }

      // historys.insert(0, _item);
      _historys.add(_item);
      if (_curIndex > 0 && isListView) {
        // insertItem 动画
        _hisViewController.sliverAnimatedListKey.currentState?.insertItem(0);
      }

      hiveHelper.addHistory(_item);
    } else {
      // historys.insert(0, _item);
      _historys.add(_item);
      final insertIndex = historys.indexOf(_item);
      if (isListView) {
        _hisViewController.sliverAnimatedListKey.currentState
            ?.insertItem(insertIndex);
      }
      hiveHelper.addHistory(_item);
    }

    logger.v('add ${galleryProvider.gid} update1');
    update();
    // if (!isListView) {
    //   update();
    // }

    if (sync) {
      // 节流函数 最多每分钟一次同步
      thrSync.throttle(() {
        logger.v('throttle syncHistory');
        return syncHistory();
      });

      debSync.debounce(syncHistory);
    }
  }

  void removeHistory(String gid, {bool sync = true}) {
    final _hisViewController = Get.find<HistoryViewController>();

    final _index = historys.indexWhere((element) => element.gid == gid);
    final _item = historys[_index];
    historys.removeAt(_index);
    if (isListView) {
      _hisViewController.sliverAnimatedListKey.currentState?.removeItem(
          _index,
          (context, Animation<double> animation) =>
              buildDelGallerySliverListItem(_item, _index, animation));
      update();
    } else {
      update();
    }

    hiveHelper.removeHistory(gid);
    _addHistoryDelFlg(gid);

    if (sync) {
      // 节流函数 最多每分钟一次同步
      thrSync.throttle(() {
        logger.v('throttle syncHistory');
        return syncHistory();
      });

      debSync.debounce(syncHistory);
    }
  }

  void _addHistoryDelFlg(String gid) {
    final int nowTime = DateTime.now().millisecondsSinceEpoch;
    final _del = HistoryIndexGid(t: nowTime, g: gid);
    _delHistorys.add(_del);
    hiveHelper.addHistoryDel(_del);
  }

  void _removeHistoryDelFlg(String gid) {
    _delHistorys.removeWhere((element) => element.g == gid);
    hiveHelper.removeHistoryDel(gid);
  }

  void cleanHistory() {
    historys.clear();
    update();
    hiveHelper.cleanHistory();
  }

  @override
  void onInit() {
    super.onInit();

    _historys.addAll(hiveHelper.getAllHistory());
    _delHistorys.addAll(hiveHelper.getAllHistoryDel());
  }

  // Future<void> removeRemoteHistory(String gid) async {
  //   // 发送云端标记该画廊为删除 不直接删除云端信息
  //   webdavController.updateRemoveFlg(gid);
  // }

  Future<void> syncHistory() async {
    if (!webdavController.syncHistory) {
      // logger.d('disable syncHistory');
      return;
    }

    final List<HistoryIndexGid?> listLocal = historys
        .map((e) => HistoryIndexGid(t: e.lastViewTime, g: e.gid))
        .toList();
    logger.v('listLocal ${listLocal.length} \n${listLocal.map((e) => e?.g)}');
    logger.v('${jsonEncode(listLocal)} ');

    // 下载远程列表
    final listRemote = await webdavController.getRemoteHistoryList();
    if (listRemote.isEmpty) {
      await _uploadHistorys(listLocal.toList());
      return;
    }

    logger.v('listRemote size ${listRemote.length}');
    // yield true;

    // 比较远程和本地的差异
    final allGid = <HistoryIndexGid?>{...listRemote, ...listLocal};
    final diff = allGid
        .where((element) =>
            !listRemote.contains(element) || !listLocal.contains(element))
        .toList()
        .toSet();
    logger.v('diff ${diff.map((e) => e?.toJson())}');

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
    logger.v('localNewer count ${localNewer.length}');

    // 远程时间更大的画廊
    final remoteNewer = listRemote.where(
      (eRemote) {
        final _eLocal = listLocal
            .firstWhereOrNull((eLocal) => (eLocal?.g ?? '') == eRemote.g);

        final _eDelFlg = _delHistorys
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
    logger.v('remoteNewer ${remoteNewer.map((e) => e.g).toList()}');

    await _downloadHistorys(remoteNewer.toSet().toList());

    await _uploadHistorys(localNewer.toList(), listRemote: listRemote);
  }

  Future _downloadHistorys(List<HistoryIndexGid> hisList) async {
    for (final gid in hisList) {
      executor.scheduleTask(() async {
        if (gid.g != null) {
          final _image =
              await webdavController.downloadHistory('${gid.g!}_${gid.t}');
          if (_image != null) {
            final ori = historys
                .firstWhereOrNull((element) => element.gid == _image.gid);
            if (ori != null && (gid.t ?? 0) <= (ori.lastViewTime ?? 0)) {
              return;
            }
            addHistory(_image, updateTime: false, sync: false);
          }
        }
      });
    }

    await executor.join(withWaiting: true);
  }

  Future _uploadHistorys(
    List<HistoryIndexGid?> localHisList, {
    List<HistoryIndexGid?>? listRemote,
  }) async {
    for (final his in localHisList) {
      executor.scheduleTask(() async {
        final GalleryProvider? _his =
            historys.firstWhereOrNull((element) => element.gid == his?.g);

        final _oriRemote =
            listRemote?.firstWhereOrNull((element) => element?.g == his?.g);

        if (_his != null) {
          final upload = webdavController.uploadHistory(_his);
          final delete = webdavController.deleteHistory(_oriRemote);
          await Future.wait([upload, delete]);
        }
      });
    }
    await executor.join(withWaiting: true);
  }

  // Future<void> _uploadHistoryIndex(List<HistoryIndexGid?> gids) async {
  //   final _time = DateTime.now().millisecondsSinceEpoch;
  //   await webdavController.uploadHistoryIndex(
  //       gids.where((element) => element != null).toList(), _time);
  // }
}
