import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/rate_controller.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:fehviewer/pages/gallery/controller/torrent_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/time.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'all_previews_controller.dart';
import 'archiver_controller.dart';
import 'comment_controller.dart';
import 'gallery_fav_controller.dart';

const double kHeaderHeight = 200.0 + 52;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryPageController extends GetxController
    with StateMixin<GalleryItem> {
  GalleryPageController({this.galleryRepository});

  final GalleryRepository? galleryRepository;

  // GalleryPageController.initUrl({@required String url}) {
  //   galleryItem = GalleryItem()..url = url;
  //   fromUrl = true;
  // }
  //
  // GalleryPageController.fromItem({
  //   @required this.galleryItem,
  // }) : gid = galleryItem.gid;

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

  // 评分后更新ui和数据
  void ratinged({
    required double ratingUsr,
    required double ratingAvg,
    required int ratingCnt,
    required String colorRating,
  }) {
    isRatinged = true;
    // galleryItem.isRatinged = true;
    //
    // galleryItem.ratingFallBack = ratingUsr;
    // galleryItem.rating = ratingAvg;
    // galleryItem.ratingCount = ratingCnt.toString();
    // galleryItem.colorRating = colorRating;

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

  List<GalleryPreview> get previews => galleryItem.galleryPreview ?? [];

  Map<int, GalleryPreview> get previewMap => galleryItem.previewMap;

  int get filecount => int.parse(galleryItem.filecount ?? '0');

  List<GalleryPreview> get previewsFromMap {
    List<MapEntry<int, GalleryPreview>> list = previewMap.entries
        .map((MapEntry<int, GalleryPreview> e) => MapEntry(e.key, e.value))
        .toList();
    logger.d('previewsFromMap len ${list.length}');
    list.sort((a, b) => a.key.compareTo(b.key));

    return list.map((e) => e.value).toList();
  }

  void uptPreviewBySer({required int ser, required GalleryPreview preview}) {
    final int? _index = galleryItem.galleryPreview
        ?.indexWhere((GalleryPreview element) => element.ser == ser);
    if (_index != null && _index >= 0) {
      galleryItem.galleryPreview?[_index] = preview;
    }
  }

  final Map<int, int> errCountMap = {};

  String get showKey => galleryItem.showKey ?? '';

  /// 当前缩略图页码
  late int currentPreviewPage;

  // 正在获取href
  bool isImageInfoGeting = false;

  // 滚动控制器
  final ScrollController scrollController = ScrollController();

  // eh设置
  final EhConfigService _ehConfigService = Get.find();
  final HistoryController _historyController = Get.find();

  @override
  void onInit() {
    super.onInit();

    logger.d('GalleryPageController $pageCtrlDepth onInit');

    scrollController.addListener(_scrollControllerLister);
    hideNavigationBtn = true;

    if (galleryRepository != null &&
        galleryRepository!.url != null &&
        galleryRepository!.url!.isNotEmpty) {
      // url跳转
      fromUrl = true;
      // galleryItem = GalleryItem()..url = galleryRepository.url;

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

    logger.d('GalleryPageController $pageCtrlDepth onInit end');
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.dispose();

    // 为了保证能正常关闭
    try {
      Get.delete<RateController>(tag: pageCtrlDepth);
      Get.delete<TorrentController>(tag: pageCtrlDepth);
      Get.delete<ArchiverController>(tag: pageCtrlDepth);
      Get.delete<CommentController>(tag: pageCtrlDepth);
      Get.delete<TagInfoController>(tag: pageCtrlDepth);
    } catch (_) {}

    logger.d('onClose GalleryPageController $pageCtrlDepth');
    Get.find<DepthService>().popPageCtrl();
  }

  // 阅读按钮开关
  final RxBool _enableRead = false.obs;

  bool get enableRead => _enableRead.value;

  bool get hasMorePreview {
    return int.parse(galleryItem.filecount ?? '0') > (firstPagePreview.length);
  }

  // 控制隐藏导航栏按钮和封面
  final RxBool _hideNavigationBtn = true.obs;

  bool get hideNavigationBtn => _hideNavigationBtn.value;

  set hideNavigationBtn(bool val) => _hideNavigationBtn.value = val;

  // 第一页的缩略图对象数组
  late List<GalleryPreview> _firstPagePreview;

  List<GalleryPreview> get firstPagePreview => _firstPagePreview;

  void setPreviewAfterRequest(List<GalleryPreview>? galleryPreview) {
    if (galleryPreview?.isNotEmpty ?? false) {
      // galleryItem.galleryPreview = galleryPreview;
      galleryItem = galleryItem.copyWith(galleryPreview: galleryPreview);
    }

    _firstPagePreview =
        galleryItem.galleryPreview!.sublist(0, galleryPreview?.length);
  }

  /// 添加缩略图对象
  void addAllPreview(List<GalleryPreview> galleryPreview) {
    // try {
    //   Get.find<ViewController>().update([GetID.IMAGE_VIEW]);
    // } catch (_) {}

    logger.v(
        'addAllPreview ${galleryPreview.first.ser}~${galleryPreview.last.ser} ');

    // update();
    for (final GalleryPreview _preview in galleryPreview) {
      final int index =
          previews.indexWhere((GalleryPreview e) => e.ser == _preview.ser);
      if (index != -1) {
        previews[index] = _preview;
      } else {
        previews.add(_preview);
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

      currentPreviewPage = 0;
      setPreviewAfterRequest(galleryItem.galleryPreview);

      logger.v('category ${galleryItem.category}');

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
        showToast('画廊已被删除');
        rethrow;
      }
      rethrow;
    } catch (e, stack) {
      showToast('解析数据异常');
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
      if (scrollController.offset < kHeaderHeight + kHeaderPaddingTop &&
          !hideNavigationBtn) {
        hideNavigationBtn = true;
      } else if (scrollController.offset >= kHeaderHeight + kHeaderPaddingTop &&
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
  Future<void> showDialogFetchPreviewUntilIndex(
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
    currentPreviewPage++;
    logger.v('获取更多预览 ${galleryItem.url} : $currentPreviewPage');

    final List<GalleryPreview> _moreGalleryPreviewList =
        await Api.getGalleryPreview(
      galleryItem.url!,
      page: currentPreviewPage,
      cancelToken: cancelToken,
      refresh: isRefresh,
    );

    addAllPreview(_moreGalleryPreviewList);
    Get.find<AllPreviewsPageController>().update();
  }

  // 直接请求目的index所在的缩略图页
  Future<void> loadPriviewsForSer(int ser, {CancelToken? cancelToken}) async {
    //  计算index所在的页码
    final int flen = firstPagePreview.length;
    if (filecount <= flen) {
      return;
    }

    final int page = (ser - 1) ~/ flen;
    logger.v('ser:$ser 所在页码为$page');

    final List<GalleryPreview> _morePreviewList = await Api.getGalleryPreview(
      galleryItem.url!,
      page: page,
      cancelToken: cancelToken,
      refresh: isRefresh, // 刷新画廊后加载缩略图不能从缓存读取，否则在改变每页数量后加载画廊会出错
    );

    // logger.v(
    //     '添加的图片序号: ${_morePreviewList.map((GalleryPreview e) => e.ser).join(',')}');

    // previews.addAll(_morePreviewList);
    addAllPreview(_morePreviewList);
    Get.find<AllPreviewsPageController>().update();
    // logger.v('previews len： ${previews.length}');
  }

  // 按顺序翻页加载缩略图对象
  Future<bool> loadPriviewUntilIndex(int index) async {
    final List<GalleryPreview>? _galleryPreviewList =
        galleryItem.galleryPreview;

    if (_galleryPreviewList == null) {
      return true;
    }

    while (index > _galleryPreviewList.length - 1) {
      logger.d(' index = $index ; len = ${_galleryPreviewList.length}');
      await _loarMordPriview();
    }
    return true;
  }

  /// 获取当前页的图片url 宽高信息
  Future<GalleryPreview?> getImageInfo(
    int itemSer, {
    CancelToken? cancelToken,
    bool refresh = false,
    bool changeSource = false,
  }) async {
    try {
      /// 当前缩略图对象
      final GalleryPreview? _curPreview = galleryItem.previewMap[itemSer];

      if (_curPreview == null) {
        return null;
      }

      final String? _largeImageUrl = _curPreview.largeImageUrl;

      // logger.d('_largeImageUrl $_largeImageUrl');

      // 大图url为空或者宽高信息为空的时候 都会解析获取
      if (_largeImageUrl != null &&
          _largeImageUrl.isNotEmpty &&
          _curPreview.largeImageHeight != null &&
          _curPreview.largeImageWidth != null) {
        return galleryItem.previewMap[itemSer];
      } else {
        final String? _sourceId =
            changeSource ? galleryItem.previewMap[itemSer]?.sourceId : '';

        logger.v(
            'ser:$itemSer ,href: ${galleryItem.previewMap[itemSer]?.href} , _sourceId: $_sourceId');

        try {
          final GalleryPreview _preview = await Api.ftchImageInfo(
            galleryItem.previewMap[itemSer]?.href ?? '',
            ser: itemSer,
            refresh: changeSource,
            sourceId: _sourceId,
          );

          logger.v('fetch _preview ${_preview.toJson()}');

          // 换源加载
          if (changeSource) {
            logger.d('itemSer$itemSer 换源加载 ${_preview.largeImageUrl}');
          }

          final GalleryPreview _previewCopyWith = _curPreview.copyWith(
            sourceId: _preview.sourceId,
            largeImageUrl: _preview.largeImageUrl,
            largeImageWidth: _preview.largeImageWidth,
            largeImageHeight: _preview.largeImageHeight,
          );
          uptPreviewBySer(ser: itemSer, preview: _previewCopyWith);
          return _preview;
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
    _downloadController.downloadGalleryIsolate(
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
