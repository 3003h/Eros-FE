import 'package:FEhViewer/model/gallery.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 收藏夹选择单项
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
    Color _colorCategory =
        ThemeColors.nameColor[widget?.galleryItemBean?.category ?? "defaule"]
                ["color"] ??
            CupertinoColors.white;

    Widget container = Container(
      color: _colorTap,
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
//        mainAxisAlignment: MainAxisAlignment.start,
//        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            // 图片容器
            Container(
              width: 140,
//              height: 180,
//              color: CupertinoColors.systemGrey6,
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                // 圆角
                borderRadius: BorderRadius.circular(8),
                child: widget?.galleryItemBean?.imgUrl != null
                    ? CachedNetworkImage(
                        imageUrl: widget.galleryItemBean.imgUrl,
                      )
                    : Container(),
              ),
            ),
            // 右侧信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 标题
                  Text(
                    widget?.galleryItemBean?.japanese_title ?? '',
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
                  // tags
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Wrap(
                      spacing: 4, //主轴上子控件的间距
                      runSpacing: 4, //交叉轴上子控件之间的间距
                      children:
                          _getTagItems(widget.galleryItemBean), //要显示的子控件集合
                    ),
                  ),
                  // 评分和页数
                  Row(),
                  // 类型和时间
                  Row(
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
                                fontSize: 14,
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
        debugPrint("fav tap ${widget.index}");
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
      height: 1.0,
      indent: 148,
      color: CupertinoColors.systemGrey,
    );
  }

  // tag Item
  Widget _tagItem(String text) {
    ClipRRect clipRRect = ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
        color: Color(0xffeeeeee),
        child: Text(
          text ?? "",
          style: TextStyle(
            fontSize: 11,
//            color: CupertinoColors.white,
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
    if (galleryItemBean.tags != null) {
      galleryItemBean.tags.forEach((tagText) {
        tags.add(_tagItem(tagText));
      });
    }

    return tags;
  }
}
