import 'package:dio/dio.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'gallery_widget.dart';

const double kMaxCrossAxisExtent = 135.0;
const double kMainAxisSpacing = 0; //主轴方向的间距
const double kCrossAxisSpacing = 4; //交叉轴方向子元素的间距
const double kChildAspectRatio = 0.55; //显示区域宽高比

class AllPreviewPage extends StatefulWidget {
  const AllPreviewPage({Key? key}) : super(key: key);

  @override
  _AllPreviewPageState createState() => _AllPreviewPageState();
}

class _AllPreviewPageState extends State<AllPreviewPage> {
  List<GalleryPreview> _galleryPreviewList = <GalleryPreview>[];

  bool _isLoading = false;
  bool _isLoadFinsh = false;

  final GlobalKey globalKey = GlobalKey();
  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: true);

  // ScrollController _scrollController;

  CancelToken moreGalleryPreviewCancelToken = CancelToken();

  final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    moreGalleryPreviewCancelToken.cancel();
  }

  @override
  void initState() {
    super.initState();

    _galleryPreviewList = _pageController.previews;
    _pageController.currentPreviewPage = 0;

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

    final MediaQueryData _mq = MediaQuery.of(context);
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
        _pageController.firstPagePreview.length ~/ itemCountCross + 1;

    // 计算滚动距离
    final double _offset = (_toLine - itemCountCrossMain) * size.height;

    // 滚动
    // _scrollController.animateTo(
    //   _offset,
    //   duration: Duration(milliseconds: _offset ~/ 6),
    //   curve: Curves.ease,
    // );
    _scrollController.jumpTo(_offset);

    logger.d('toLine:$_toLine  _offset:$_offset');
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int _count = int.parse(_pageController.galleryItem.filecount ?? '0');
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: GestureDetector(
          onTap: _scrollToTop,
          child: Text(S.of(context).all_preview),
        ),
        previousPageTitle: S.of(context).back,
      ),
      child: CupertinoScrollbar(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverSafeArea(
              sliver: SliverPadding(
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: kMaxCrossAxisExtent,
                      mainAxisSpacing: kMainAxisSpacing, //主轴方向的间距
                      crossAxisSpacing: kCrossAxisSpacing, //交叉轴方向子元素的间距
                      childAspectRatio: kChildAspectRatio //显示区域宽高比
                      ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      //如果显示到最后一个 获取下一页缩略图
                      if (index == _galleryPreviewList.length - 1 &&
                          index < _count - 1) {
                        _fetchNextPriviews();
                      } else if (index >= _count - 1) {
                        _fetchFinsh();
                      }
                      return Center(
                        key: index == 0 ? globalKey : null,
                        child: PreviewContainer(
                          galleryPreviewList: _galleryPreviewList,
                          index: index,
                          gid: _pageController.gid,
                        ),
                      );
                    },
                    childCount: _galleryPreviewList.length,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(bottom: 50, top: 10),
                child: Column(
                  children: <Widget>[
                    if (_isLoading)
                      const CupertinoActivityIndicator(
                        radius: 14,
                      )
                    else
                      Container(),
                    if (_isLoadFinsh)
                      Container(
                        padding: const EdgeInsets.only(top: 0),
                        child: Text(
                          S.of(context).noMorePreviews,
                          style: const TextStyle(fontSize: 14),
                        ),
                      )
                    else
                      Container(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _fetchNextPriviews() async {
    if (_isLoading) {
      return;
    }
    //
    logger.v('获取更多预览 ${_pageController.galleryItem.url}');
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _pageController.currentPreviewPage++;
    setState(() {
      _isLoading = true;
    });

    final List<GalleryPreview> _nextGalleryPreviewList =
        await Api.getGalleryPreview(
      _pageController.galleryItem.url!,
      page: _pageController.currentPreviewPage,
      cancelToken: moreGalleryPreviewCancelToken,
      refresh: _pageController.isRefresh,
    );

    // _galleryPreviewList.addAll(_nextGalleryPreviewList);
    _pageController.addAllPreview(_nextGalleryPreviewList);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchFinsh() async {
    if (_isLoadFinsh) {
      return;
    }
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));
    setState(() {
      _isLoadFinsh = true;
    });
  }
}
