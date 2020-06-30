import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(),
          child: Container(
            margin: const EdgeInsets.only(left: 12),
            child: ListView(
              children: <Widget>[
                _buildGalletyHead(context),
                Container(
                  height: 0.5,
                  color: CupertinoColors.systemGrey4,
                ),
              ],
            ),
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
      margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      child: Column(
        children: [
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 12),
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
                      Text(
                        widget.title,
                        maxLines: 4,
                        textAlign: TextAlign.left, // 对齐方式
                        overflow: TextOverflow.ellipsis, // 超出部分省略号
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamilyFallback: [EHConst.FONT_FAMILY]),
                      ),
                      Text(
                        widget?.galleryItem?.uploader ?? '',
                        maxLines: 1,
                        textAlign: TextAlign.left, // 对齐方式
                        overflow: TextOverflow.ellipsis, // 超出部分省略号
                        style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                            fontFamilyFallback: [EHConst.FONT_FAMILY]),
                      ),
                      Spacer(),
                      Row(
                        children: <Widget>[
                          CupertinoButton(
                              child: Text(
                                ln.READ,
                                style: TextStyle(fontSize: 15),
                              ),
                              minSize: 20,
                              padding:
                                  const EdgeInsets.fromLTRB(15, 2.5, 15, 2.5),
                              borderRadius: BorderRadius.circular(50),
                              color: CupertinoColors.activeBlue,
                              onPressed: () {}),
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
          Row(
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
                      height: 1,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
