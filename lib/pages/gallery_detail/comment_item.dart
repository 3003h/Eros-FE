import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const kMaxline = 4;

class CommentItem extends StatelessWidget {
  final GalleryComment galleryComment;
  final bool simple;

  const CommentItem(
      {Key key, @required this.galleryComment, this.simple = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _fullText = Text(
      galleryComment.context,
      softWrap: true,
      textAlign: TextAlign.left, // 对齐方式
      style: TextStyle(
        fontSize: 14,
      ),
    );

    var _fullTextLinkify = SelectableLinkify(
      onOpen: _onOpen,
      text: galleryComment.context,
//      softWrap: true,
      textAlign: TextAlign.left, // 对齐方式
      style: TextStyle(
        fontSize: 14,
      ),
      options: LinkifyOptions(humanize: false),
    );

    var _simpleText = Text(
      galleryComment.context,
      maxLines: kMaxline,
      softWrap: true,
      textAlign: TextAlign.left,
      // 对齐方式
      overflow: TextOverflow.ellipsis,
      // 超出部分省略号
      style: TextStyle(
        fontSize: 13,
      ),
    );

    var _simpleTextLinkify = Linkify(
      text: galleryComment.context,
      onOpen: _onOpen,
      options: LinkifyOptions(humanize: false),
      maxLines: kMaxline,
      softWrap: true,
      textAlign: TextAlign.left,
      // 对齐方式
      overflow: TextOverflow.ellipsis,
      // 超出部分省略号
      style: TextStyle(
        fontSize: 13,
      ),
    );

    return Container(
//      height: 50,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ClipRRect(
        // 圆角
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: CupertinoColors.systemGrey6,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  _buildUsername(context),
                  Spacer(),
                  Text(
                    galleryComment.score,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                child: simple ? _simpleTextLinkify : _fullTextLinkify,
              ),
              Text(
                galleryComment.time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54,
                ),
              ),
//          Container(
//            height: 1,
//            color: CupertinoColors.systemGrey4,
//          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsername(context) {
    return GestureDetector(
      child: Text(
        galleryComment.name,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.activeBlue,
        ),
      ),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Global.logger.v('search uploader:${galleryComment.name}');
        NavigatorUtil.goGalleryList(context,
            simpleSearch: 'uploader:${galleryComment.name}');
      },
    );
  }

  Future<void> _onOpen(LinkableElement link) async {
    Global.logger.v('${link.url}');
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }
}
