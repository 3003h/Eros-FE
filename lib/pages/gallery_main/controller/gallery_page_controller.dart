import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery_view/controller/view_controller.dart';
import 'package:fehviewer/pages/gallery_view/view/common.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

import 'gallery_fav_controller.dart';

const double kHeaderHeight = 200.0 + 52;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryPageController extends GetxController
    with StateMixin<GalleryItem> {
  GalleryPageController();

  GalleryPageController.initUrl({@required String url}) {
    galleryItem = GalleryItem()..url = url;
    fromUrl = true;
  }

  GalleryPageController.fromItem({
    @required this.galleryItem,
    @required this.tabIndex,
  }) : gid = galleryItem.gid;

  // 画廊gid 唯一
  String gid;

  bool isRefresh = false;

  GalleryItemController _itemController;

  final RxBool _fromUrl = false.obs;
  bool get fromUrl => _fromUrl.value;
  set fromUrl(bool val) => _fromUrl.value = val;

  final RxBool _isRatinged = false.obs;
  bool get isRatinged => _isRatinged.value;
  set isRatinged(bool val) => _isRatinged.value = val;

  void ratinged() {
    isRatinged = true;
    galleryItem.isRatinged = true;
    _itemController.galleryItem.isRatinged = true;
  }

  // 画廊数据对象
  GalleryItem galleryItem;
  List<GalleryPreview> get previews => galleryItem.galleryPreview;

  String tabIndex;

  String get showKey => galleryItem.showKey;

  // 当前缩略图页码
  int currentPreviewPage;

  // 已获取所有大图页面的 href
  bool isGetAllImageHref = false;
  bool isImageInfoGeting = false;

  // 滚动控制器
  final ScrollController scrollController = ScrollController();

  // eh设置
  final EhConfigService _ehConfigService = Get.find();
  final HistoryController _historyController = Get.find();
  final DepthService depthService = Get.find();

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(_scrollControllerLister);
    hideNavigationBtn = true;

    if (!fromUrl) {
      _itemController = Get.find(tag: gid);
      logger.d(
          'isRatinged: i-${_itemController.galleryItem.isRatinged} p-${galleryItem.isRatinged}');
    }

    _loadData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    depthService.popPageCtrl();
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

  // 添加缩略图对象
  void addAllPreview(List<GalleryPreview> galleryPreview) {
    galleryItem.galleryPreview.addAll(galleryPreview);
    Get.find<ViewController>().update(['_buildPhotoViewGallery']);
    update();
  }

  // 是否存在本地收藏中
  set localFav(bool value) {
    galleryItem.localFav = value;
  }

  bool get localFav => galleryItem.localFav ?? false;

  /// 请求数据
  Future<GalleryItem> _fetchData({bool refresh = false}) async {
    logger.d('fetch data');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      hideNavigationBtn = true;

      // 检查画廊是否包含在本地收藏中
      final bool _localFav = _isInLocalFav(galleryItem.gid);
      galleryItem.localFav = _localFav;

      await Future<void>.delayed(const Duration(milliseconds: 200));

      if (galleryItem.filecount == null || galleryItem.filecount.isEmpty) {
        await Api.getMoreGalleryInfoOne(galleryItem, refresh: refresh);
      }

      galleryItem = await Api.getGalleryDetail(
        inUrl: galleryItem.url,
        inGalleryItem: galleryItem,
        refresh: refresh,
      );

      currentPreviewPage = 0;
      setPreviewAfterRequest(galleryItem.galleryPreview);

      /// 通知收藏控制器更新
      try {
        if (refresh) {
          final GalleryFavController _favController =
              Get.find(tag: '${Get.find<DepthService>().pageCtrlDepth}');
          // _favController.favcat = galleryItem.favcat;
          _favController.setFav(galleryItem.favcat, galleryItem.favTitle);

          isRatinged = galleryItem.isRatinged;
        }
        // ignore: empty_catches
      } catch (e) {}

      galleryItem.imgUrl = galleryItem.imgUrl ?? galleryItem.imgUrlL;

      // 加入历史
      if (galleryItem.gid != null) {
        Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
          _historyController.addHistory(galleryItem);
        });
      }

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

  Future<void> _loadData({bool refresh = false, bool showError = true}) async {
    try {
      final GalleryItem value = await _fetchData(refresh: refresh);
      change(value, status: RxStatus.success());
      _enableRead.value = true;
      logger
          .d('${galleryItem.isRatinged} value.isRatinged:${value.isRatinged}');
      isRatinged = (galleryItem.isRatinged ?? false) ||
          value.isRatinged ||
          (_itemController?.galleryItem?.isRatinged ?? false);
    } catch (err, stack) {
      logger.e('$err\n$stack');
      if (showError) {
        change(null, status: RxStatus.error(err.toString()));
      }
    }
  }

  Future<void> _reloadData() async {
    isRefresh = true;
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
    if (scrollController.offset < kHeaderHeight + kHeaderPaddingTop &&
        !hideNavigationBtn) {
      hideNavigationBtn = true;
    } else if (scrollController.offset >= kHeaderHeight + kHeaderPaddingTop &&
        hideNavigationBtn) {
      hideNavigationBtn = false;
    }
  }

  // 另一个语言的标题
  String get topTitle {
    if (!_ehConfigService.isJpnTitle.value ||
        (galleryItem.japaneseTitle?.isNotEmpty ?? false)) {
      return galleryItem.englishTitle;
    } else {
      return galleryItem.japaneseTitle;
    }
  }

  // 根据设置的语言显示的标题
  String get title {
    if (_ehConfigService.isJpnTitle.value &&
        (galleryItem.japaneseTitle?.isNotEmpty ?? false)) {
      return galleryItem.japaneseTitle;
    } else {
      return galleryItem.englishTitle;
    }
  }

  /// 显示等待
  Future<void> showLoadingDialog(BuildContext context, int index) async {
    /// 加载下一页缩略图
    Future<void> _loarMordPriview({CancelToken cancelToken}) async {
      // 增加延时 避免build期间进行 setState
      await Future<void>.delayed(const Duration(milliseconds: 0));
      currentPreviewPage++;
      // logger.v(
      //     '获取更多预览 ${_galleryPageController.galleryItem.url} : ${_galleryPageController.currentPreviewPage}');

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
        logger.d(' index = $index ; len = ${_galleryPreviewList.length}');
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
        return CupertinoAlertDialog(
          content: Container(
              width: 40,
              child: const CupertinoActivityIndicator(
                radius: 30,
              )),
          actions: const <Widget>[],
        );
      },
    );
  }

  /// 解析获取画廊图片链接
  /// 自动获取下一页直到全部获取
  /// 缺点比较明显 图片比较多的画廊一次全部获取会导致卡顿等
  Future<void> _getAllImageHref({CancelToken cancelToken}) async {
    if (isGetAllImageHref) {
      loggerNoStack.d(' isGetAllImageHref return');
      return;
    }
    isGetAllImageHref = true;
    final int _filecount = int.parse(galleryItem.filecount);

    logger.d('_filecount : $_filecount');

    // 获取画廊所有图片页面的href
    while (previews.length < _filecount) {
      currentPreviewPage++;

      final List<GalleryPreview> _moreGalleryPreviewList =
          await Api.getGalleryPreview(
        galleryItem.url,
        page: currentPreviewPage,
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
    }
    isGetAllImageHref = false;
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
    if (previews.length - index < 4) {
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

  /// 获取当前页的图片地址 宽高信息
  Future<GalleryPreview> getImageInfo(
    int index, {
    CancelToken cancelToken,
  }) async {
    // 数据获取处理
    try {
      await _lazyGetImageHref(cancelToken: cancelToken, index: index);
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
        final GalleryPreview _preview = await GalleryPrecache.instance
            .paraImageLageInfoFromApi(
                galleryItem.galleryPreview[index].href, showKey,
                index: index);
        return _preview;
      }
    } catch (e, stack) {
      logger.e('$e \n $stack');
      rethrow;
    }
  }
}
