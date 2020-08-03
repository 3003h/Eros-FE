import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/galleryItem.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/pages/gallery_detail/gallery_detail_widget.dart';
import 'package:FEhViewer/pages/gallery_detail/gallery_favcat.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:FEhViewer/widget/rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

const kHeaderHeight = 200.0;
const kHeaderPaddingTop = 12.0;

class GalleryDetailPage extends StatelessWidget {
  GalleryDetailPage({Key key}) : super(key: key);

  final ScrollController _controller = ScrollController();

  /// 异步请求数据
  Future<GalleryItem> _loadData(BuildContext context) async {
    final _galleryModel = Provider.of<GalleryModel>(context, listen: false);
    _galleryModel.resetHideNavigationBtn();
    if (!_galleryModel.detailLoadFinish) {
      var _galleryItemFromApi =
          await Api.getGalleryDetail(_galleryModel.galleryItem.url);

      _galleryModel.currentPreviewPage = 0;
      _galleryModel.galleryItem.tagGroup = _galleryItemFromApi.tagGroup;
      _galleryModel.galleryItem.galleryComment =
          _galleryItemFromApi.galleryComment;
      _galleryModel.setGalleryPreview(_galleryItemFromApi.galleryPreview);
      _galleryModel.setFavTitle(_galleryItemFromApi.favTitle,
          favcat: _galleryItemFromApi.favcat);
      _galleryModel.galleryItem.showKey = _galleryItemFromApi.showKey;

      _galleryModel.detailLoadFinish = true;

      return _galleryItemFromApi;
    } else {
      return _galleryModel.galleryItem;
    }
  }

