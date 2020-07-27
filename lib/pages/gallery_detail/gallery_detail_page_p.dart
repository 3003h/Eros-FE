import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/pages/gallery_detail/gallery_detail_widget.dart';
import 'package:FEhViewer/pages/gallery_detail/gallery_favcat.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:FEhViewer/widget/rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const kHeaderHeight = 200.0;

class GalleryDetailPagePr extends StatefulWidget {
  final GalleryItem galleryItem;

  GalleryDetailPagePr({
    Key key,
    this.galleryItem,
  }) : super(key: key);

  @override
  _GalleryDetailPagePrState createState() => _GalleryDetailPagePrState();
}

class _GalleryDetailPagePrState extends State<GalleryDetailPagePr> {
  List<Widget> _listTagGroupW = [];
  GalleryItem _galleryItem;

  bool _loading = false;
  bool _hideNavigationBtn = true;

  ScrollController _controller = ScrollController();

  GalleryModel _galleryModel;

  /// 初始化 请求数据
  _loadData() async {
    setState(() {
      _loading = true;
    });
    _galleryItem = await Api.getGalleryDetail(widget.galleryItem);

    _galleryItem.tagGroup.forEach((tagGroupData) {
      _listTagGroupW.add(TagGroupItem(tagGroupData: tagGroupData));
    });
    setState(() {
      _loading = false;
    });
  }

  // 滚动监听
  // 后续考虑用状态管理处理
  void _controllerLister() {
    if (_controller.offset < kHeaderHeight && !_hideNavigationBtn) {
      setState(() {
        _hideNavigationBtn = true;
      });
    } else if (_controller.offset >= kHeaderHeight && _hideNavigationBtn) {
      setState(() {
        _hideNavigationBtn = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _controller.addListener(_controllerLister);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final galleryModel = Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != this._galleryModel) {
      this._galleryModel = galleryModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      child: SafeArea(
        bottom: false,
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
              _buildGalleryDetailInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryDetailInfo() {
    return Container(
      child: _loading
          ? Padding(
              padding: const EdgeInsets.all(18.0),
              child: CupertinoActivityIndicator(
                radius: 15.0,
              ),
            )
          : GalleryDetailInfo(
              listTagGroupW: _listTagGroupW,
              galleryItem: _galleryItem,
            ),
    );
  }

  Widget _buildNavigationBar() {
    var ln = S.of(context);
    double _statusBarHeight = MediaQuery.of(context).padding.top;
    var _tinyImg = _hideNavigationBtn
        ? Container()
        : CoveTinyImage(
            imgUrl: widget.galleryItem.imgUrl,
            statusBarHeight: _statusBarHeight,
          );

    var _navReadButton =
        _hideNavigationBtn ? Container() : _buildReadButton(ln.READ);

    return CupertinoNavigationBar(
      middle: _tinyImg,
      trailing: _navReadButton,
    );
  }

  /// 构建标题
  /// [EhConfigModel] eh设置的state 控制显示日文还是英文标题
  /// [GalleryModel] 画廊数据
  Widget _buildTitle() {
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
        return Text(
          title,
          maxLines: 5,
          textAlign: TextAlign.left, // 对齐方式
          overflow: TextOverflow.ellipsis, // 超出部分省略号
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
//            fontFamilyFallback: EHConst.FONT_FAMILY_FB,
          ),
        );
      },
    );
  }

  Widget _buildGalletyHead() {
    var ln = S.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 12, 12),
      child: Column(
        children: [
          Container(
            height: kHeaderHeight,
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: <Widget>[
                // 封面
                _buildCoverImage(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 标题
                      _buildTitle(),
                      // 上传用户
                      _buildUploaderWidget(),
                      Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          // 阅读按钮
                          _buildReadButton(ln.READ),
                          Spacer(),
                          // 收藏按钮
                          _buildFavIcon(),
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
                _buildRating(),
                Spacer(),
                // 类型
                _buildCategory(),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// 封面图片
  Widget _buildCoverImage() {
    return Selector<GalleryModel, GalleryModel>(
        shouldRebuild: (pre, next) => false,
        selector: (context, provider) => provider,
        builder: (context, GalleryModel provider, child) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150.0),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              child: Hero(
                tag: widget.galleryItem.url + '_cover_${provider.tabIndex}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.galleryItem.imgUrl,
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildCategory() {
    Color _colorCategory = ThemeColors
            .nameColor[widget?.galleryItem?.category ?? "defaule"]["color"] ??
        CupertinoColors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
        color: _colorCategory,
        child: Text(
          widget?.galleryItem?.category ?? '',
          style: TextStyle(
            fontSize: 14.5,
            // height: 1.1,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: <Widget>[
        Container(
            padding: const EdgeInsets.only(right: 8),
            child: Text("${widget?.galleryItem?.rating ?? ''}")),
        // 星星
        StaticRatingBar(
          size: 18.0,
          rate: widget?.galleryItem?.rating ?? 0,
          radiusRatio: 1.5,
        ),
      ],
    );
  }

  Widget _buildFavIcon() {
    return Container(
      child: _loading
          ? Container(
              height: 38,
            )
          : GalleryFavButton(
              favTitle: _galleryItem.favTitle,
              favcat: _galleryItem.favcat,
              gid: widget.galleryItem.gid,
              token: widget.galleryItem.token,
            ),
    );
  }

  Widget _buildUploaderWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(
        widget?.galleryItem?.uploader ?? '',
        maxLines: 1,
        textAlign: TextAlign.left, // 对齐方式
        overflow: TextOverflow.ellipsis, // 超出部分省略号
        style: TextStyle(
          fontSize: 13,
          color: Colors.brown,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReadButton(String text) {
    return CupertinoButton(
        child: Text(
          text,
          style: TextStyle(fontSize: 15),
        ),
        minSize: 20,
        padding: const EdgeInsets.fromLTRB(15, 2.5, 15, 2.5),
        borderRadius: BorderRadius.circular(50),
        color: CupertinoColors.activeBlue,
        onPressed: () {});
  }
}
