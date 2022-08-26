import 'package:dio/dio.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/gallery/view/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import 'gallery_page_controller.dart';
import 'gallery_page_state.dart';

class AllPreviewsPageController extends GetxController
    with StateMixin<Tuple2<List<GalleryImage>, List<GalleryImage>>> {
  AllPreviewsPageController();
  late GalleryPageController _pageController;
  GalleryPageState get _pageState => _pageController.gState;

  List<GalleryImage> get _images => _pageState.imagesFromMap;

  String get filecount => _pageState.galleryProvider?.filecount ?? '0';

  String get gid => _pageState.gid;

  CancelToken moreGalleryImageCancelToken = CancelToken();

  int get currPage => _pageState.currentImagePage;

  final GlobalKey globalKey = GlobalKey();
  final ScrollController scrollController =
      ScrollController(keepScrollOffset: true);

  bool isLoadingNext = false;
  bool isLoadingPrevious = false;
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

    _pageController = Get.find(tag: pageCtrlTag);

    _pageState.currentImagePage = 0;

    change(Tuple2([], _images), status: RxStatus.success());

    WidgetsBinding.instance.addPostFrameCallback((Duration callback) {
      logger.v('addPostFrameCallback be invoke');
      _autoJumpTo();
    });
  }

  Future<void> _autoJumpTo() async {
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

    final int _toLine = _pageState.firstPageImage.length ~/ itemCountCross + 1;

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

  // 获取下一页预览图
  Future<void> fetchPriviewsNext() async {
    if (isLoadingNext) {
      return;
    }
    //
    logger.v('获取更多预览 ${_pageState.galleryProvider?.url}');
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    isLoadingNext = true;
    // update();

    final List<GalleryImage> _nextGalleryImageList = await getGalleryImage(
      _pageState.galleryProvider?.url ?? '',
      page: _pageState.currentImagePage + 1,
      cancelToken: moreGalleryImageCancelToken,
      refresh: _pageState.isRefresh,
    );

    _pageController.addAllImages(_nextGalleryImageList);
    isLoadingNext = false;
    _pageState.currentImagePage += 1;
    change(Tuple2([], _images), status: RxStatus.success());
  }

  // 获取预览图fromPage
  Future<void> fetchPriviewsFromPage(int fromPage) async {
    if (isLoadingNext) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));

    change(Tuple2([], _images), status: RxStatus.loading());

    final List<GalleryImage> _galleryImageList = await getGalleryImage(
      _pageState.galleryProvider?.url ?? '',
      page: fromPage - 1,
      cancelToken: moreGalleryImageCancelToken,
      refresh: _pageState.isRefresh,
    );

    _pageState.images.clear();
    _pageController.addAllImages(_galleryImageList);
    _pageState.currentImagePage = fromPage - 1;

    update(['trailing']);
    change(Tuple2([], _images), status: RxStatus.success());
  }

  // 获取上一页预览图
  Future<void> fetchPriviewsPrevious() async {
    if (isLoadingPrevious) {
      return;
    }
    //
    logger.v('获取上一页预览 ${_pageState.galleryProvider?.url}');
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));

    isLoadingPrevious = true;
    // update();

    final List<GalleryImage> _previousGalleryImageList = await getGalleryImage(
      _pageState.galleryProvider?.url ?? '',
      page: _pageState.currentImagePage - 1,
      cancelToken: moreGalleryImageCancelToken,
      refresh: _pageState.isRefresh,
    );

    logger.d('_previousGalleryImageList ${_previousGalleryImageList.length}');

    _pageController.addAllImages(_previousGalleryImageList);

    isLoadingPrevious = false;
    _pageState.currentImagePage -= 1;
    // change(
    //     Tuple2([
    //       ...state?.item1 ?? <GalleryImage>[],
    //       ..._previousGalleryImageList,
    //     ], _images),
    //     status: RxStatus.success());

    change(Tuple2([], _images), status: RxStatus.success());
  }

  // 没有更多预览
  Future<void> fetchFinsh() async {
    if (isLoadFinsh) {
      return;
    }
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));
    isLoadFinsh = true;
    change(Tuple2([], _images), status: RxStatus.success());
  }

  // 判断是否显示跳页按钮
  bool get canShowJumpDialog =>
      _pageState.filecount > _pageState.firstPageImage.length;

  // 显示跳页Dialog
  Future showJumpDialog(BuildContext context) async {
    return await showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return JumpDialog(pageController: _pageController);
        });
  }
}

// 跳页Dialog
class JumpDialog extends StatefulWidget {
  const JumpDialog({Key? key, required this.pageController}) : super(key: key);
  final GalleryPageController pageController;

  @override
  _JumpDialogState createState() => _JumpDialogState();
}

class _JumpDialogState extends State<JumpDialog> {
  double _value = 0.0;
  int toPage = 1;
  int get maxpage =>
      (widget.pageController.gState.filecount ~/
          widget.pageController.gState.firstPageImage.length) +
      1;

  @override
  void initState() {
    super.initState();
    _value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('跳到 $toPage'),
      content: Row(
        children: [
          const Text('1'),
          Expanded(
            child: CupertinoSlider(
              value: _value,
              divisions: maxpage - 1,
              min: 1.0,
              max: maxpage / 1.0,
              onChanged: (double value) {
                _value = value;
                if (_value ~/ 1 != toPage) {
                  toPage = _value ~/ 1;
                  setState(() {});
                }
              },
            ),
          ),
          Text('$maxpage'),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: Text(L10n.of(context).ok),
          onPressed: () {
            Get.back(result: toPage);
          },
        )
      ],
    );
  }
}