  // 滚动监听
  void _controllerLister(BuildContext context) {
    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
//    _galleryModel.resetHideNavigationBtn();

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
//    Global.logger.v('build GalleryDetailPageLess');
    _initData(context);

    _controller.addListener(() => _controllerLister(context));

    /// 因为 CupertinoNavigationBar的特殊 不能直接用Selector包裹控制build 所以在
    /// CupertinoPageScaffold 外层加了 Selector , hideNavigationBtn变化才会重绘
    /// 内容作为 child 缓存避免重绘
    ///
    /// 增加 oriGalleryPreview 变化时可重绘的控制
    Widget cupertinoTabScaffold = Selector<GalleryModel, Tuple2<bool, bool>>(
      selector: (context, galleryModel) => Tuple2(
          galleryModel.hideNavigationBtn,
          galleryModel.oriGalleryPreview.isNotEmpty),
      shouldRebuild: (pre, next) =>
          pre.item1 != next.item1 || pre.item2 != next.item2,
      builder: (BuildContext context, _tuple, child) {
        return CupertinoPageScaffold(
          navigationBar:
              _buildNavigationBar(context, hideNavigationBtn: _tuple.item1),
          child: child,
        );
      },
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 12),
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            controller: _controller,
            dragStartBehavior: DragStartBehavior.down,
            children: <Widget>[
              _buildGalletyHead(),
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

    return cupertinoTabScaffold;
  }

  Widget _buildDetail(context) {
    return Selector<GalleryModel, bool>(
      selector: (_, gllaeryModel) => gllaeryModel.detailLoadFinish,
      builder: (context, loadFinish, child) {
        return FutureBuilder<GalleryItem>(
            future: _loadData(context),
            builder: (context, snapshot) {
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
      child: _buildLoadSuccessful(),
    );
  }

  Widget _buildLoading(context) {
    // 加载中 显示一个菊花
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: CupertinoActivityIndicator(
        radius: 15.0,
      ),
    );
  }

  Widget _buildLoadSuccessful() {
    // 加载完成 显示内容
    return GalleryDetailInfo();
  }

  ObstructingPreferredSizeWidget _buildNavigationBar(BuildContext context,
      {bool hideNavigationBtn = true}) {
    return hideNavigationBtn
        ? CupertinoNavigationBar()
        : CupertinoNavigationBar(
            middle: _buildNavigationBarImage(context),
            trailing: _buildNavigationBarReadButton(context),
          );
  }

  /// 独立出导航栏的阅读按钮
  Widget _buildNavigationBarReadButton(BuildContext context) {
    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);

    var _hasPreview = _galleryModel.oriGalleryPreview.isNotEmpty;

    var ln = S.of(context);
    return CupertinoButton(
        child: Text(
          ln.READ,
          style: TextStyle(fontSize: 15),
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
    double _statusBarHeight = MediaQuery.of(context).padding.top;
    final GalleryModel _galleryModel =
        Provider.of<GalleryModel>(context, listen: false);

    return GestureDetector(
      onTap: () {
        _controller.animateTo(0,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      },
      child: Container(
        child: CoveTinyImage(
          imgUrl: _galleryModel.galleryItem.imgUrl,
          statusBarHeight: _statusBarHeight,
        ),
      ),
    );
  }

  Widget _buildGalletyHead() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, kHeaderPaddingTop, 12, 12),
      child: Column(
        children: [
          Container(
            height: kHeaderHeight,
            child: Row(
              children: <Widget>[
                // 封面
                _buildCoverImage(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 标题
                      GalleryTitle(),
                      // 上传用户
                      GalleryUploader(),
                      Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          // 阅读按钮
                          _buildReadButton(),
                          Spacer(),
                          // 收藏按钮
                          GalleryFavButton(),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: <Widget>[
                // 评分
                GalleryRating(),
                Spacer(),
                // 类型
                GalleryCategory(),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// 封面图片
  Widget _buildCoverImage() {
    const kWidth = 145.0;

    //
    return Selector<GalleryModel, GalleryModel>(
        shouldRebuild: (pre, next) => false,
        selector: (context, provider) => provider,
        builder: (context, GalleryModel galleryModel, child) {
          final _item = galleryModel.galleryItem;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: kWidth,
//                  height: _getHeigth(),
//                  color: CupertinoColors.systemGrey6,
                child: Hero(
                  tag: '${_item.url}_cover_${galleryModel.tabIndex}',
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        child: CachedNetworkImage(
                          imageUrl: _item.imgUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildReadButton() {
    return Selector<GalleryModel, bool>(
        selector: (context, provider) => provider.oriGalleryPreview.length > 0,
        builder: (context, value, child) {
          var ln = S.of(context);
          return CupertinoButton(
              child: Text(
                ln.READ,
                style: TextStyle(fontSize: 15),
              ),
              minSize: 20,
              padding: const EdgeInsets.fromLTRB(15, 2.5, 15, 2.5),
              borderRadius: BorderRadius.circular(50),
              color: CupertinoColors.activeBlue,
              onPressed: value
                  ? () {
                      NavigatorUtil.goGalleryViewPagePr(context, 0);
                    }
                  : null);
        });
  }
}

/// 类别 点击可跳转搜索
class GalleryCategory extends StatelessWidget {
  const GalleryCategory({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GalleryModel, String>(
        selector: (_, galleryModel) => galleryModel.galleryItem.category ?? '',
        builder: (context, category, _) {
          final Color _colorCategory =
              (ThemeColors.nameColor[category ?? 'defaule']['color'] ??
                  CupertinoColors.white) as Color;

          return GestureDetector(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                color: _colorCategory,
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14.5,
                    // height: 1.1,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
            onTap: () {
              final iCat = EHConst.cats[category];
              final cats = EHConst.sumCats - iCat;
              NavigatorUtil.goGalleryList(context, cats: cats);
            },
          );
        });
  }
}

class GalleryRating extends StatelessWidget {
  const GalleryRating({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GalleryModel, double>(
        selector: (_, GalleryModel galleryModel) =>
            galleryModel.galleryItem.rating as double ?? 0.0,
        builder: (context, rating, _) {
          return Row(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text('$rating')),
              // 星星
              StaticRatingBar(
                size: 18.0,
                rate: rating,
                radiusRatio: 1.5,
              ),
            ],
          );
        });
  }
}

/// 上传用户
class GalleryUploader extends StatelessWidget {
  const GalleryUploader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<GalleryModel, String>(
        selector: (_, galleryModel) => galleryModel.galleryItem.uploader,
        builder: (context, uploader, _) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.only(top: 8, right: 8, bottom: 4),
              child: Text(
                uploader,
                maxLines: 1,
                textAlign: TextAlign.left, // 对齐方式
                overflow: TextOverflow.ellipsis, // 超出部分省略号
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.brown,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () {
              Global.logger.v('search uploader:$uploader');
              NavigatorUtil.goGalleryList(context,
                  simpleSearch: 'uploader:$uploader');
            },
          );
        });
  }
}

/// 标题
class GalleryTitle extends StatelessWidget {
  const GalleryTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// 构建标题
    /// [EhConfigModel] eh设置的state 控制显示日文还是英文标题
    /// [GalleryModel] 画廊数据
    ///
    /// 问题 文字如果使用 SelectableText 并且页面拉到比较下方的时候
    /// 在返回列表时会异常 疑似和封面图片的Hero动画有关
    /// 如果修改封面图片的 Hero tag ,即不使用 Hero 动画
    /// 异常则不会出现
    ///
    /// 暂时放弃使用 SelectableText
    return Selector2<EhConfigModel, GalleryModel, String>(
      selector: (context, ehconfig, gallery) {
        var _titleEn = gallery?.galleryItem?.englishTitle ?? '';
        var _titleJpn = gallery?.galleryItem?.japaneseTitle ?? '';

        // 日语标题判断
        var _title =
            ehconfig.isJpnTitle && _titleJpn != null && _titleJpn.isNotEmpty
                ? _titleJpn
                : _titleEn;

        return _title;
      },
      builder: (context, title, child) {
        return GestureDetector(
          child: Text(
            title,
            maxLines: 5,
            textAlign: TextAlign.left, // 对齐方式
            overflow: TextOverflow.ellipsis, // 超出部分省略号
            style: TextStyle(
              textBaseline: TextBaseline.alphabetic,
              height: 1.2,
              fontSize: 16,
              fontWeight: FontWeight.w500,
//            backgroundColor: CupertinoColors.systemGrey3,
//            fontFamilyFallback: EHConst.FONT_FAMILY_FB,
            ),
          ),
        );

        /*return cust.SelectableText(
          title,
          maxLines: 5,
          minLines: 1,
          textAlign: TextAlign.left, // 对齐方式
//          overflow: TextOverflow.ellipsis, // 超出部分省略号
          style: TextStyle(
            textBaseline: TextBaseline.alphabetic,
            height: 1.2,
            fontSize: 16,
            fontWeight: FontWeight.w500,
//            backgroundColor: CupertinoColors.systemGrey3,
//            fontFamilyFallback: EHConst.FONT_FAMILY_FB,
          ),
          scrollPhysics: ClampingScrollPhysics(),
        );*/
      },
    );
  }
}
