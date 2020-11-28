import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/galleryItem.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/models/states/history_model.dart';
import 'package:FEhViewer/models/states/local_favorite_model.dart';
import 'package:FEhViewer/pages/gallery_detail/gallery_detail_widget.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:tuple/tuple.dart';

const double kHeaderHeight = 200.0 + 52;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryDetailPage extends StatefulWidget {
  const GalleryDetailPage({Key key}) : super(key: key);

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  final ScrollController _controller = ScrollController();
  GalleryModel _galleryModel;
  HistoryModel _historyModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;
    }
    final HistoryModel historyModel =
        Provider.of<HistoryModel>(context, listen: false);
    if (historyModel != _historyModel) {
      _historyModel = historyModel;
    }
  }

  /// 异步请求数据
  Future<GalleryItem> _loadData(BuildContext context) async {
    try {
      GalleryItem _item = _galleryModel.galleryItem;

      if (_item.gid != null) {
        Future<void>.delayed(const Duration(milliseconds: 1000))
            .then((_) => {_historyModel.addHistory(_item)});
      }

      // Global.logger.v('${_item.toJson()}');

      _galleryModel.resetHideNavigationBtn();

      // 检查画廊是否包含在本地收藏中
      final bool _localFav =
          _isInLocalFav(context, _galleryModel.galleryItem.gid);
      _item.localFav = _localFav;

      /// 画廊详情内容未获取完毕 或者 画廊缩略对象列表为空的情况
      /// 需要请求网络获取数据
      if (!_galleryModel.detailLoadFinish || _item.galleryPreview.isNotEmpty) {
        if (_item.filecount == null || _item.filecount.isEmpty) {
          await Api.getMoreGalleryInfoOne(_item);
        }

        // final GalleryItem _galleryItemFromApi =
        _item =
            await Api.getGalleryDetail(inUrl: _item.url, inGalleryItem: _item);

        _galleryModel.currentPreviewPage = 0;
        _galleryModel.setGalleryPreview(_item.galleryPreview);
        _galleryModel.setFavTitle(_item.favTitle, favcat: _item.favcat);

        _item.imgUrl = _item.imgUrl ?? _item.imgUrlL;
        /*
        _item.tagGroup = _galleryItemFromApi.tagGroup;
        _item.galleryComment = _galleryItemFromApi.galleryComment;
        _item.showKey = _galleryItemFromApi.showKey;*/

        _galleryModel.detailLoadFinish = true;
      }
      return _item;
    } catch (e, stack) {
      Global.logger.e('解析数据异常\n' + e.toString() + '\n' + stack.toString());
      rethrow;
    }
  }

  bool _isInLocalFav(context, String gid) {
    // 检查是否包含在本地收藏中
    final LocalFavModel localFavModel =
        Provider.of<LocalFavModel>(context, listen: false);
    final int index =
        localFavModel.loacalFavs.indexWhere((GalleryItem element) {
      return element.gid == gid;
    });
    return index >= 0;
  }

  Future<void> _reloadData(context) async {
    Global.logger.v('_reloadData');

    _galleryModel.reset();
    _galleryModel.detailLoadFinish = false;
    _galleryModel.isReloading = true;
    await _loadData(context);
    _galleryModel.isReloading = false;
  }

  void _controllerLister(BuildContext context) {
    if (_controller.offset < kHeaderHeight + kHeaderPaddingTop &&
        !_galleryModel.hideNavigationBtn) {
      _galleryModel.hideNavigationBtn = true;
    } else if (_controller.offset >= kHeaderHeight + kHeaderPaddingTop &&
        _galleryModel.hideNavigationBtn) {
      _galleryModel.hideNavigationBtn = false;
    }
  }

  void _initData(BuildContext context) {
    _controller.addListener(() => _controllerLister(context));

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
        final String _title =
            _isJpnTitle ? _item.englishTitle ?? '' : _item.japaneseTitle ?? '';

        // 主布局
        return CupertinoPageScaffold(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  _title,
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
                        onPressed: () {
                          Global.logger.v('tap shareBtn');
                          Share.share('${_item.url}');
                        },
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
        top: false,
        bottom: false,
        sliver: SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              const GalleryHeader(),
              Container(
                height: 0.5,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey4, context),
              ),
              // 内容
              _buildDetail(context),
            ],
          ),
        ),
      ),
    );

    return cps;
  }

  Widget _buildDetail(context) {
    return Selector<GalleryModel, Tuple3<bool, bool, GalleryItem>>(
      selector: (_, GalleryModel gllaeryModel) => Tuple3(
          gllaeryModel.detailLoadFinish,
          gllaeryModel.isReloading,
          gllaeryModel.galleryItem),
      builder: (BuildContext context, Tuple3 tuple, Widget child) {
        final bool loadFinish = tuple.item1;
        final bool isReloading = tuple.item2;
        final GalleryItem galleryItem = tuple.item3;

        return FutureBuilder<GalleryItem>(
            future: _loadData(context),
            initialData: galleryItem,
            builder:
                (BuildContext context, AsyncSnapshot<GalleryItem> snapshot) {
              if (loadFinish) {
                Future<void>.delayed(const Duration(milliseconds: 100))
                    .then((_) => {_historyModel.addHistory(snapshot.data)});
                return child;
              } else {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return _buildLoading(context, isReloading);
                  case ConnectionState.done:
                    Global.logger.v('done');
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      Future<void>.delayed(const Duration(milliseconds: 100))
                          .then(
                              (_) => {_historyModel.addHistory(snapshot.data)});
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

  /// 独立出导航栏的阅读按钮
  Widget _buildNavigationBarReadButton(BuildContext context) {
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
