import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/galleryItem.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:FEhViewer/widget/blur_image.dart';
import 'package:FEhViewer/widget/rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GalleryItemWidget extends StatefulWidget {
  final int index;
  final GalleryItem galleryItemBean;

  GalleryItemWidget({this.index, this.galleryItemBean});

  @override
  _GalleryItemWidgetState createState() => _GalleryItemWidgetState();
}

class _GalleryItemWidgetState extends State<GalleryItemWidget> {
  Color _colorTap; // 按下时颜色反馈
  double _padL;
  String _title;
  List<String> _simpleTags = [];

  @override
  Widget build(BuildContext context) {
    // Global.logger.v('bulid _GalleryItemWidgetState');
    _padL = 8.0;

    var _isBlur = Global.profile.ehConfig.galleryImgBlur ?? false;

    String _getTitle(bool isJpnTitle) {
      var _titleEn = widget?.galleryItemBean?.englishTitle ?? '';
      var _titleJpn = widget?.galleryItemBean?.japaneseTitle ?? '';

      // 日语标题判断
      var _title = isJpnTitle && _titleJpn != null && _titleJpn.isNotEmpty
          ? _titleJpn
          : _titleEn;

      return _title;
    }

    Widget _buildTitle() {
      return Consumer<EhConfigModel>(
        builder: (BuildContext context, EhConfigModel value, Widget child) {
          _title = _getTitle(value.isJpnTitle);
          return Text(
            _title,
            maxLines: 3,
            textAlign: TextAlign.left, // 对齐方式
            overflow: TextOverflow.ellipsis, // 超出部分省略号
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamilyFallback: [EHConst.FONT_FAMILY]),
          );
        },
      );
    }

    // 标签 Item
    Widget _tagItem(String text) {
      ClipRRect clipRRect = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          // height: 18,
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
          color: Color(0xffeeeeee),
          child: Text(
            text ?? "",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                height: 1,
                fontWeight: FontWeight.normal,
                color: Color(0xff666666),
                fontFamilyFallback: [EHConst.FONT_FAMILY]),
            strutStyle: StrutStyle(height: 1),
          ),
        ),
      );

      return Container(
//      padding: EdgeInsets.all(4),
        child: clipRRect,
      );
    }

    List<Widget> _buildTagItems() {
      List<Widget> tags = [];

      _simpleTags.forEach((tagText) {
        tags.add(_tagItem(tagText));
      });

      return tags;
    }

    Widget _buildTagBox() {
      return Consumer<EhConfigModel>(
        builder: (BuildContext context, EhConfigModel value, Widget child) {
          _simpleTags = value.isTagTranslat
              ? widget.galleryItemBean.simpleTagsTranslat
              : widget.galleryItemBean.simpleTags;
          return Container(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
            child: Wrap(
              spacing: 4, //主轴上子控件的间距
              runSpacing: 4, //交叉轴上子控件之间的间距
              children: _buildTagItems(), //要显示的子控件集合
            ),
          );
        },
      );
    }

    // 封面图片
    Widget _buildImg() {
      return Consumer<EhConfigModel>(
          builder: (BuildContext context, EhConfigModel value, Widget child) {
        _isBlur = value.isGalleryImgBlur;
        return widget?.galleryItemBean?.imgUrl != null
            ? (_isBlur
                ? BlurImage(
                    widget: CachedNetworkImage(
                    imageUrl: widget.galleryItemBean.imgUrl,
                  ))
                : CachedNetworkImage(
                    imageUrl: widget.galleryItemBean.imgUrl,
                  ))
            : Container();
      });
    }

    Color _colorCategory =
        ThemeColors.nameColor[widget?.galleryItemBean?.category ?? "defaule"]
                ["color"] ??
            CupertinoColors.white;

    Widget containerGallery = Container(
      color: _colorTap,
      // height: 200,
      padding: EdgeInsets.fromLTRB(_padL, 8, 8, 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 120.0, //最小高度
          // maxHeight: 200,
        ),
        child: Column(
//        mainAxisAlignment: MainAxisAlignment.start,
//        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Container(
                width: 120,
//                height: 180,
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  // 圆角
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImg(),
                ),
              ),

              // 右侧信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 标题
                    _buildTitle(),
                    // 上传者
                    Text(
                      widget?.galleryItemBean?.uploader ?? '',
                      style: TextStyle(
                          fontSize: 12, color: CupertinoColors.systemGrey),
                    ),

                    // 标签
                    _buildTagBox(),
                    // Spacer(),
                    // 评分和页数
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                          child: StaticRatingBar(
                            size: 20.0,
                            rate: widget.galleryItemBean.rating,
                            radiusRatio: 1.5,
                          ),
                        ),
                        Text(
                          widget?.galleryItemBean?.rating.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        // 占位
                        Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 1),
                              child: Icon(
//                              EHCupertinoIcons.paper_solid,
                                Icons.panorama,
                                size: 13,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                widget?.galleryItemBean?.filecount ?? "",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Container(
                      height: 4,
                    ),
                    // 类型和时间
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                            color: _colorCategory,
                            child: Text(
                              widget?.galleryItemBean?.category ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                height: 1,
                                color: CupertinoColors.white,
//                              backgroundColor: _colorCategory
                              ),
                            ),
                          ),
                        ),

                        // 上传时间
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              widget?.galleryItemBean?.postTime ?? "",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );

    return GestureDetector(
      child: Column(
        children: <Widget>[
          containerGallery,
          _galleryItemDivider(),
        ],
      ),
      // 不可见区域点击有效
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Global.logger.v("title: $_title \n tags: $_simpleTags");
        NavigatorUtil.goGalleryDetail(context, _title, widget.galleryItemBean);
      },
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
  }

  void _updateNormalColor() {
    setState(() {
      _colorTap = CupertinoColors.systemBackground;
    });
  }

  void _updatePressedColor() {
    setState(() {
      _colorTap = CupertinoColors.systemGrey4;
    });
  }

  /// 设置项分隔线
  Widget _galleryItemDivider() {
    return Divider(
      height: 0.5,
      indent: _padL,
      color: CupertinoColors.systemGrey4,
    );
  }
}
