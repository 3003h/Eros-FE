import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:fehviewer/pages/gallery/controller/torrent_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/time.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'all_previews_controller.dart';
import 'comment_controller.dart';
import 'gallery_fav_controller.dart';

const double kHeaderHeightOffset = kHeaderHeight;

class GalleryPageController extends GetxController
    with StateMixin<GalleryItem> {
  GalleryPageController({this.galleryRepository});

  final GalleryRepository? galleryRepository;

  /// 画廊数据对象
  late GalleryItem _galleryItem;

  GalleryItem get galleryItem => _galleryItem;

  set galleryItem(GalleryItem val) {
    _galleryItem = val;
  }

  // void initItem(GalleryItem val) {
  //   _galleryItem = val;
  // }

  /// 画廊gid 唯一
  String get gid => galleryItem.gid ?? '';

  bool isRefresh = false;

  final RxBool _fromUrl = false.obs;

  bool get fromUrl => _fromUrl.value;

  set fromUrl(bool val) => _fromUrl.value = val;

  final RxBool _isRatinged = false.obs;

  bool get isRatinged => _isRatinged.value;

  set isRatinged(bool val) => _isRatinged.value = val;

  final RxInt _lastIndex = 0.obs;

  int get lastIndex => _lastIndex.value;

  set lastIndex(int val) => _lastIndex.value = val;

  // 评分后更新ui和数据
  void ratinged({
    required double ratingUsr,
    required double ratingAvg,
    required int ratingCnt,
    required String colorRating,
  }) {
    isRatinged = true;

    galleryItem = galleryItem.copyWith(
      isRatinged: true,
      ratingFallBack: ratingUsr,
      rating: ratingAvg,
      ratingCount: ratingCnt.toString(),
      colorRating: colorRating,
    );

    logger.d('update GetIds.PAGE_VIEW_HEADER');
    update([GetIds.PAGE_VIEW_HEADER]);

    _itemController?.update();
  }

  GalleryItemController? get _itemController {
    try {
      return Get.find(tag: gid);
    } catch (_) {
      return null;
    }
  }

  List<GalleryImage> get images => galleryItem.galleryImages ?? [];

  Map<int, GalleryImage> get imageMap => galleryItem.imageMap;

  int get filecount => int.parse(galleryItem.filecount ?? '0');

  List<GalleryImage> get imagesFromMap {
    List<MapEntry<int, GalleryImage>> list = imageMap.entries
        .map((MapEntry<int, GalleryImage> e) => MapEntry(e.key, e.value))
        .toList();
    // logger5.d('imagesFromMap len ${list.length}');
    list.sort((a, b) => a.key.compareTo(b.key));

    return list.map((e) => e.value).toList();
  }

  void uptImageBySer({required int ser, required GalleryImage image}) {
    final int? _index = galleryItem.galleryImages
        ?.indexWhere((GalleryImage element) => element.ser == ser);
    if (_index != null && _index >= 0) {
      galleryItem.galleryImages?[_index] = image;
    }
  }

  // final Map<int, int> errCountMap = {};

  String get showKey => galleryItem.showKey ?? '';

  /// 当前缩略图页码
  late int currentImagePage;

  // 正在获取href
  bool isImageInfoGeting = false;

  // 滚动控制器
  final ScrollController scrollController = ScrollController();

  // eh设置
  final EhConfigService _ehConfigService = Get.find();
  final HistoryController _historyController = Get.find();
  final GalleryCacheController _galleryCacheController = Get.find();

  @override
  void onInit() {
    super.onInit();

    logger.v('GalleryPageController $pageCtrlDepth onInit');

    scrollController.addListener(_scrollControllerLister);
    hideNavigationBtn = true;

    if (galleryRepository != null &&
        galleryRepository!.url != null &&
        galleryRepository!.url!.isNotEmpty) {
      // url跳转
      fromUrl = true;

      final RegExp urlRex =
          RegExp(r'(http?s://e(-|x)hentai.org)?/g/(\d+)/(\w+)/?$');
      final RegExpMatch? urlRult =
          urlRex.firstMatch(galleryRepository!.url ?? '');
      final String gid = urlRult?.group(3) ?? '';
      final String token = urlRult?.group(4) ?? '';

      galleryItem =
          GalleryItem(url: galleryRepository!.url, gid: gid, token: token);
    } else {
      _galleryItem = galleryRepository!.item!;
    }

    _loadData();

    // 初始
    final GalleryCache? _galleryCache =
        _galleryCacheController.getGalleryCache(galleryItem.gid ?? '');
    lastIndex = _galleryCache?.lastIndex ?? 0;

    logger.v('GalleryPageController $pageCtrlDepth onInit end');
  }

  @override
  void onClose() {
    scrollController.dispose();

    logger.v('onClose GalleryPageController $pageCtrlDepth');

    // 如果不在onClose进行这步。在使用命名路由对 [EHRoutes.galleryPage] 跳转关闭后
    // 所有不同tag的 [CommentController] 等 都会被deleted
    // Get.find<DepthService>().popPageCtrl();
    super.onClose();
  }

  // 阅读按钮开关
  final RxBool _enableRead = false.obs;

  bool get enableRead => _enableRead.value;

  bool get hasMoreImage {
    return int.parse(galleryItem.filecount ?? '0') > (firstPageImage.length);
  }

  // 控制隐藏导航栏按钮和封面
  final RxBool _hideNavigationBtn = true.obs;

  bool get hideNavigationBtn => _hideNavigationBtn.value;

  set hideNavigationBtn(bool val) => _hideNavigationBtn.value = val;

  // 第一页的缩略图对象数组
  late List<GalleryImage> _firstPageImage;

  List<GalleryImage> get firstPageImage => _firstPageImage;

  void setImageAfterRequest(List<GalleryImage>? images) {
    if (images?.isNotEmpty ?? false) {
      // galleryItem.galleryPreview = galleryPreview;
      galleryItem = galleryItem.copyWith(galleryImages: images);
    }

    _firstPageImage = galleryItem.galleryImages!.sublist(0, images?.length);
  }

  /// 添加缩略图对象
  void addAllImages(List<GalleryImage> galleryImages) {
    logger5.v(
        'addAllPreview ${galleryImages.first.ser}~${galleryImages.last.ser} ');

    for (final GalleryImage _image in galleryImages) {
      final int index =
          images.indexWhere((GalleryImage e) => e.ser == _image.ser);
      if (index != -1) {
        images[index] = _image;
      } else {
        images.add(_image);
      }
    }
  }

  /// 是否存在本地收藏中
  set localFav(bool value) {
    // galleryItem.localFav = value;
    galleryItem = galleryItem.copyWith(localFav: value);
  }

  bool get localFav => galleryItem.localFav ?? false;

  /// 请求数据
  Future<GalleryItem> _fetchData({bool refresh = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      hideNavigationBtn = true;

      if (galleryItem.filecount == null ||
          (galleryItem.filecount?.isEmpty ?? true)) {
        galleryItem =
            await Api.getMoreGalleryInfoOne(galleryItem, refresh: refresh);
      }

      // logger.d('filecount ${galleryItem.filecount}');

      // 检查画廊是否包含在本地收藏中
      final bool _localFav = _isInLocalFav(galleryItem.gid ?? '');
      // galleryItem.localFav = _localFav;
      galleryItem = galleryItem.copyWith(localFav: _localFav);

      final String? _oriColorRating = galleryItem.colorRating;
      final String? _oriRatingCount = galleryItem.ratingCount;
      final double? _oriRatingFallBack = galleryItem.ratingFallBack;
      final bool? _oriIsRatinged = galleryItem.isRatinged;

      time.showTime('start get galleryItem');
      galleryItem = await Api.getGalleryDetail(
        inUrl: galleryItem.url!,
        inGalleryItem: galleryItem,
        refresh: refresh,
      );
      time.showTime('fetch galleryItem end');

      // logger.d('filecount ${galleryItem.filecount}');

      currentImagePage = 0;
      setImageAfterRequest(galleryItem.galleryImages);

      // logger.v('category ${galleryItem.category}');

      // logger.d('ratingCount ${galleryItem.ratingCount} ');

      try {
        // 页面内刷新时的处理
        if (refresh) {
          // 收藏控制器状态更新
          final GalleryFavController _favController =
              Get.find(tag: pageCtrlDepth);
          _favController.setFav(galleryItem.favcat!, galleryItem.favTitle!);

          // 评论控制器状态数据更新
          Get.find<CommentController>(tag: pageCtrlDepth)
              .change(galleryItem.galleryComment);

          // 评分状态更新
          isRatinged = galleryItem.isRatinged ?? false;
        } else {
          galleryItem = galleryItem.copyWith(
            ratingFallBack: galleryItem.ratingFallBack ?? _oriRatingFallBack,
            ratingCount: galleryItem.ratingCount ?? _oriRatingCount,
            colorRating: _oriColorRating,
            isRatinged: _oriIsRatinged,
          );
        }
      } catch (_) {}

      // galleryItem.imgUrl = galleryItem.imgUrl ?? galleryItem.imgUrlL;
      galleryItem = galleryItem.copyWith(
          imgUrl: galleryItem.imgUrl ?? galleryItem.imgUrlL);

      // 加入历史
      if (galleryItem.gid != null) {
        Future<void>.delayed(const Duration(milliseconds: 700)).then((_) {
          _historyController.addHistory(galleryItem);
        });
      }

      // logger.d('fb ${galleryItem.ratingFallBack} ');

      // logger.d('ratingCount ${galleryItem.ratingCount} ');

      // logger.d('update GetIds.PAGE_VIEW_HEADER');
      update([GetIds.PAGE_VIEW_HEADER]);
      _itemController?.update([gid]);
      return galleryItem;
    } on DioError catch (e) {
      if (e.type == DioErrorType.response && e.response?.statusCode == 404) {
        showToast('Gallery has been deleted');
        rethrow;
      }
      rethrow;
    } catch (e, stack) {
      showToast('Parsing data abnormal');
      logger.e('解析数据异常\n' + e.toString() + '\n' + stack.toString());
      rethrow;
    }
  }

  Future<void> _loadData({bool refresh = false, bool showError = true}) async {
    // logger.d('_firstLoadData');

    try {
      final GalleryItem _fetchItem = await _fetchData(refresh: refresh);
      change(_fetchItem, status: RxStatus.success());
      time.showTime('change end');

      _enableRead.value = true;

      // 跳转提示dialog
      if (galleryRepository?.jumpSer != null) {
        startReadDialog(galleryRepository!.jumpSer!);
      }

      analytics.logViewItem(
        itemId: galleryItem.gid ?? '',
        itemName: galleryItem.englishTitle ?? '',
        itemCategory: galleryItem.category ?? '',
        destination: galleryItem.japaneseTitle,
      );
    } catch (err, stack) {
      logger.e('$err\n$stack');
      if (showError) {
        change(null, status: RxStatus.error(err.toString()));
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
                NavigatorUtil.goGalleryViewPage(ser - 1, gid);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _reloadData() async {
    isRefresh = true;
    try {
      Get.find<TorrentController>(tag: pageCtrlDepth).isRefresh = true;
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
    _fetchData(refresh: true).then((GalleryItem value) {
      _enableRead.value = true;
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

  void _scrollControllerLister() {
    try {
      if (scrollController.offset < kHeaderHeightOffset + kHeaderPaddingTop &&
          !hideNavigationBtn) {
        hideNavigationBtn = true;
      } else if (scrollController.offset >=
              kHeaderHeightOffset + kHeaderPaddingTop &&
          hideNavigationBtn) {
        hideNavigationBtn = false;
      }
    } catch (_) {}
  }

  // 另一个语言的标题
  String get topTitle {
    // logger.d('${galleryItem.japaneseTitle} ${galleryItem.englishTitle}');

    if ((_ehConfigService.isJpnTitle.value) &&
        (galleryItem.japaneseTitle?.isNotEmpty ?? false)) {
      return galleryItem.englishTitle ?? '';
    } else {
      return galleryItem.japaneseTitle ?? '';
    }
  }

  final _topTitle = ''.obs;
  // get topTitle => _topTitle.value;
  set topTitle(val) => _topTitle.value = val;

  // 根据设置的语言显示的标题
  String get title {
    if ((_ehConfigService.isJpnTitle.value) &&
        (galleryItem.japaneseTitle?.isNotEmpty ?? false)) {
      return galleryItem.japaneseTitle ?? '';
    } else {
      return galleryItem.englishTitle ?? '';
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
  Future<void> _loarMordPriview({CancelToken? cancelToken}) async {
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 0));

    logger.v('获取更多预览 ${galleryItem.url} : $currentImagePage');

    final List<GalleryImage> _moreGalleryImageList = await Api.getGalleryImage(
      galleryItem.url!,
      page: currentImagePage + 1,
      cancelToken: cancelToken,
      refresh: isRefresh,
    );

    currentImagePage++;
    addAllImages(_moreGalleryImageList);
    if (Get.isRegistered<AllPreviewsPageController>()) {
      Get.find<AllPreviewsPageController>().update();
    }
  }

  final Map<int, Future<List<GalleryImage>>> _mapLoadImagesForSer = {};

  /// 直接请求目的index所在的缩略图页
  Future<void> loadImagesForSer(int ser, {CancelToken? cancelToken}) async {
    // TODO(w): 优化重复触发

    //  计算index所在的页码
    final int flen = firstPageImage.length;
    if (filecount <= flen) {
      return;
    }

    final int page = (ser - 1) ~/ flen;
    logger.d('ser:$ser 所在页码为$page');

    _mapLoadImagesForSer.putIfAbsent(
        page,
        () => Api.getGalleryImage(
              galleryItem.url!,
              page: page,
              cancelToken: cancelToken,
              refresh: isRefresh, // 刷新画廊后加载缩略图不能从缓存读取，否则在改变每页数量后加载画廊会出错
            ));

    final List<GalleryImage> _moreImageList = await _mapLoadImagesForSer[page]!;

    addAllImages(_moreImageList);
    if (Get.isRegistered<AllPreviewsPageController>()) {
      Get.find<AllPreviewsPageController>().update();
    }
    _mapLoadImagesForSer.remove(page);
  }

  // 按顺序翻页加载缩略图对象
  Future<bool> loadPriviewUntilIndex(int index) async {
    final List<GalleryImage>? _galleryImageList = galleryItem.galleryImages;

    if (_galleryImageList == null) {
      return true;
    }

    while (index > _galleryImageList.length - 1) {
      logger.d(' index = $index ; len = ${_galleryImageList.length}');
      await _loarMordPriview();
    }
    return true;
  }

  /// 获取当前页的图片url 宽高信息
  Future<GalleryImage?> getImageInfo(
    int itemSer, {
    CancelToken? cancelToken,
    // bool refresh = false,
    bool changeSource = false,
  }) async {
    try {
      /// 当前缩略图对象
      final GalleryImage? _curImages = galleryItem.imageMap[itemSer];

      if (_curImages == null) {
        return null;
      }

      final String? _largeImageUrl = _curImages.imageUrl;

      // logger.d('_largeImageUrl $_largeImageUrl');

      // 大图url为空或者宽高信息为空的时候 都会解析获取
      if (_largeImageUrl != null &&
          _largeImageUrl.isNotEmpty &&
          _curImages.imageHeight != null &&
          _curImages.imageWidth != null) {
        return galleryItem.imageMap[itemSer];
      } else {
        final String? _sourceId =
            changeSource ? galleryItem.imageMap[itemSer]?.sourceId : '';

        // logger.v(
        //     'ser:$itemSer ,href: ${galleryItem.previewMap[itemSer]?.href} , _sourceId: $_sourceId');

        try {
          final GalleryImage _image = await Api.fetchImageInfo(
            galleryItem.imageMap[itemSer]?.href ?? '',
            refresh: changeSource,
            sourceId: _sourceId,
          );

          logger.v('fetch _image ${_image.toJson()}');

          // 换源加载
          if (changeSource) {
            logger5.d('itemSer$itemSer 换源加载 ${_image.imageUrl}');
          }

          final GalleryImage _imageCopyWith = _curImages.copyWith(
            sourceId: _image.sourceId,
            imageUrl: _image.imageUrl,
            imageWidth: _image.imageWidth,
            imageHeight: _image.imageHeight,
          );

          logger.v('_imageCopyWith ${_imageCopyWith.toJson()}');

          uptImageBySer(ser: itemSer, image: _imageCopyWith);
          return _imageCopyWith;
        } catch (_) {
          rethrow;
        }
      }
    } catch (e, stack) {
      logger.e('$e \n $stack');
      FirebaseCrashlytics.instance.recordError(e, stack);
      rethrow;
    }
  }

  void downloadGallery() {
    final DownloadController _downloadController =
        Get.find<DownloadController>();
    _downloadController.downloadGallery(
      gid: int.parse(gid),
      token: galleryItem.token,
      url: galleryItem.url!,
      fileCount: int.parse(galleryItem.filecount ?? '0'),
      title: title,
    );
  }

  Future<void> addTag() async {
    final dynamic _rult = await Get.toNamed(EHRoutes.addTag);
    if (_rult != null && _rult is String) {
      logger.v('addTag $_rult');
      final TagInfoController? controller =
          Get.put(TagInfoController(), tag: pageCtrlDepth);
      controller?.tagVoteUp(_rult);
    }
  }
}
