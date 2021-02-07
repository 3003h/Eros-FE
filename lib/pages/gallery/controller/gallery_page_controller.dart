import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/main.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/rate_controller.dart';
import 'package:fehviewer/pages/gallery/controller/torrent_controller.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/time.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'archiver_controller.dart';
import 'comment_controller.dart';
import 'gallery_fav_controller.dart';

const double kHeaderHeight = 200.0 + 52;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryPageController extends GetxController
    with StateMixin<GalleryItem> {
  GalleryPageController({this.galleryRepository});

  final GalleryRepository galleryRepository;

  // GalleryPageController.initUrl({@required String url}) {
  //   galleryItem = GalleryItem()..url = url;
  //   fromUrl = true;
  // }
  //
  // GalleryPageController.fromItem({
  //   @required this.galleryItem,
  // }) : gid = galleryItem.gid;

  /// 画廊数据对象
  GalleryItem _galleryItem;

  GalleryItem get galleryItem => _galleryItem;

  set galleryItem(GalleryItem val) {
    _galleryItem = val;
  }

  /// 画廊gid 唯一
  String get gid => galleryItem?.gid ?? '';

  bool isRefresh = false;

  final RxBool _fromUrl = false.obs;

  bool get fromUrl => _fromUrl.value;

  set fromUrl(bool val) => _fromUrl.value = val;

  final RxBool _isRatinged = false.obs;

  bool get isRatinged => _isRatinged.value;

  set isRatinged(bool val) => _isRatinged.value = val;

  // 评分后更新ui和数据
  void ratinged({
    double ratingUsr,
    double ratingAvg,
    int ratingCnt,
    String colorRating,
  }) {
    isRatinged = true;
    galleryItem.isRatinged = true;

    galleryItem.ratingFallBack = ratingUsr;
    galleryItem.rating = ratingAvg;
    galleryItem.ratingCount = ratingCnt.toString();
    galleryItem.colorRating = colorRating;
    update(['header']);

    _itemController.update();
  }

  GalleryItemController get _itemController {
    try {
      return Get.find(tag: gid);
    } catch (_) {
      return null;
    }
  }

  List<GalleryPreview> get previews => galleryItem.galleryPreview;

  String get showKey => galleryItem.showKey;

  /// 当前缩略图页码
  int currentPreviewPage;

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

    // logger.d('GalleryPageController$pageCtrlDepth onInit');

    scrollController.addListener(_scrollControllerLister);
    hideNavigationBtn = true;

    if (galleryRepository.url != null && galleryRepository.url.isNotEmpty) {
      fromUrl = true;
      galleryItem = GalleryItem()..url = galleryRepository.url;
    } else {
      _galleryItem = galleryRepository.item;
    }

    _firstLoadData();
  }

  @override
  void onClose() {
    scrollController.dispose();

    // 为了保证能正常关闭
    try {
      Get.delete<RateController>(tag: pageCtrlDepth);
      Get.delete<TorrentController>(tag: pageCtrlDepth);
      Get.delete<ArchiverController>(tag: pageCtrlDepth);
      Get.delete<CommentController>(tag: pageCtrlDepth);
    } catch (_) {}

    logger.d('onClose GalleryPageController $pageCtrlDepth');
    Get.find<DepthService>().popPageCtrl();
    super.onClose();
  }

  // 阅读按钮开关
  final RxBool _enableRead = false.obs;

  bool get enableRead => _enableRead.value;

  bool get hasMorePreview {
    return int.parse(galleryItem?.filecount ?? '0') >
            firstPagePreview?.length ??
        0;
  }

  // 控制隐藏导航栏按钮和封面
  final RxBool _hideNavigationBtn = true.obs;

  bool get hideNavigationBtn => _hideNavigationBtn.value;

  set hideNavigationBtn(bool val) => _hideNavigationBtn.value = val;

  // 第一页的缩略图对象数组
  List<GalleryPreview> _firstPagePreview;

  List<GalleryPreview> get firstPagePreview => _firstPagePreview;

  void setPreviewAfterRequest(List<GalleryPreview> galleryPreview) {
    if (galleryPreview.isNotEmpty) {
      galleryItem.galleryPreview = galleryPreview;
    }

    _firstPagePreview =
        galleryItem.galleryPreview.sublist(0, galleryPreview.length);
  }

  /// 添加缩略图对象
  void addAllPreview(List<GalleryPreview> galleryPreview) {
    galleryItem.galleryPreview.addAll(galleryPreview);
    Get.find<ViewController>().update(['_buildPhotoViewGallery']);
    update();
  }

  /// 是否存在本地收藏中
  set localFav(bool value) {
    galleryItem.localFav = value;
  }

  bool get localFav => galleryItem.localFav ?? false;

  /// 请求数据
  Future<GalleryItem> _fetchData({bool refresh = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // logger.d('fetch data refresh:$refresh');
    try {
      hideNavigationBtn = true;

      if (galleryItem?.filecount == null ||
          (galleryItem?.filecount?.isEmpty ?? true)) {
        await Api.getMoreGalleryInfoOne(galleryItem, refresh: refresh);
      }

      // 检查画廊是否包含在本地收藏中
      final bool _localFav = _isInLocalFav(galleryItem.gid);
      galleryItem.localFav = _localFav;

      // logger.d('colorRating i-[${_itemController?.galleryItem?.colorRating}] '
      //     ' p-[${galleryItem.colorRating}]');

      final String _oriColorRating = galleryItem.colorRating;
      final String _oriRatingCount = galleryItem.ratingCount;
      final double _oriRatingFallBack = galleryItem.ratingFallBack;
      final bool _oriIsRatinged = galleryItem.isRatinged;

      time.showTime('start get galleryItem');
      galleryItem = await Api.getGalleryDetail(
        inUrl: galleryItem.url,
        inGalleryItem: galleryItem,
        refresh: refresh,
      );
      time.showTime('fetch galleryItem end');

      currentPreviewPage = 0;
      setPreviewAfterRequest(galleryItem.galleryPreview);

      // logger.d('ratingCount ${galleryItem.ratingCount} ');

      try {
        // 页面内刷新时的处理
        if (refresh) {
          // 收藏控制器状态更新
          final GalleryFavController _favController =
              Get.find(tag: pageCtrlDepth);
          _favController.setFav(galleryItem.favcat, galleryItem.favTitle);

          // 评论控制器状态数据更新
          Get.find<CommentController>(tag: pageCtrlDepth)
              .change(galleryItem.galleryComment);

          // 评分状态更新
          isRatinged = galleryItem.isRatinged;
        } else {
          galleryItem.ratingFallBack ??= _oriRatingFallBack;
          galleryItem.ratingCount ??= _oriRatingCount;
          galleryItem.colorRating = _oriColorRating;
          galleryItem.isRatinged = _oriIsRatinged;
        }
      } catch (_) {}

      galleryItem.imgUrl = galleryItem.imgUrl ?? galleryItem.imgUrlL;

      // 加入历史
      if (galleryItem.gid != null) {
        Future<void>.delayed(const Duration(milliseconds: 700)).then((_) {
          _historyController.addHistory(galleryItem);
        });
      }

      // logger.d('fb ${galleryItem.ratingFallBack} ');

      // logger.d('ratingCount ${galleryItem.ratingCount} ');

      update(['header']);
      _itemController?.update([gid]);
      return galleryItem;
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE && e.response.statusCode == 404) {
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

  // Future<void> getShowKey({int index = 0}) async {
  //   final String _showKey = await Api.getShowkey(previews[index].href);
  //   galleryItem.showKey = _showKey;
  // }

  Future<void> _firstLoadData(
      {bool refresh = false, bool showError = true}) async {
    try {
      final GalleryItem _fetchItem = await _fetchData(refresh: refresh);
      change(_fetchItem, status: RxStatus.success());
      time.showTime('change end');
      _enableRead.value = true;
      // isRatinged = (galleryItem?.isRatinged ?? false) ||
      //     (_fetchItem?.isRatinged ?? false) ||
      //     (_itemController?.galleryItem?.isRatinged ?? false);

      await analytics.logViewItem(
        itemId: galleryItem.gid,
        itemName: galleryItem.englishTitle,
        itemCategory: galleryItem.category,
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
    await _firstLoadData(refresh: true, showError: false);
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

    if (_ehConfigService.isJpnTitle.value &&
        (galleryItem?.japaneseTitle?.isNotEmpty ?? false)) {
      return galleryItem?.englishTitle ?? '';
    } else {
      return galleryItem?.japaneseTitle ?? '';
    }
  }

  // 根据设置的语言显示的标题
  String get title {
    if (_ehConfigService.isJpnTitle.value &&
        (galleryItem?.japaneseTitle?.isNotEmpty ?? false)) {
      return galleryItem?.japaneseTitle ?? '';
    } else {
      return galleryItem?.englishTitle ?? '';
    }
  }

  /// 显示等待
  Future<void> showLoadingDialog(BuildContext context, int index) async {
    /// 加载下一页缩略图
    Future<void> _loarMordPriview({CancelToken cancelToken}) async {
      // 增加延时 避免build期间进行 setState
      await Future<void>.delayed(const Duration(milliseconds: 0));
      currentPreviewPage++;
      logger.v('获取更多预览 ${galleryItem.url} : ${currentPreviewPage}');

      final List<GalleryPreview> _moreGalleryPreviewList =
          await Api.getGalleryPreview(
        galleryItem.url,
        page: currentPreviewPage,
        cancelToken: cancelToken,
        refresh: isRefresh,
      );

      // previews.addAll(_moreGalleryPreviewList);
      addAllPreview(_moreGalleryPreviewList);
    }

    // 翻页加载缩略图对象
    Future<bool> _loadPriview(int index) async {
      final List<GalleryPreview> _galleryPreviewList =
          galleryItem.galleryPreview;

      while (index > _galleryPreviewList.length - 1) {
        // logger.d(' index = $index ; len = ${_galleryPreviewList.length}');
        await _loarMordPriview();
      }
      return true;
    }

    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        Future<void>.delayed(const Duration(milliseconds: 0))
            .then((_) => _loadPriview(index))
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

  /// 懒加载
  Future<void> _lazyGetImageHref({int index, CancelToken cancelToken}) async {
    if (isImageInfoGeting) {
      loggerNoStack.d(' isGetAllImageHref return');
      return;
    }
    isImageInfoGeting = true;
    // logger.d('length ${previews.length} ; index $index');

    // todo 好像还有点问题
    if (previews.length - index < 10) {
      try {
        final List<GalleryPreview> _moreGalleryPreviewList =
            await Api.getGalleryPreview(
          galleryItem.url,
          page: currentPreviewPage + 1,
          cancelToken: cancelToken,
          refresh: isRefresh,
        );

        // 避免重复添加
        if (_moreGalleryPreviewList.first.ser >
            galleryItem.galleryPreview.last.ser) {
          logger.d('添加图片对象 起始序号${_moreGalleryPreviewList.first.ser}  '
              '数量${_moreGalleryPreviewList.length}');
          addAllPreview(_moreGalleryPreviewList);
        }
        // 成功后才+1
        currentPreviewPage++;
      } catch (e, stack) {
        showToast('$e');
        logger.e('$e\n$stack');
        rethrow;
      } finally {
        isImageInfoGeting = false;
      }
    }
    isImageInfoGeting = false;
  }

  /// 获取当前页的图片url 宽高信息
  Future<GalleryPreview> getImageInfo(
    int index, {
    CancelToken cancelToken,
    bool refresh,
    bool changeSource = false,
  }) async {
    // 数据获取处理
    try {
      await _lazyGetImageHref(
        cancelToken: cancelToken,
        index: index,
      );
    } catch (e, stack) {
      logger.e('$e \n $stack');
    }

    try {
      final GalleryPreview _curPreview = galleryItem.galleryPreview[index];
      final String _largeImageUrl = _curPreview.largeImageUrl;

      if (_largeImageUrl != null &&
          _largeImageUrl.isNotEmpty &&
          _curPreview.largeImageHeight != null &&
          _curPreview.largeImageWidth != null) {
        return galleryItem.galleryPreview[index];
      } else {
        final _sourceId =
            changeSource ? galleryItem.galleryPreview[index].sourceId : '';

        // paraImageLageInfoFromHtml
        final GalleryPreview _preview = await Api.ftchImageInfo(
          galleryItem.galleryPreview[index].href,
          index: index,
          refresh: refresh,
          sourceId: _sourceId,
        );

        if (changeSource) {
          logger.d('changeSource ${_preview.largeImageUrl}');
        }

        return _preview;
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
      url: galleryItem.url,
      fileCount: int.parse(galleryItem.filecount),
      title: title,
    );
  }
}
