import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/ehConfig.dart';
import 'package:FEhViewer/models/galleryItem.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/pages/gallery_detail/gallery_detail_widget.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

const double kHeaderHeight = 200.0 + 52;
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
      _item.imgUrl = _galleryItemFromApi.imgUrl ?? _galleryItemFromApi.imgUrlL;
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

  Future<void> _reloadData(context) async {
    Global.logger.v('_reloadData');
    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);

    _galleryModel.reset();
    _galleryModel.detailLoadFinish = false;
    _galleryModel.isReloading = true;
    await _loadData(context);
    _galleryModel.isReloading = false;
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
    _controller.addListener(() => _controllerLister(context));

    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    _galleryModel.resetHideNavigationBtn();
  }

  @override
  Widget build(BuildContext context) {
    _initData(context);

    /// 因为 CupertinoNavigationBar的特殊 不能直接用Selector包裹控制build 所以在
    /// CupertinoPageScaffold 外层加了 Selector , hideNavigationBtn变化才会重绘
    /// 内容作为 child 缓存避免重绘
    ///
    /// 增加 oriGalleryPreview 变化时可重绘的控制
    final Widget cps = Selector2<GalleryModel, EhConfigModel,
        Tuple4<bool, bool, bool, GalleryItem>>(
      selector: (context, galleryModel, ehconfigModel) => Tuple4(
          galleryModel.hideNavigationBtn,
          galleryModel.oriGalleryPreview.isNotEmpty,
          ehconfigModel.isJpnTitle,
          galleryModel.galleryItem),
      shouldRebuild: (pre, next) =>
          pre.item1 != next.item1 || pre.item2 != next.item2,
      builder: (context, _tuple, child) {
        final bool _hideNavigationBtn = _tuple.item1;
        final bool _isJpnTitle = _tuple.item3;
        final GalleryItem _item = _tuple.item4;

        return CupertinoPageScaffold(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  _isJpnTitle
                      ? _item.englishTitle ?? ''
                      : _item.japaneseTitle ?? '',
                  textAlign: TextAlign.left,
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 12, color: CupertinoColors.systemGrey),
                ),
                middle: _hideNavigationBtn
                    ? null
                    : _buildNavigationBarImage(context),
                trailing: _hideNavigationBtn
                    ? CupertinoButton(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                        minSize: 0,
                        child: const Icon(
                          FontAwesomeIcons.shareAltSquare,
                          size: 26,
                        ),
                        onPressed: () {},
                      )
                    : _buildNavigationBarReadButton(context),
              ),
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await _reloadData(context);
                },
              ),
              child,
            ],
          ),
        );
      },
      child: SliverSafeArea(
        bottom: false,
        sliver: SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              const GalleryHeader(),
              Container(
                height: 0.5,
                color: CupertinoColors.systemGrey4,
              ),
              _buildDetail(context),
            ],
          ),
        ),
      ),
    );

    return cps;
  }

  Widget _buildDetail(context) {
    return Selector<GalleryModel, Tuple2<bool, bool>>(
      selector: (_, GalleryModel gllaeryModel) =>
          Tuple2(gllaeryModel.detailLoadFinish, gllaeryModel.isReloading),
      builder: (BuildContext context, Tuple2 tuple, Widget child) {
        final bool loadFinish = tuple.item1;
        final bool isReloading = tuple.item2;

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
                    return _buildLoading(context, isReloading);
                  case ConnectionState.waiting:
//                    Global.logger.v('waiting');
                    return _buildLoading(context, isReloading);
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

  Widget _buildLoading(context, bool isReloading) {
    // 加载中 显示一个菊花
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: !isReloading
          ? const CupertinoActivityIndicator(
              radius: 15.0,
            )
          : null,
    );
  }

  /*ObstructingPreferredSizeWidget _buildNavigationBar(BuildContext context,
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
  }*/

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
}
