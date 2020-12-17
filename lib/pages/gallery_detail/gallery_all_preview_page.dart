import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/utils/network/gallery_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'gallery_detail_widget.dart';

const double kMaxCrossAxisExtent = 135.0;
const double kMainAxisSpacing = 0; //主轴方向的间距
const double kCrossAxisSpacing = 4; //交叉轴方向子元素的间距
const double kChildAspectRatio = 0.55; //显示区域宽高比

class AllPreviewPage extends StatefulWidget {
  const AllPreviewPage({Key key}) : super(key: key);

  @override
  _AllPreviewPageState createState() => _AllPreviewPageState();
}

class _AllPreviewPageState extends State<AllPreviewPage> {
  List<GalleryPreview> _galleryPreviewList = <GalleryPreview>[];

//  int _currentPage;
  bool _isLoading = false;
  bool _isLoadFinsh = false;

  GalleryModel _galleryModel;

  final GlobalKey globalKey = GlobalKey();
  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: true);

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;

      _galleryPreviewList = _galleryModel.galleryItem.galleryPreview;
      _galleryModel.currentPreviewPage = 0;

      Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
        //获取position
        final RenderBox box = globalKey.currentContext.findRenderObject();

        //获取size
        final Size size = box.size;

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
            _galleryModel.oriGalleryPreview.length ~/ itemCountCross + 1;

        // 计算滚动距离
        final double _offset = (_toLine - itemCountCrossMain) * size.height;

        // 滚动
        _scrollController.animateTo(
          _offset,
          duration: Duration(milliseconds: _offset ~/ 6),
          curve: Curves.ease,
        );
        // _scrollController.jumpTo(_offset);

        logger.d('toLine:$_toLine  _offset:$_offset');
      }).catchError((e, stack) {
        logger.e('$stack');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int _count = int.parse(_galleryModel.galleryItem.filecount);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('all_preview'.tr),
      ),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverSafeArea(
            sliver: SliverPadding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              sliver: Selector<GalleryModel, GalleryItem>(
                  selector: (context, galleryModel) => galleryModel.galleryItem,
                  shouldRebuild: (pre, next) =>
                      int.parse(pre.filecount) == next.galleryPreview.length,
                  builder: (context, GalleryItem galleryItem, child) {
//                    logger.v('build SliverGrid');
                    return SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: kMaxCrossAxisExtent,
                              mainAxisSpacing: kMainAxisSpacing, //主轴方向的间距
                              crossAxisSpacing: kCrossAxisSpacing, //交叉轴方向子元素的间距
                              childAspectRatio: kChildAspectRatio //显示区域宽高比
                              ),
                      delegate: SliverChildBuilderDelegate(
                        (context, int index) {
                          //如果显示到最后一个 获取下一页缩略图
                          if (index == _galleryPreviewList.length - 1 &&
                              index < _count - 1) {
                            _loarMordPriview();
                          } else if (index >= _count - 1) {
                            _loadFinsh();
                          }
                          return Center(
                            key: index == 0 ? globalKey : null,
                            child: PreviewContainer(
                              galleryPreviewList: _galleryPreviewList,
                              index: index,
                            ),
                          );
                        },
                        childCount: _galleryPreviewList.length,
                      ),
                    );
                  }),
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
                        'noMorePreviews'.tr,
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
    );
  }

  Future<void> _loarMordPriview() async {
    if (_isLoading) {
      return;
    }
    //
    logger.v('获取更多预览 ${_galleryModel.galleryItem.url}');
    // 增加延时 避免build期间进行 setState
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _galleryModel.currentPreviewPageAdd();
    setState(() {
      _isLoading = true;
    });

    final List<GalleryPreview> _moreGalleryPreviewList =
        await Api.getGalleryPreview(
      _galleryModel.galleryItem.url,
      page: _galleryModel.currentPreviewPage,
    );

    _galleryPreviewList.addAll(_moreGalleryPreviewList);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadFinsh() async {
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
