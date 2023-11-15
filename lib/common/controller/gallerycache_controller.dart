import 'dart:collection';
import 'dart:convert';

import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';
import 'package:throttling/throttling.dart';

import '../../pages/gallery/controller/gallery_page_state.dart';

const _kMaxPageState = 60;

class GalleryCacheController extends GetxController {
  final GStore gStore = Get.find<GStore>();
  final WebdavController webdavController = Get.find();
  LinkedHashMap<String, GalleryCache> gCacheMap = LinkedHashMap();

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
    final _localCache = hiveHelper.getCache(gid) ?? gStore.getCache(gid);

    if (!gCacheMap.containsKey(gid) && _localCache != null) {
      logger.d('get from store');
      gCacheMap[gid] = _localCache;
    }

    yield gCacheMap[gid];

    if (sync && webdavController.syncReadProgress) {
      try {
        final remotelist = await webdavController.getRemotReadList();
        logger.t('remotelist $remotelist');
        if (remotelist.contains(gid)) {
          final remote = await webdavController.downloadRead(gid);
          logger.t('远程 ${remote?.toJson()}');
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
      } catch (e) {
        logger.e('$e');
      }
    }
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
        if (webdavController.syncReadProgress) {
          debSync.debounce(() => webdavController.uploadRead(_newCache));
        }
      }
    } else {
      final _newCache = _ori.copyWith(lastIndex: index, time: _time, gid: gid);
      gCacheMap[gid] = _newCache;
      if (saveToStore) {
        hiveHelper.saveCache(_newCache);
        if (webdavController.syncReadProgress) {
          debSync.debounce(() => webdavController.uploadRead(_newCache));
        }
      }
    }
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
