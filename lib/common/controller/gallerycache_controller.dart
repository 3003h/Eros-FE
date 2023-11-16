import 'dart:collection';
import 'dart:convert';

import 'package:fehviewer/common/controller/mysql_controller.dart';
import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';
import 'package:throttling/throttling.dart';

import '../../pages/gallery/controller/gallery_page_state.dart';

const _kMaxPageState = 60;

class GalleryCacheController extends GetxController {
  final WebdavController webdavController = Get.find();
  LinkedHashMap<String, GalleryCache> gCacheMap = LinkedHashMap();

  final MysqlController mysqlController = Get.find();

  final Map<String, GalleryProvider?> _galleryProviderCache = {};

  GalleryProvider? getGalleryProviderCache(String? gid) {
    return _galleryProviderCache[gid ?? ''];
  }

  void setGalleryProviderCache(String? gid, GalleryProvider? galleryProvider) {
    logger.t('setGalleryProviderCache');
    // clone一个新的对象 避免后续加载更多image影响
    _galleryProviderCache[gid ?? ''] = galleryProvider?.clone();
  }

  final debSync = Debouncing(duration: const Duration(seconds: 5));

  Stream<GalleryCache?> listenGalleryCache(
    String gid, {
    bool sync = true,
  }) async* {
    final _localCache = hiveHelper.getCache(gid);

    if (!gCacheMap.containsKey(gid) && _localCache != null) {
      logger.d('get from store');
      gCacheMap[gid] = _localCache;
    }

    yield gCacheMap[gid];

    if (sync) {
      GalleryCache? remote = await getRemote(gid);

      if (_localCache == null && remote != null) {
        logger.t('local null');
        gCacheMap[gid] = GalleryCache(lastIndex: remote.lastIndex);
        yield gCacheMap[gid];
      } else if (_localCache != null && remote != null) {
        logger.t('both not null');
        if ((remote.time ?? 0) > (_localCache.time ?? 0)) {
          gCacheMap[gid] = _localCache.copyWith(
              lastIndex: remote.lastIndex, time: remote.time);
          yield gCacheMap[gid];
        }
      }
    }
  }

  Future<GalleryCache?> getRemote(String gid) async {
    List<GalleryCache?> remotes = [];
    if (webdavController.syncReadProgress) {
      try {
        final remoteList = await webdavController.getRemotReadList();
        logger.t('remoteList $remoteList');
        if (remoteList.contains(gid)) {
          final remoteWebdav = await webdavController.downloadRead(gid);
          remotes.add(remoteWebdav);
        }
      } catch (e) {
        logger.e('$e');
      }
    }

    if (mysqlController.syncReadProgress) {
      final remoteMysql = await mysqlController.downloadRead(gid);
      remotes.add(remoteMysql);
    }

    return remotes.reduce((value, element) {
      if (value == null) {
        return element;
      } else if (element == null) {
        return value;
      } else {
        return (element.time ?? 0) > (value.time ?? 0) ? element : value;
      }
    });
  }

  Future<void> setIndex(
    String gid,
    int index, {
    bool saveToStore = false,
  }) async {
    if (gid.isEmpty) {
      logger.e('gid is empty');
      return;
    }
    final GalleryCache? _ori = await listenGalleryCache(gid, sync: false).first;
    logger.d('_ori ${_ori?.toJson()}');
    final _time = DateTime.now().millisecondsSinceEpoch;
    if (_ori == null) {
      final _newCache = GalleryCache(gid: gid, lastIndex: index, time: _time);
      logger.d('_newCache ${_newCache.toJson()}');
      gCacheMap[gid] = _newCache;
      if (saveToStore) {
        hiveHelper.saveCache(_newCache);
        _uploadRead(_newCache);
      }
    } else {
      final _newCache = _ori.copyWith(lastIndex: index, time: _time, gid: gid);
      gCacheMap[gid] = _newCache;
      if (saveToStore) {
        hiveHelper.saveCache(_newCache);
        _uploadRead(_newCache);
      }
    }
  }

  void _uploadRead(GalleryCache read) {
    debSync.debounce(() {
      if (webdavController.syncReadProgress) {
        return webdavController.uploadRead(read);
      }

      if (mysqlController.syncReadProgress) {
        return mysqlController.uploadRead(read);
      }
    });
  }

  void saveAll() {
    logger.t(
        'save All GalleryCache \n${gCacheMap.entries.map((e) => jsonEncode(e.value)).join('\n')}');
    gCacheMap.forEach((key, value) {
      hiveHelper.saveCache(value);
    });
  }

  Future<void> setColumnMode(String gid, ViewColumnMode columnMode) async {
    final GalleryCache? _ori = await listenGalleryCache(gid, sync: false).first;
    if (_ori == null) {
      gCacheMap[gid] = GalleryCache(gid: gid).copyWithMode(columnMode);
      hiveHelper.saveCache(GalleryCache(gid: gid).copyWithMode(columnMode));
    } else {
      gCacheMap[gid] = _ori.copyWithMode(columnMode);
      hiveHelper.saveCache(_ori.copyWithMode(columnMode));
    }
  }

  // 缓存GalleryPageState
  final List<GalleryPageState> pageStateList = [];

  void addGalleryPageState(GalleryPageState state) {
    if (state.firstPageImage.isEmpty) {
      return;
    }

    final index =
        pageStateList.indexWhere((element) => element.gid == state.gid);
    if (index > -1) {
      pageStateList[index] = state;
    } else {
      if (pageStateList.length + 1 > _kMaxPageState) {
        pageStateList.removeAt(0);
      }
      pageStateList.add(state);
    }
    logger.t(
        'pageStateList\n${pageStateList.map((e) => '${e.mainTitle} - ${e.galleryProvider?.favcat}').join('\n')}');
  }

  GalleryPageState? getGalleryPageState(String gid) {
    return pageStateList.firstWhereOrNull((element) => element.gid == gid);
  }
}
