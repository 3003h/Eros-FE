import 'package:FEhViewer/fehviewer/model/gallery.dart';
import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/values/storages.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:FEhViewer/widget/blur_image.dart';
import 'package:FEhViewer/widget/rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GalleryItemWidget extends StatefulWidget {
  final int index;
  final GalleryItemBean galleryItemBean;

  GalleryItemWidget({this.index, this.galleryItemBean});

  @override
  _GalleryItemWidgetState createState() => _GalleryItemWidgetState();
}

class _GalleryItemWidgetState extends State<GalleryItemWidget> {
  Color _colorTap;

  @override
  Widget build(BuildContext context) {
    var _isBlur = StorageUtil().getBool(ENABLE_IMG_BLUR);

    var _title_en = widget?.galleryItemBean?.english_title ?? '';
    var _title_jpn = widget?.galleryItemBean?.japanese_title ?? '';
    var _ena_jpn = StorageUtil().getBool(ENABLE_JPN_TITLE);

    // 日语标题判断
    var _title = _ena_jpn && _title_jpn != null && _title_jpn.isNotEmpty
        ? _title_jpn
        : _title_en;

    Color _colorCategory =
        ThemeColors.nameColor[widget?.galleryItemBean?.category ?? "defaule"]
                ["color"] ??
            CupertinoColors.white;

    // 封面图片
    Widget _gaImage = widget?.galleryItemBean?.imgUrl != null
        ? (_isBlur
            ? BlurImage(
                widget: CachedNetworkImage(
                imageUrl: widget.galleryItemBean.imgUrl,
              ))
            : CachedNetworkImage(
                imageUrl: widget.galleryItemBean.imgUrl,
              ))
        : Container();

    Widget container = Container(
      color: _colorTap,
      padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Column(
//        mainAxisAlignment: MainAxisAlignment.start,
//        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
//                minWidth: double.infinity, //宽度尽可能大
                minHeight: 70.0, //最小高度
//                maxHeight: 180,
//                maxWidth: 140,
              ),
              // 图片容器
              child: Container(
                width: 120,
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  // 圆角
                  borderRadius: BorderRadius.circular(8),
                  child: _gaImage,
                ),
              ),
            ),

            // 右侧信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 标题
                  Text(
                    _title,
                    maxLines: 3,
                    textAlign: TextAlign.left, // 对齐方式
                    overflow: TextOverflow.ellipsis, // 超出部分省略号
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  // 上传者
                  Text(
                    widget?.galleryItemBean?.uploader ?? '',
                    style: TextStyle(
                        fontSize: 12, color: CupertinoColors.systemGrey),
                  ),

                  // 标签
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
                    child: Wrap(
                      spacing: 4, //主轴上子控件的间距
                      runSpacing: 4, //交叉轴上子控件之间的间距
                      children:
                          _getTagItems(widget.galleryItemBean), //要显示的子控件集合
                    ),
                  ),

//                  Expanded(child: Container(),),

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
                      Expanded(
                        child: Container(),
                      ),
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
                          padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                          color: _colorCategory,
                          child: Text(
                            widget?.galleryItemBean?.category ?? "",
                            style: TextStyle(
                              fontSize: 14,
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
    );

    return GestureDetector(
      child: Column(
        children: <Widget>[
          container,
          _galleryItemDivider(),
        ],
      ),
      // 不可见区域点击有效
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint("title: ${_title}");
        // 返回 并带上参数
//        NavigatorUtil.goBackWithParams(context, widget.galleryItemBean);
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
      indent: 18,
      color: CupertinoColors.systemGrey4,
    );
  }

  // tag Item
  Widget _tagItem(String text) {
    ClipRRect clipRRect = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 18,
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        color: Color(0xffeeeeee),
        child: Text(
          text ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xff666666),
//              fontFamilyFallback: ['PingFang','NotoSansSC']
          ),
        ),
      ),
    );

    return Container(
//      padding: EdgeInsets.all(4),
      child: clipRRect,
    );
  }

  List<Widget> _getTagItems(GalleryItemBean galleryItemBean) {
    List<Widget> tags = [];
    if (galleryItemBean.simpleTags != null) {
      galleryItemBean.simpleTags.forEach((tagText) {
        tags.add(_tagItem(tagText));
      });
    }

    return tags;
  }
}
