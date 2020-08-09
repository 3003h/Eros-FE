import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/galleryItem.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/pages/gallery_detail/gallery_detail_widget.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

const double kHeaderHeight = 200.0;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryDetailPage extends StatelessWidget {
  GalleryDetailPage({Key key}) : super(key: key);

  final ScrollController _controller = ScrollController();

  /// 异步请求数据
  Future<GalleryItem> _loadData(BuildContext context) async {
    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);

    final GalleryItem _item = _galleryModel.galleryItem;

    _galleryModel.resetHideNavigationBtn();

    if (!_galleryModel.detailLoadFinish || _item.galleryPreview.isNotEmpty) {
      if (_item.filecount == null || _item.filecount.isEmpty) {
        await Api.getMoreGalleryInfoOne(_item);
      }

      final GalleryItem _galleryItemFromApi =
          await Api.getGalleryDetail(_item.url);

      _galleryModel.currentPreviewPage = 0;
      _item.tagGroup = _galleryItemFromApi.tagGroup;
      _item.galleryComment = _galleryItemFromApi.galleryComment;
      _galleryModel.setGalleryPreview(_galleryItemFromApi.galleryPreview);
      _galleryModel.setFavTitle(_galleryItemFromApi.favTitle,
          favcat: _galleryItemFromApi.favcat);
      _item.showKey = _galleryItemFromApi.showKey;

      _galleryModel.detailLoadFinish = true;

      return _galleryItemFromApi;
    } else {
      return _item;
    }
  }

  // 滚动监听
  void _controllerLister(BuildContext context) {
    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);

    if (_controller.offset < kHeaderHeight + kHeaderPaddingTop &&
        !_galleryModel.hideNavigationBtn) {
      _galleryModel.hideNavigationBtn = true;
    } else if (_controller.offset >= kHeaderHeight + kHeaderPaddingTop &&
        _galleryModel.hideNavigationBtn) {
      _galleryModel.hideNavigationBtn = false;
    }
  }

  _initData(BuildContext context) {
    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    _galleryModel.resetHideNavigationBtn();
  }

  @override
  Widget build(BuildContext context) {
    _initData(context);

    _controller.addListener(() => _controllerLister(context));

    final Widget sliverSa = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _controller,
      slivers: <Widget>[
        SliverSafeArea(
          bottom: false,
          sliver: SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _buildGalletyHead(context),
                Container(
                  height: 0.5,
                  color: CupertinoColors.systemGrey4,
                ),
                _buildDetail(context),
              ],
            ),
          ),
        ),
      ],
    );

    /// 因为 CupertinoNavigationBar的特殊 不能直接用Selector包裹控制build 所以在
    /// CupertinoPageScaffold 外层加了 Selector , hideNavigationBtn变化才会重绘
    /// 内容作为 child 缓存避免重绘
    ///
    /// 增加 oriGalleryPreview 变化时可重绘的控制
    final Widget cps = Selector<GalleryModel, Tuple2<bool, bool>>(
      selector: (context, galleryModel) => Tuple2(
          galleryModel.hideNavigationBtn,
          galleryModel.oriGalleryPreview.isNotEmpty),
      shouldRebuild: (pre, next) =>
          pre.item1 != next.item1 || pre.item2 != next.item2,
      builder: (context, _tuple, child) {
        return CupertinoPageScaffold(
          navigationBar:
              _buildNavigationBar(context, hideNavigationBtn: _tuple.item1),
          child: child,
        );
      },
      child: sliverSa,
    );

    return cps;
  }

  Widget _buildDetail(context) {
    return Selector<GalleryModel, bool>(
      selector: (_, GalleryModel gllaeryModel) => gllaeryModel.detailLoadFinish,
      builder: (BuildContext context, bool loadFinish, Widget child) {
        return FutureBuilder<GalleryItem>(
            future: _loadData(context),
            builder:
                (BuildContext context, AsyncSnapshot<GalleryItem> snapshot) {
              if (loadFinish) {
                return child;
              } else {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
//                    Global.logger.v('active');
                    return _buildLoading(context);
                  case ConnectionState.waiting:
//                    Global.logger.v('waiting');
                    return _buildLoading(context);
                  case ConnectionState.done:
                    Global.logger.v('done');
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return child;
                    }
                }
                return null;
              }
            });
      },
      child: const GalleryDetailInfo(),
    );
  }

  Widget _buildLoading(context) {
    // 加载中 显示一个菊花
    return const Padding(
      padding: EdgeInsets.all(18.0),
      child: CupertinoActivityIndicator(
        radius: 15.0,
      ),
    );
  }

  ObstructingPreferredSizeWidget _buildNavigationBar(BuildContext context,
      {bool hideNavigationBtn = true}) {
    return hideNavigationBtn
        ? const CupertinoNavigationBar(
            backgroundColor: ThemeColors.navigationBarBackground,
          )
        : CupertinoNavigationBar(
            backgroundColor: ThemeColors.navigationBarBackground,
            middle: _buildNavigationBarImage(context),
            trailing: _buildNavigationBarReadButton(context),
          );
  }

  /// 独立出导航栏的阅读按钮
  Widget _buildNavigationBarReadButton(BuildContext context) {
    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);

    final bool _hasPreview = _galleryModel.oriGalleryPreview.isNotEmpty;

    final S ln = S.of(context);
    return CupertinoButton(
        child: Text(
          ln.READ,
          style: const TextStyle(fontSize: 15),
        ),
        minSize: 20,
        padding: const EdgeInsets.fromLTRB(15, 2.5, 15, 2.5),
        borderRadius: BorderRadius.circular(50),
        color: CupertinoColors.activeBlue,
        onPressed: _hasPreview
            ? () {
                NavigatorUtil.goGalleryViewPagePr(context, 0);
              }
            : null);
  }

  Widget _buildNavigationBarImage(BuildContext context) {
    final double _statusBarHeight = MediaQuery.of(context).padding.top;
    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);

    return GestureDetector(
      onTap: () {
        _controller.animateTo(0,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      },
      child: Container(
        child: CoveTinyImage(
          imgUrl: _galleryModel.galleryItem.imgUrl,
          statusBarHeight: _statusBarHeight,
        ),
      ),
    );
  }

  Widget _buildGalletyHead(BuildContext context) {
    return GalleryHeader();
  }
}
