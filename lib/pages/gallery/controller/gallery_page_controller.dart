import 'package:dio/dio.dart';
import 'package:eros_fe/common/controller/cache_controller.dart';
import 'package:eros_fe/common/controller/download_controller.dart';
import 'package:eros_fe/common/controller/gallerycache_controller.dart';
import 'package:eros_fe/common/controller/history_controller.dart';
import 'package:eros_fe/common/controller/localfav_controller.dart';
import 'package:eros_fe/common/parser/eh_parser.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/network/app_dio/pdio.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/pages/gallery/gallery_repository.dart';
import 'package:eros_fe/pages/gallery/view/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:synchronized/synchronized.dart';

import 'all_thumbnails_controller.dart';
import 'gallery_fav_controller.dart';
import 'gallery_page_state.dart';
import 'taginfo_controller.dart';
import 'torrent_controller.dart';

const double kHeaderHeightOffset = kHeaderHeight + 52.0;

typedef ImageCallback = GalleryImage Function(GalleryImage image);

class GalleryPageController extends GetxController
    with StateMixin<GalleryProvider> {
  GalleryPageController();

  late final GalleryPageState gState;

  // 滚动控制器
  ScrollController? scrollController;

  // eh设置
  final EhSettingService _ehSettingService = Get.find();
  final HistoryController _historyController = Get.find();
  final GalleryCacheController _galleryCacheController = Get.find();
  DownloadController get _downloadController => Get.find();
  final CacheController _cacheController = Get.find();

  final imageLoadLock = Lock();

  @override
  void onInit() {
    super.onInit();

    logger.t('GalleryPageController $pageCtrlTag onInit');

    final tag = pageCtrlTag;
    logger.d('>>>> get GalleryRepository tag $tag');
    final galleryRepository = Get.find<GalleryRepository>(tag: tag);
    bool isStateFromCache = false;

    if (galleryRepository.url != null && galleryRepository.url!.isNotEmpty) {
      // url跳转
      // 解析gid等信息
      final RegExp urlRex =
          RegExp(r'(http?s://e[-x]hentai.org)?/g/(\d+)/(\w+)/?$');
      final RegExpMatch? urlRult =
          urlRex.firstMatch(galleryRepository.url ?? '');
      final String gid = urlRult?.group(2) ?? '';
      final String token = urlRult?.group(3) ?? '';

      if (!_loadDataFromCache(
        gid,
        isStateFromCacheChange: (val) => isStateFromCache = val,
      )) {
        gState = GalleryPageState();
        gState.fromUrl = true;
        gState.galleryProvider =
            GalleryProvider(url: galleryRepository.url, gid: gid, token: token);
      }
    } else {
      if (!_loadDataFromCache(
        galleryRepository.item?.gid ?? '',
        isStateFromCacheChange: (val) => isStateFromCache = val,
      )) {
        gState = GalleryPageState();
        gState.galleryProvider = galleryRepository.item!;
      }
    }

    gState.hideNavigationBtn = true;

    if (!isStateFromCache) {
      logger.t('state new load');
      gState.galleryRepository = galleryRepository;
      _loadData();

      // 初始
      _galleryCacheController
          .listenGalleryCache(gState.galleryProvider?.gid ?? '')
          .listen((_galleryCache) =>
              gState.lastIndex = _galleryCache?.lastIndex ?? 0);
    }
  }

  // @override
  // void onReady() {
  //   super.onReady();
  //   scrollController = PrimaryScrollController.of(Get.context!)!;
  //   scrollController.addListener(scrollControllerLister);
  // }

  @override
  void onClose() {
    scrollController?.dispose();
    logger.t('onClose GalleryPageController $pageCtrlTag');
    super.onClose();
    // _galleryCacheController.addGalleryPageState(gState);
  }

  void _analytics(GalleryProvider? item) {}

  Future<void> _loadData({bool refresh = false, bool showError = true}) async {
    try {
      final GalleryProvider? _fetchItem = await _fetchData(refresh: refresh);
      logger.t('fetch end postTime ${_fetchItem?.postTime}');
      change(_fetchItem, status: RxStatus.success());
      _analytics(_fetchItem);
      time.showTime('change end');

      gState.enableRead = true;

      // 跳转提示dialog
      if (gState.galleryRepository?.jumpSer != null) {
        startReadDialog(gState.galleryRepository!.jumpSer!);
      }
    } catch (err, stack) {
      logger.e('$err\n$stack');
      String errMsg = err.toString();
      if (err is EhError) {
        errMsg = err.message;
      }
      if (showError) {
        change(null, status: RxStatus.error(errMsg));
      }
    }
  }

  /// 请求数据
  Future<GalleryProvider?> _fetchData({bool refresh = false}) async {
    try {
      gState.hideNavigationBtn = true;

      if (gState.galleryProvider != null &&
          (gState.galleryProvider?.filecount == null ||
              (gState.galleryProvider?.filecount?.isEmpty ?? true))) {
        gState.galleryProvider = await Api.getMoreGalleryInfoOne(
            gState.galleryProvider!,
            refresh: refresh);

        logger.t('fetch end postTime ${gState.galleryProvider?.postTime}');
      }

      // 检查画廊是否包含在本地收藏中
      final bool _localFav = _isInLocalFav(gState.galleryProvider?.gid ?? '0');
      gState.galleryProvider =
          gState.galleryProvider?.copyWith(localFav: _localFav.oN);

      final String? _oriColorRating = gState.galleryProvider?.colorRating;
      final String? _oriRatingCount = gState.galleryProvider?.ratingCount;
      final double? _oriRatingFallBack = gState.galleryProvider?.ratingFallBack;
      final bool? _oriIsRatinged = gState.galleryProvider?.isRatinged;

      time.showTime('start get galleryProvider');

      late final GalleryProvider? fetchedGalleryProvider;
      // 从内存缓存中加载
      final providerCache = _galleryCacheController
          .getGalleryProviderCache(gState.galleryProvider?.gid);

      if (!refresh && providerCache != null) {
        fetchedGalleryProvider = providerCache;
      } else {
        // 网络请求画廊数据
        fetchedGalleryProvider = await getGalleryDetail(
          url: gState.galleryProvider?.url ?? '',
          refresh: refresh,
        );

        logger.t('^^ postTime ${fetchedGalleryProvider?.postTime}');

        _galleryCacheController.setGalleryProviderCache(
            gState.galleryProvider?.gid, fetchedGalleryProvider);
        await 200.milliseconds.delay();
      }

      time.showTime('fetch galleryProvider end');

      if (fetchedGalleryProvider != null) {
        gState.galleryProvider =
            gState.galleryProvider?.copyWithAll(fetchedGalleryProvider);
      }

      gState.currentImagePage = 0;
      setImageAfterRequest(gState.galleryProvider?.galleryImages);

      // 评论
      gState.comments(gState.galleryProvider?.galleryComment);

      try {
        if (!refresh) {
          // 如果不是refresh情况。 收藏状态 评分状态从Provider中继承
          gState.galleryProvider = gState.galleryProvider?.copyWith(
            ratingFallBack:
                (gState.galleryProvider?.ratingFallBack ?? _oriRatingFallBack)
                    ?.oN,
            ratingCount:
                (gState.galleryProvider?.ratingCount ?? _oriRatingCount)?.oN,
            colorRating: _oriColorRating?.oN,
            // isRatinged: _oriIsRatinged,
          );

          // 收藏控制器状态更新
          final GalleryFavController _favController =
              Get.find(tag: pageCtrlTag);
          _favController.setFav(gState.galleryProvider?.favcat ?? '',
              gState.galleryProvider?.favTitle ?? '');
        }
      } catch (_) {}

      // 评分状态更新
      gState.isRatinged = gState.galleryProvider?.isRatinged ?? false;

      gState.galleryProvider = gState.galleryProvider?.copyWith(
        imgUrl:
            (gState.galleryProvider?.imgUrl ?? gState.galleryProvider?.imgUrlL)
                ?.oN,
      );

      // 加入历史
      final _galleryProvider = gState.galleryProvider;
      if (_galleryProvider != null && _galleryProvider.gid != null) {
        Future<void>.delayed(const Duration(milliseconds: 5000)).then((_) {
          _historyController.addHistory(_galleryProvider);
        });
      }

      update([GetIds.PAGE_VIEW_HEADER]);
      gState.itemController?.update([gState.gid]);
      return gState.galleryProvider;
    } on HttpException catch (e) {
      throw EhError(error: e.message);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        logger.e('data: ${e.response?.data}');
        final errMsg = parseErrGallery('${e.response?.data ?? ''}');
        logger.e('errMsg: $errMsg');
        throw EhError(error: errMsg);
      }
      rethrow;
    } catch (e, stack) {
      logger.e('解析数据异常\n' + e.toString() + '\n' + stack.toString());
      throw EhError(error: 'Parsing data error');
    }
  }

  bool _loadDataFromCache(
    String gid, {
    ValueChanged<bool>? isStateFromCacheChange,
  }) {
    final stateFromCache = _galleryCacheController.getGalleryPageState(gid);
    if (stateFromCache != null) {
      gState = stateFromCache;
      isStateFromCacheChange?.call(true);
      change(gState.galleryProvider, status: RxStatus.success());
      _analytics(gState.galleryProvider);

      // 加入历史
      final _galleryProvider = gState.galleryProvider;
      if (_galleryProvider != null && _galleryProvider.gid != null) {
        Future<void>.delayed(const Duration(milliseconds: 5000)).then((_) {
          _historyController.addHistory(_galleryProvider);
        });
      }
      return true;
    } else {
      return false;
    }
  }

  // 评分后更新ui和数据
  void afterRating({
    required double ratingUsr,
    required double ratingAvg,
    required int ratingCnt,
    required String colorRating,
  }) {
    gState.isRatinged = true;

    gState.galleryProvider = gState.galleryProvider?.copyWith(
      isRatinged: true.oN,
      ratingFallBack: ratingUsr.oN,
      rating: ratingAvg.oN,
      ratingCount: ratingCnt.toString().oN,
      colorRating: colorRating.oN,
    );

    // gState.itemController?.galleryProvider = gState.galleryProvider!;

    // logger.d('update GetIds.PAGE_VIEW_HEADER');
    update([GetIds.PAGE_VIEW_HEADER]);
    gState.itemController?.ratingFallBack =
        gState.galleryProvider?.ratingFallBack ?? 0.0;

    gState.itemController?.rating = gState.galleryProvider?.rating ?? 0.0;

    gState.itemController?.colorRating =
        gState.galleryProvider?.colorRating ?? '';

    gState.itemController?.update();
  }

  GalleryImage? uptImageBySer({
    required int ser,
    required ImageCallback imageCallback,
  }) {
    final int? _index =
        gState.images.indexWhere((GalleryImage element) => element.ser == ser);
    if (_index != null && _index >= 0) {
      final image = imageCallback(gState.images[_index]);

      // update showKey
      if (image.showKey != null &&
          image.showKey != gState.galleryProvider?.showKey) {
        logger.d('update showKey ${image.showKey}');
        gState.galleryProvider = gState.galleryProvider?.copyWith(
          showKey: image.showKey?.oN,
        );
      }

      gState.images[_index] = image;
      return image;
    }
    return null;
  }

  void setImageAfterRequest(List<GalleryImage>? images) {
    // 进行请求后图片对象存放
    if (images?.isNotEmpty ?? false) {
      gState.images(images);
    }

    // 存放第一页的图片对象
    gState.firstPageImage =
        gState.galleryProvider?.galleryImages?.sublist(0, images?.length) ?? [];
  }

  /// 添加缩略图对象
  void addAllImages(List<GalleryImage> galleryImages) {
    for (final GalleryImage _image in galleryImages) {
      final int index =
          gState.images.indexWhere((GalleryImage e) => e.ser == _image.ser);
      if (index != -1) {
        gState.images[index] = _image;
      } else {
        gState.images.add(_image);
      }
    }
  }

  Future<void> startReadDialog(int ser) async {
    await showCupertinoDialog<void>(
      context: Get.overlayContext!,
      barrierDismissible: true,
      builder: (context) {
        return CupertinoAlertDialog(
          // title: Text(L10n.of(context).jump_to_page),
          title: Text('${L10n.of(context).jump_to_page} $ser?'),
          // title: Text('Start reading on page $ser ?'),
          actions: [
            CupertinoDialogAction(
              child: Text(L10n.of(Get.context!).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                L10n.of(Get.context!).ok,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                Get.back();
                NavigatorUtil.goGalleryViewPage(ser - 1, gState.gid);
              },
            ),
          ],
        );
      },
    );
  }

  // 刷新重载
  Future<void> _reloadData() async {
    gState.isRefresh = true;
    try {
      Get.find<TorrentController>(tag: pageCtrlTag).isRefresh = true;
    } catch (e) {
      logger.e('$e');
    }
    await _loadData(refresh: true, showError: false);
  }

  Future<void> handOnRefresh() async {
    await _reloadData();
  }

  Future<void> handOnRefreshAfterErr() async {
    change(null, status: RxStatus.loading());
    _fetchData(refresh: true).then((GalleryProvider? value) {
      gState.enableRead = true;
      change(value, status: RxStatus.success());
    });
  }

  bool _isInLocalFav(String gid) {
    // 检查是否包含在本地收藏中
    final int index = Get.find<LocalFavController>()
        .loacalFavs
        .indexWhere((GalleryProvider element) {
      return element.gid == gid;
    });
    return index >= 0;
  }

  // 滚动控制器监听
  void scrollControllerLister() {
    if (scrollController == null) {
      return;
    }
    // logger.d('${scrollController?.offset}');
    try {
      if (scrollController!.offset < kHeaderHeightOffset + kHeaderPaddingTop &&
          !gState.hideNavigationBtn) {
        gState.hideNavigationBtn = true;
      } else if (scrollController!.offset >=
              kHeaderHeightOffset + kHeaderPaddingTop &&
          gState.hideNavigationBtn) {
        gState.hideNavigationBtn = false;
      }
    } catch (e, stack) {
      logger.e('$e, $stack');
    }
  }

  /// 拉取直到index的缩略图信息
  Future<void> showDialogFetchImageUntilIndex(
      BuildContext context, int index) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        Future<void>.delayed(const Duration(milliseconds: 0))
            .then((_) => loadPriviewUntilIndex(index))
            .whenComplete(() => Get.back());

        return Center(
          child: CupertinoPopupSurface(
            child: Container(
                height: 80,
                width: 80,
                alignment: Alignment.center,
                child: const CupertinoActivityIndicator(
                  radius: 20,
                )),
          ),
        );
      },
    );
  }

  /// 加载下一页缩略图
  Future<void> _loadMordPreview({CancelToken? cancelToken}) async {
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 0));

    logger.d(
        '获取更多预览 ${gState.galleryProvider?.url} : ${gState.currentImagePage}');

    final List<GalleryImage> _moreGalleryImageList = await getGalleryImageList(
      gState.galleryProvider?.url ?? '',
      page: gState.currentImagePage + 1,
      cancelToken: cancelToken,
      refresh: gState.isRefresh,
    );

    gState.currentImagePage++;
    addAllImages(_moreGalleryImageList);
    if (Get.isRegistered<AllThumbnailsPageController>()) {
      Get.find<AllThumbnailsPageController>().update();
    }
  }

  /// 直接请求目的index所在的缩略图页
  Future<void> loadImagesForSer(int ser, {CancelToken? cancelToken}) async {
    // TODO(w): 优化重复触发

    //  计算index所在的页码
    final int flen = gState.firstPageImage.length;
    if (gState.filecount <= flen) {
      return;
    }

    final int page = (ser - 1) ~/ flen;
    logger.d('ser:$ser 所在页码为$page');

    gState.mapLoadImagesForSer.putIfAbsent(
        page,
        () => getGalleryImageList(
              gState.galleryProvider?.url ?? '',
              page: page,
              cancelToken: cancelToken,
              refresh: gState.isRefresh, // 刷新画廊后加载缩略图不能从缓存读取，否则在改变每页数量后加载画廊会出错
            ));

    final List<GalleryImage>? _moreImageList = await imageLoadLock
        .synchronized(() async => await gState.mapLoadImagesForSer[page]);

    if (_moreImageList != null) {
      addAllImages(_moreImageList);
    }
    if (Get.isRegistered<AllThumbnailsPageController>()) {
      Get.find<AllThumbnailsPageController>().update();
    }
    gState.mapLoadImagesForSer.remove(page);
  }

  // 按顺序翻页加载缩略图对象
  Future<bool> loadPriviewUntilIndex(int index) async {
    final List<GalleryImage>? _galleryImageList =
        gState.galleryProvider?.galleryImages;

    if (_galleryImageList == null) {
      return true;
    }

    while (index > _galleryImageList.length - 1) {
      logger.d(' index = $index ; len = ${_galleryImageList.length}');
      await _loadMordPreview();
    }
    return true;
  }

  /// 获取当前页的图片信息
  Future<GalleryImage?> fetchAndParserImageInfo(
    int itemSer, {
    CancelToken? cancelToken,
    bool changeSource = false,
    bool refresh = false,
  }) async {
    logger.t('fetchAndParserImageInfo $itemSer');
    try {
      /// 当前缩略图对象
      final GalleryImage? _curImages = gState.imageMap[itemSer];

      if (_curImages == null) {
        return null;
      }

      final String? _largeImageUrl = _curImages.imageUrl;

      // 大图url为空或者宽高信息为空的时候 都会解析获取
      if (_largeImageUrl != null &&
          _largeImageUrl.isNotEmpty &&
          _curImages.imageHeight != null &&
          _curImages.imageWidth != null) {
        return gState.imageMap[itemSer];
      } else {
        final String? _sourceId =
            changeSource ? gState.imageMap[itemSer]?.sourceId : '';

        final _showKey = gState.galleryProvider?.showKey;

        logger.t(
            'ser:$itemSer ,href: ${gState.imageMap[itemSer]?.href} , _sourceId: $_sourceId');

        try {
          if (changeSource) {
            logger.d('itemSer$itemSer 换源加载 start');
            // 删除旧缓存
            _cacheController.clearDioCache(
                path: gState.imageMap[itemSer]?.href ?? '');
          }

          // 请求当前页信息
          final GalleryImage? _image = await fetchImageInfoByApi(
            gState.imageMap[itemSer]?.href ?? '',
            sourceId: _sourceId,
            refresh: changeSource || refresh,
            showKey: _showKey,
          );

          logger.t('fetch _image ${_image?.toJson()}');

          if (_image?.showKey != null && _image?.showKey != _showKey) {
            logger.t('update showKey ${_image?.showKey}');
            gState.galleryProvider = gState.galleryProvider?.copyWith(
              showKey: _image?.showKey?.oN,
            );
          }

          // 换源加载
          if (changeSource) {
            logger.d('itemSer$itemSer 换源加载 ${_image?.imageUrl}');
          }

          if (_image == null) {
            return _curImages;
          }

          final __image = _curImages.copyWith(
            sourceId: _image.sourceId.oN,
            imageUrl: _image.imageUrl.oN,
            imageWidth: _image.imageWidth.oN,
            imageHeight: _image.imageHeight.oN,
            originImageUrl: _image.originImageUrl.oN,
            filename: _image.filename.oN,
            changeSource: changeSource.oN,
            errorInfo: ''.oN,
            tempPath: ''.oN,
            completeCache: false.oN,
            showKey: _image.showKey.oN,
          );

          return uptImageBySer(ser: itemSer, imageCallback: (image) => __image);
        } catch (_) {
          rethrow;
        }
      }
    } catch (e, stack) {
      logger.e('fetchAndParserImageInfo error\n$e \n $stack');
      rethrow;
    }
  }

  void downloadGallery(BuildContext context) {
    switch (_ehSettingService.downloadOrigType) {
      case DownloadOrigImageType.no:
        _downloadGallery();
        break;
      case DownloadOrigImageType.always:
        _downloadGallery(downloadOri: true);
        break;
      case DownloadOrigImageType.askMe:
        showCupertinoDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(L10n.of(context).image_download_type),
                // content: Text(L10n.of(context).download_ori_image_summary),
                actions: [
                  CupertinoDialogAction(
                    child: Text(L10n.of(context).resample_image),
                    onPressed: () {
                      Get.back();
                      _downloadGallery();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(L10n.of(context).original_image),
                    onPressed: () {
                      Get.back();
                      _downloadGallery(downloadOri: true);
                    },
                  ),
                ],
              );
            });
        break;
    }
  }

  void _downloadGallery({bool downloadOri = false}) {
    _downloadController.downloadGallery(
      gid: int.parse(gState.gid),
      token: gState.galleryProvider?.token,
      url: gState.galleryProvider?.url ?? '',
      fileCount: int.parse(gState.galleryProvider?.filecount ?? '0'),
      title: gState.mainTitle,
      coverUrl: gState.galleryProvider?.imgUrl,
      rating: gState.galleryProvider?.rating,
      uploader: gState.galleryProvider?.uploader,
      category: gState.galleryProvider?.category,
      downloadOri: downloadOri,
      showKey: gState.galleryProvider?.showKey,
    );
  }

  Future<void> addTag() async {
    final dynamic _rult = await Get.toNamed(
      EHRoutes.addTag,
      id: isLayoutLarge ? 2 : null,
    );
    if (_rult != null && _rult is String) {
      logger.t('addTag $_rult');
      final TagInfoController? controller =
          Get.put(TagInfoController(), tag: pageCtrlTag);
      controller?.tagVoteUp(_rult);
    }
  }
}
