import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/cache_controller.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/parser/eh_parser.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/app_dio/pdio.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'all_previews_controller.dart';
import 'comment_controller.dart';
import 'gallery_fav_controller.dart';
import 'gallery_page_state.dart';
import 'taginfo_controller.dart';
import 'torrent_controller.dart';

const double kHeaderHeightOffset = kHeaderHeight;

class GalleryPageController extends GetxController
    with StateMixin<GalleryItem> {
  GalleryPageController();

  late final GalleryPageState gState;

  // 滚动控制器
  late ScrollController scrollController;

  // eh设置
  final EhConfigService _ehConfigService = Get.find();
  final HistoryController _historyController = Get.find();
  final GalleryCacheController _galleryCacheController = Get.find();
  DownloadController get _downloadController => Get.find();
  final CacheController _cacheController = Get.find();

  @override
  void onInit() {
    super.onInit();

    logger.v('GalleryPageController $pageCtrlTag onInit');

    final galleryRepository = Get.find<GalleryRepository>();
    bool isStateFromCache = false;

    if (galleryRepository.url != null && galleryRepository.url!.isNotEmpty) {
      // url跳转

      // 解析gid等信息
      final RegExp urlRex =
          RegExp(r'(http?s://e(-|x)hentai.org)?/g/(\d+)/(\w+)/?$');
      final RegExpMatch? urlRult =
          urlRex.firstMatch(galleryRepository.url ?? '');
      final String gid = urlRult?.group(3) ?? '';
      final String token = urlRult?.group(4) ?? '';

      final stateFromCache = _galleryCacheController.getGalleryPageState(gid);
      if (stateFromCache != null) {
        gState = stateFromCache;
        isStateFromCache = true;
        change(gState.galleryItem, status: RxStatus.success());
      } else {
        gState = GalleryPageState();
        gState.fromUrl = true;
        gState.galleryItem =
            GalleryItem(url: galleryRepository.url, gid: gid, token: token);
      }
    } else {
      final stateFromCache = _galleryCacheController
          .getGalleryPageState(galleryRepository.item!.gid ?? '');
      if (stateFromCache != null) {
        gState = stateFromCache;
        isStateFromCache = true;
        change(gState.galleryItem, status: RxStatus.success());
      } else {
        gState = GalleryPageState();
        gState.galleryItem = galleryRepository.item!;
      }
    }

    gState.hideNavigationBtn = true;

    if (!isStateFromCache) {
      logger.d('new load');
      gState.galleryRepository = galleryRepository;
      _loadData();

      // 初始
      _galleryCacheController
          .getGalleryCache(gState.galleryItem?.gid ?? '')
          .then((_galleryCache) =>
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
    scrollController.dispose();
    logger.v('onClose GalleryPageController $pageCtrlTag');
    _galleryCacheController.addGalleryPageState(gState);
    super.onClose();
  }

  // 评分后更新ui和数据
  void ratinged({
    required double ratingUsr,
    required double ratingAvg,
    required int ratingCnt,
    required String colorRating,
  }) {
    gState.isRatinged = true;

    gState.galleryItem = gState.galleryItem?.copyWith(
      isRatinged: true,
      ratingFallBack: ratingUsr,
      rating: ratingAvg,
      ratingCount: ratingCnt.toString(),
      colorRating: colorRating,
    );

    logger.d('update GetIds.PAGE_VIEW_HEADER');
    update([GetIds.PAGE_VIEW_HEADER]);

    gState.itemController?.update();
  }

  void uptImageBySer({required int ser, required GalleryImage image}) {
    final int? _index = gState.galleryItem?.galleryImages
        ?.indexWhere((GalleryImage element) => element.ser == ser);
    if (_index != null && _index >= 0) {
      gState.galleryItem?.galleryImages?[_index] = image;
    }
  }

  void setImageAfterRequest(List<GalleryImage>? images) {
    if (images?.isNotEmpty ?? false) {
      gState.galleryItem = gState.galleryItem?.copyWith(galleryImages: images);
    }

    gState.firstPageImage =
        gState.galleryItem?.galleryImages?.sublist(0, images?.length) ?? [];
  }

  /// 添加缩略图对象
  void addAllImages(List<GalleryImage> galleryImages) {
    logger5.v(
        'addAllPreview ${galleryImages.first.ser}~${galleryImages.last.ser} ');

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

  /// 请求数据
  Future<GalleryItem?> _fetchData({bool refresh = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      gState.hideNavigationBtn = true;

      if (gState.galleryItem != null &&
          (gState.galleryItem?.filecount == null ||
              (gState.galleryItem?.filecount?.isEmpty ?? true))) {
        gState.galleryItem = await Api.getMoreGalleryInfoOne(
            gState.galleryItem!,
            refresh: refresh);
      }

      // 检查画廊是否包含在本地收藏中
      final bool _localFav = _isInLocalFav(gState.galleryItem?.gid ?? '0');
      gState.galleryItem = gState.galleryItem?.copyWith(localFav: _localFav);

      final String? _oriColorRating = gState.galleryItem?.colorRating;
      final String? _oriRatingCount = gState.galleryItem?.ratingCount;
      final double? _oriRatingFallBack = gState.galleryItem?.ratingFallBack;
      final bool? _oriIsRatinged = gState.galleryItem?.isRatinged;

      time.showTime('start get galleryItem');
      final fetchedGalleryItem = await getGalleryDetail(
        url: gState.galleryItem?.url ?? '',
        refresh: refresh,
      );
      time.showTime('fetch galleryItem end');

      if (fetchedGalleryItem != null) {
        gState.galleryItem =
            gState.galleryItem?.copyWithAll(fetchedGalleryItem);
      }

      gState.currentImagePage = 0;
      setImageAfterRequest(gState.galleryItem?.galleryImages);

      try {
        // 页面内刷新时的处理
        if (refresh) {
          // 评论控制器状态数据更新
          Get.find<CommentController>(tag: pageCtrlTag)
              .change(gState.galleryItem?.galleryComment);
          // 评分状态更新
          gState.isRatinged = gState.galleryItem?.isRatinged ?? false;
        } else {
          gState.galleryItem = gState.galleryItem?.copyWith(
            ratingFallBack:
                gState.galleryItem?.ratingFallBack ?? _oriRatingFallBack,
            ratingCount: gState.galleryItem?.ratingCount ?? _oriRatingCount,
            colorRating: _oriColorRating,
            // isRatinged: _oriIsRatinged,
          );

          // 评分状态更新
          gState.isRatinged = gState.galleryItem?.isRatinged ?? false;

          // 收藏控制器状态更新
          final GalleryFavController _favController =
              Get.find(tag: pageCtrlTag);
          _favController.setFav(gState.galleryItem?.favcat ?? '',
              gState.galleryItem?.favTitle ?? '');
        }
      } catch (_) {}

      gState.galleryItem = gState.galleryItem?.copyWith(
          imgUrl: gState.galleryItem?.imgUrl ?? gState.galleryItem?.imgUrlL);

      // 加入历史
      if (gState.galleryItem != null && gState.galleryItem?.gid != null) {
        Future<void>.delayed(const Duration(milliseconds: 700)).then((_) {
          _historyController.addHistory(gState.galleryItem!);
        });
      }

      update([GetIds.PAGE_VIEW_HEADER]);
      gState.itemController?.update([gState.gid]);
      return gState.galleryItem;
    } on HttpException catch (e) {
      throw EhError(error: e.message);
    } on DioError catch (e) {
      if (e.type == DioErrorType.response && e.response?.statusCode == 404) {
        logger.e('data: ${e.response?.data}');
        final errMsg = parseErrGallery('${e.response?.data ?? ''}');
        logger.d('errMsg: $errMsg');
        // showToast('This gallery has been removed or is unavailable.');
        // rethrow;
        throw EhError(error: errMsg);
      }
      rethrow;
    } catch (e, stack) {
      // showToast('Parsing data error');
      logger.e('解析数据异常\n' + e.toString() + '\n' + stack.toString());
      // rethrow;
      throw EhError(error: 'Parsing data error');
    }
  }

  Future<void> _loadData({bool refresh = false, bool showError = true}) async {
    try {
      final GalleryItem? _fetchItem = await _fetchData(refresh: refresh);
      change(_fetchItem, status: RxStatus.success());
      time.showTime('change end');

      gState.enableRead = true;

      // 跳转提示dialog
      if (gState.galleryRepository?.jumpSer != null) {
        startReadDialog(gState.galleryRepository!.jumpSer!);
      }

      analytics.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: gState.galleryItem?.gid ?? '',
            itemName: gState.galleryItem?.englishTitle ?? '',
            itemCategory: gState.galleryItem?.category ?? '',
            creativeName: gState.galleryItem?.japaneseTitle,
          )
        ],
      );
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

  Future<void> startReadDialog(int ser) async {
    await showCupertinoDialog<void>(
      context: Get.overlayContext!,
      barrierDismissible: true,
      builder: (context) {
        return CupertinoAlertDialog(
          // title: Text(L10n.of(context).jump_to_page),
          // title: Text('${L10n.of(context).jump_to_page} $ser?'),
          title: Text('Start reading on page $ser ?'),
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
    _fetchData(refresh: true).then((GalleryItem? value) {
      gState.enableRead = true;
      change(value, status: RxStatus.success());
    });
  }

  bool _isInLocalFav(String gid) {
    // 检查是否包含在本地收藏中
    final int index = Get.find<LocalFavController>()
        .loacalFavs
        .indexWhere((GalleryItem element) {
      return element.gid == gid;
    });
    return index >= 0;
  }

  void scrollControllerLister() {
    if (scrollController == null) {
      return;
    }
    try {
      if (scrollController.offset < kHeaderHeightOffset + kHeaderPaddingTop &&
          !gState.hideNavigationBtn) {
        gState.hideNavigationBtn = true;
      } else if (scrollController.offset >=
              kHeaderHeightOffset + kHeaderPaddingTop &&
          gState.hideNavigationBtn) {
        gState.hideNavigationBtn = false;
      }
    } catch (_) {}
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
  Future<void> _loarMordPriview({CancelToken? cancelToken}) async {
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 0));

    logger.v('获取更多预览 ${gState.galleryItem?.url} : ${gState.currentImagePage}');

    final List<GalleryImage> _moreGalleryImageList = await getGalleryImage(
      gState.galleryItem?.url ?? '',
      page: gState.currentImagePage + 1,
      cancelToken: cancelToken,
      refresh: gState.isRefresh,
    );

    gState.currentImagePage++;
    addAllImages(_moreGalleryImageList);
    if (Get.isRegistered<AllPreviewsPageController>()) {
      Get.find<AllPreviewsPageController>().update();
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
        () => getGalleryImage(
              gState.galleryItem?.url ?? '',
              page: page,
              cancelToken: cancelToken,
              refresh: gState.isRefresh, // 刷新画廊后加载缩略图不能从缓存读取，否则在改变每页数量后加载画廊会出错
            ));

    final List<GalleryImage> _moreImageList =
        await gState.mapLoadImagesForSer[page]!;

    addAllImages(_moreImageList);
    if (Get.isRegistered<AllPreviewsPageController>()) {
      Get.find<AllPreviewsPageController>().update();
    }
    gState.mapLoadImagesForSer.remove(page);
  }

  // 按顺序翻页加载缩略图对象
  Future<bool> loadPriviewUntilIndex(int index) async {
    final List<GalleryImage>? _galleryImageList =
        gState.galleryItem?.galleryImages;

    if (_galleryImageList == null) {
      return true;
    }

    while (index > _galleryImageList.length - 1) {
      logger.d(' index = $index ; len = ${_galleryImageList.length}');
      await _loarMordPriview();
    }
    return true;
  }

  /// 获取当前页的图片信息
  Future<GalleryImage?> fetchAndParserImageInfo(
    int itemSer, {
    CancelToken? cancelToken,
    // bool refresh = false,
    bool changeSource = false,
  }) async {
    try {
      /// 当前缩略图对象
      final GalleryImage? _curImages = gState.galleryItem?.imageMap[itemSer];

      if (_curImages == null) {
        return null;
      }

      final String? _largeImageUrl = _curImages.imageUrl;

      // 大图url为空或者宽高信息为空的时候 都会解析获取
      if (_largeImageUrl != null &&
          _largeImageUrl.isNotEmpty &&
          _curImages.imageHeight != null &&
          _curImages.imageWidth != null) {
        return gState.galleryItem?.imageMap[itemSer];
      } else {
        final String? _sourceId =
            changeSource ? gState.galleryItem?.imageMap[itemSer]?.sourceId : '';

        logger.d(
            'ser:$itemSer ,href: ${gState.galleryItem?.imageMap[itemSer]?.href} , _sourceId: $_sourceId');

        try {
          if (changeSource) {
            // 删除旧缓存
            _cacheController.clearDioCache(
                path: gState.galleryItem?.imageMap[itemSer]?.href ?? '');
          }

          // 加载当前页信息
          final GalleryImage? _image = await fetchImageInfo(
            gState.galleryItem?.imageMap[itemSer]?.href ?? '',
            sourceId: _sourceId,
          );

          logger.v('fetch _image ${_image?.toJson()}');

          // 换源加载
          if (changeSource) {
            logger5.d('itemSer$itemSer 换源加载 ${_image?.imageUrl}');
          }

          if (_image == null) {
            return _curImages;
          }

          final GalleryImage _imageCopyWith = _curImages.copyWith(
            sourceId: _image.sourceId,
            imageUrl: _image.imageUrl,
            imageWidth: _image.imageWidth,
            imageHeight: _image.imageHeight,
            originImageUrl: _image.originImageUrl,
          );

          logger.v('_imageCopyWith ${_imageCopyWith.toJson()}');

          uptImageBySer(ser: itemSer, image: _imageCopyWith);
          return _imageCopyWith;
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
    switch (_ehConfigService.downloadOrigType) {
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
      token: gState.galleryItem?.token,
      url: gState.galleryItem?.url ?? '',
      fileCount: int.parse(gState.galleryItem?.filecount ?? '0'),
      title: gState.title,
      coverUrl: gState.galleryItem?.imgUrl,
      rating: gState.galleryItem?.rating,
      uploader: gState.galleryItem?.uploader,
      category: gState.galleryItem?.category,
      downloadOri: downloadOri,
    );
  }

  Future<void> addTag() async {
    final dynamic _rult = await Get.toNamed(
      EHRoutes.addTag,
      id: isLayoutLarge ? 2 : null,
    );
    if (_rult != null && _rult is String) {
      logger.v('addTag $_rult');
      final TagInfoController? controller =
          Get.put(TagInfoController(), tag: pageCtrlTag);
      controller?.tagVoteUp(_rult);
    }
  }
}
