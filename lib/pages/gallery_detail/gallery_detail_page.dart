import 'dart:io';

import 'package:FEhViewer/client/parser/gallery_detail_parser.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:FEhViewer/widget/rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GalleryDetailPage extends StatefulWidget {
  final String title;
  final GalleryItem galleryItem;
  GalleryDetailPage({Key key, this.galleryItem, this.title}) : super(key: key);

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  List<Widget> _lisTagGroupW = [];
  GalleryItem _galleryItem;

  bool _loading = false;
  bool _hideNavigationBtn = true;

  final _titleHeight = 200.0;

  ScrollController _controller = new ScrollController();

  _loadData() async {
    setState(() {
      _loading = true;
    });
    _galleryItem =
        await GalleryDetailParser.getGalleryDetail(widget.galleryItem);

    _galleryItem.tagGroup.forEach((tagGroupData) {
      _lisTagGroupW.add(TagGroupW(tagGroupData: tagGroupData));
    });
    setState(() {
      _loading = false;
    });
  }

  // 滚动监听
  void _controllerLister() {
    if (_controller.offset < _titleHeight && !_hideNavigationBtn) {
      setState(() {
        _hideNavigationBtn = true;
      });
    } else if (_controller.offset >= _titleHeight && _hideNavigationBtn) {
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
  Widget build(BuildContext context) {
    double _statusBarHeight = MediaQuery.of(context).padding.top;

    var ln = S.of(context);
    return Container(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: _loading
              ? CupertinoActivityIndicator(
                  // radius: 15.0,
                  )
              : _hideNavigationBtn
                  ? Container()
                  : CoveTinyImage(
                      imgUrl: widget.galleryItem.imgUrl,
                      statusBarHeight: _statusBarHeight,
                    ),
          trailing: _hideNavigationBtn ? Container() : _readButton(ln),
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 12),
          child: ListView(
            controller: _controller,
            children: <Widget>[
              _buildGalletyHead(context),
              Container(
                height: 0.5,
                color: CupertinoColors.systemGrey4,
              ),
              // 标签
              _loading
                  ? Container()
                  : TagBox(
                      lisTagGroup: _lisTagGroupW,
                    ),
              CupertinoButton(
                child: Text('Comment'),
                onPressed: () {
                  NavigatorUtil.goGalleryDetailComment(
                      context, _galleryItem.galleryComment);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalletyHead(BuildContext context) {
    Color _colorCategory = ThemeColors
            .nameColor[widget?.galleryItem?.category ?? "defaule"]["color"] ??
        CupertinoColors.white;
    var ln = S.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 12, 12),
      child: Column(
        children: [
          Container(
            height: _titleHeight,
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
//                minWidth: double.infinity, //宽度尽可能大
                      minWidth: 130.0,
                      maxWidth: 150.0
//                maxWidth: 140,
                      ),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    // color: CupertinoColors.systemGrey6,
                    // width: 130,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.galleryItem.imgUrl,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 标题
                      Text(
                        widget.title,
                        maxLines: 5,
                        textAlign: TextAlign.left, // 对齐方式
                        overflow: TextOverflow.ellipsis, // 超出部分省略号
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          // fontFamilyFallback: EHConst.FONT_FAMILY_FB,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          widget?.galleryItem?.uploader ?? '',
                          maxLines: 1,
                          textAlign: TextAlign.left, // 对齐方式
                          overflow: TextOverflow.ellipsis, // 超出部分省略号
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                            // fontFamilyFallback: [EHConst.FONT_FAMILY],
                          ),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: <Widget>[
                          _readButton(ln),
                          Spacer(),
                          Icon(FontAwesomeIcons.heart)
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text("${widget?.galleryItem?.rating ?? ''}")),
                StaticRatingBar(
                  size: 18.0,
                  rate: widget?.galleryItem?.rating ?? 0,
                  radiusRatio: 1.5,
                ),
                Spacer(),
                ClipRRect(
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  CupertinoButton _readButton(S ln) {
    return CupertinoButton(
        child: Text(
          ln.READ,
          style: TextStyle(fontSize: 15),
        ),
        minSize: 20,
        padding: const EdgeInsets.fromLTRB(15, 2.5, 15, 2.5),
        borderRadius: BorderRadius.circular(50),
        color: CupertinoColors.activeBlue,
        onPressed: () {});
  }
}

/// 一个标签组 第一个是类型
class TagGroupW extends StatelessWidget {
  TagGroupW({
    @required this.tagGroupData,
  });

  final tagGroupData;

  static initTagBtnList(galleryTags) {
    final _isTagTranslat = Global.profile.ehConfig.tagTranslat;
    List<Widget> _tagBtnList = [];
    galleryTags.forEach((tag) {
      _tagBtnList.add(TagButton(
        text: _isTagTranslat ? tag?.tagTranslat ?? '' : tag?.title ?? '',
        onPressed: () {
          Global.logger.v('search type[${tag.type}] tag[${tag.title}]');
        },
      ));
    });
    return _tagBtnList;
  }

  @override
  Widget build(BuildContext context) {
    final _isTagTranslat = Global.profile.ehConfig.tagTranslat;
    final _tagBtnList = initTagBtnList(tagGroupData.galleryTags);
    final _tagType = tagGroupData.tagType;

    Container container = Container(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // tag 分类
          Container(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: TagButton(
              text: _isTagTranslat
                  ? EHConst.translateTagType[_tagType.trim()] ?? _tagType
                  : _tagType,
            ),
          ),
          Expanded(
            child: Container(
              child: Wrap(
                spacing: 4, //主轴上子控件的间距
                runSpacing: 4, //交叉轴上子控件之间的间距
                children: _tagBtnList, //要显示的子控件集合
              ),
            ),
          )
        ],
      ),
    );

    return container;
  }
}

/// 标签按钮
/// onPressed 回调
class TagButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback _onPressed;
  const TagButton({
    @required this.text,
    color,
    VoidCallback onPressed,
  })  : this.color = color ?? Colors.teal,
        _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: Text(
        text,
        style: TextStyle(fontSize: 14, height: 1.3),
        strutStyle: StrutStyle(height: 1),
      ),
      minSize: 5,
      padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
      borderRadius: BorderRadius.circular(50),
      color: color,
      onPressed: _onPressed,
      disabledColor: Colors.blueGrey,
    );
  }
}

/// 包含多个 TagBox
class TagBox extends StatelessWidget {
  final List<Widget> lisTagGroup;
  const TagBox({Key key, this.lisTagGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
          child: Column(children: lisTagGroup),
        ),
        Container(
          height: 0.5,
          color: CupertinoColors.systemGrey4,
        ),
      ],
    );
  }
}

/// 封面小图
class CoveTinyImage extends StatelessWidget {
  final String imgUrl;
  final double statusBarHeight;

  const CoveTinyImage({Key key, this.imgUrl, double statusBarHeight})
      : statusBarHeight = statusBarHeight ?? 44,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var _padding = Platform.isAndroid ? 0.0 : 2.0;
    return Container(
      height: statusBarHeight,
      width: statusBarHeight,
      padding: EdgeInsets.all(_padding),
      child: ClipRRect(
        // 圆角
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: imgUrl,
        ),
      ),
    );
  }
}
