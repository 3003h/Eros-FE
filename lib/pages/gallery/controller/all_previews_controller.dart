import 'package:dio/dio.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'gallery_page_controller.dart';

const double kMaxCrossAxisExtent = 135.0;
const double kMainAxisSpacing = 0; //主轴方向的间距
const double kCrossAxisSpacing = 4; //交叉轴方向子元素的间距
const double kChildAspectRatio = 0.55; //显示区域宽高比

class AllPreviewsPageController extends GetxController
    with StateMixin<List<GalleryImage>> {
  AllPreviewsPageController();
  GalleryPageController get _pageController => Get.find(tag: pageCtrlDepth);

  List<GalleryImage> get _images => _pageController.imagesFromMap;

  String get filecount => _pageController.galleryItem.filecount ?? '0';

  String get gid => _pageController.gid;

  CancelToken moreGalleryImageCancelToken = CancelToken();

  final GlobalKey globalKey = GlobalKey();
  final ScrollController scrollController =
      ScrollController(keepScrollOffset: true);

  bool isLoading = false;
  bool isLoadFinsh = false;

  @override
  void onClose() {
    super.onClose();
    scrollController.dispose();
    moreGalleryImageCancelToken.cancel();
  }

  @override
  void onInit() {
    super.onInit();

    _pageController.currentImagePage = 0;

    change(_images, status: RxStatus.success());

    WidgetsBinding.instance?.addPostFrameCallback((Duration callback) {
      logger.v('addPostFrameCallback be invoke');
      _jumpTo();
    });
  }

  Future<void> _jumpTo() async {
    //获取position
    final RenderBox? box =
        globalKey.currentContext!.findRenderObject() as RenderBox?;

    //获取size
    final Size size = box!.size;

    final MediaQueryData _mq = MediaQuery.of(Get.context!);
    final Size _screensize = _mq.size;
    final double _paddingLeft = _mq.padding.left;
    final double _paddingRight = _mq.padding.right;
    final double _paddingTop = _mq.padding.top;

    // 每行数量
    final int itemCountCross = (_screensize.width -
            kCrossAxisSpacing -
            _paddingRight -
            _paddingLeft) ~/
        size.width;

    // 单屏幕列数
    final int itemCountCrossMain = (_screensize.height -
            _paddingTop -
            kMinInteractiveDimensionCupertino) ~/
        size.height;

    final int _toLine =
        _pageController.firstPageImage.length ~/ itemCountCross + 1;

    // 计算滚动距离
    final double _offset = (_toLine - itemCountCrossMain) * size.height;

    // 滚动
    // _scrollController.animateTo(
    //   _offset,
    //   duration: Duration(milliseconds: _offset ~/ 6),
    //   curve: Curves.ease,
    // );
    scrollController.jumpTo(_offset);

    logger.d('toLine:$_toLine  _offset:$_offset');
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  Future<void> fetchPriviews() async {
    if (isLoading) {
      return;
    }
    //
    logger.v('获取更多预览 ${_pageController.galleryItem.url}');
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    isLoading = true;
    update();

    final List<GalleryImage> _nextGalleryImageList = await Api.getGalleryImage(
      _pageController.galleryItem.url!,
      page: _pageController.currentImagePage + 1,
      cancelToken: moreGalleryImageCancelToken,
      refresh: _pageController.isRefresh,
    );

    _pageController.addAllImages(_nextGalleryImageList);
    isLoading = false;
    _pageController.currentImagePage += 1;
    change(_images, status: RxStatus.success());
  }

  Future<void> fetchFinsh() async {
    if (isLoadFinsh) {
      return;
    }
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));
    isLoadFinsh = true;
    change(_images, status: RxStatus.success());
  }
}
