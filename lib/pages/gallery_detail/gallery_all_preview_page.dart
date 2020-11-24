import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'gallery_detail_widget.dart';

class AllPreviewPage extends StatefulWidget {
  const AllPreviewPage({Key key}) : super(key: key);

  @override
  _AllPreviewPageState createState() => _AllPreviewPageState();
}

class _AllPreviewPageState extends State<AllPreviewPage> {
  List<GalleryPreview> _galleryPreviewList = [];

//  int _currentPage;
  bool _isLoading = false;
  bool _isLoadFinsh = false;

  GalleryModel _galleryModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;

      _galleryPreviewList = _galleryModel.galleryItem.galleryPreview;
      _galleryModel.currentPreviewPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final S ln = S.of(context);
    final int _count = int.parse(_galleryModel.galleryItem.filecount);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(ln.all_preview),
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverSafeArea(
            sliver: SliverPadding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              sliver: Selector<GalleryModel, GalleryItem>(
                  selector: (context, galleryModel) => galleryModel.galleryItem,
                  shouldRebuild: (pre, next) =>
                      int.parse(pre.filecount) == next.galleryPreview.length,
                  builder: (context, GalleryItem galleryItem, child) {
//                    Global.logger.v('build SliverGrid');
                    return SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 135.0,
                              mainAxisSpacing: 0, //主轴方向的间距
                              crossAxisSpacing: 4, //交叉轴方向子元素的间距
                              childAspectRatio: 0.55 //显示区域宽高
                              ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          //如果显示到最后一个 获取下一页缩略图
                          if (index == _galleryPreviewList.length - 1 &&
                              index < _count - 1) {
                            _loarMordPriview();
                          } else if (index >= _count - 1) {
                            _loadFinsh();
                          }
                          return Center(
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
                        ln.noMorePreviews,
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

  void _loarMordPriview() async {
    if (_isLoading) {
      return;
    }
    //
    Global.logger.v('获取更多预览 ${_galleryModel.galleryItem.url}');
    // 增加延时 避免build期间进行 setState
    await Future.delayed(Duration(milliseconds: 100));
    _galleryModel.currentPreviewPageAdd();
    setState(() {
      _isLoading = true;
    });

    var _moreGalleryPreviewList = await Api.getGalleryPreview(
      _galleryModel.galleryItem.url,
      page: _galleryModel.currentPreviewPage,
    );

    _galleryPreviewList.addAll(_moreGalleryPreviewList);
    setState(() {
      _isLoading = false;
    });
  }

  void _loadFinsh() async {
    if (_isLoadFinsh) {
      return;
    }
    // 增加延时 避免build期间进行 setState
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _isLoadFinsh = true;
    });
  }
}
