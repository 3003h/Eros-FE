import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/utils/utility.dart';
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
  int _currentPage;
  bool _isLoading = false;
  bool _isLoadFinsh = false;

  GalleryModel _galleryModel;

  @override
  void initState() {
    super.initState();

    _currentPage = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final galleryModel = Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != this._galleryModel) {
      this._galleryModel = galleryModel;
    }

    // 初始化
//    _galleryPreviewList.addAll(_galleryModel.galleryItem.galleryPreview);

    _galleryPreviewList = _galleryModel.galleryItem.galleryPreview;
  }

/*  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(ln.all_preview),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: GridView.builder(
            shrinkWrap: true, //解决无限高度问题
//            physics: NeverScrollableScrollPhysics(), //禁用滑动事件
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 135.0,
                mainAxisSpacing: 0, //主轴方向的间距
                crossAxisSpacing: 4, //交叉轴方向子元素的间距
                childAspectRatio: 0.595 //显示区域宽高
                ),
            itemCount: widget.galleryPreviewList.length,
            itemBuilder: (context, index) {
              //如果显示到最后一个 获取下一页缩略图
              if (index == _galleryPreviewList.length - 1 &&
                  index < int.parse(widget.filecount)) {
                _loarMordPriview();
              }

              return Center(
                child: PreviewContainer(
                  galleryPreviewList: _galleryPreviewList,
                  index: index,
                  showKey: widget.showKey,
                ),
              );
            }),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    var _count = int.parse(_galleryModel.galleryItem.filecount);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(ln.all_preview),
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverSafeArea(
            sliver: SliverPadding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                children: <Widget>[
                  _isLoading
                      ? CupertinoActivityIndicator(
                          radius: 14,
                        )
                      : Container(),
                  _isLoadFinsh ? Text('no more pic') : Container(),
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
    setState(() {
      _currentPage++;
      _isLoading = true;
    });

    var _moreGalleryPreviewList = await Api.getGalleryPreview(
        _galleryModel.galleryItem.url,
        page: _currentPage);

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
