import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/cust_lib/flutter_linkify.dart' as linkify;
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

const kMaxline = 4;

class CommentItem extends StatelessWidget {
  const CommentItem(
      {Key key, @required this.galleryComment, this.simple = false})
      : super(key: key);
  final GalleryComment galleryComment;
  final bool simple;

  @override
  Widget build(BuildContext context) {
    final Text _fullText = Text(
      galleryComment.context,
      softWrap: true,
      textAlign: TextAlign.left, // 对齐方式
      style: const TextStyle(
        fontSize: 14,
      ),
    );

    final linkify.SelectableLinkify _fullTextLinkify =
        linkify.SelectableLinkify(
      onOpen: (link) => _onOpen(context, link),
      text: galleryComment.context,
//      softWrap: true,
      textAlign: TextAlign.left, // 对齐方式
      style: TextStyle(
        fontSize: 14,
        color: CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
      ),
      options: LinkifyOptions(humanize: false),
    );

    final Text _simpleText = Text(
      galleryComment.context,
      maxLines: kMaxline,
      softWrap: true,
      textAlign: TextAlign.left,
      // 对齐方式
      overflow: TextOverflow.ellipsis,
      // 超出部分省略号
      style: const TextStyle(
        fontSize: 13,
      ),
    );

    final Linkify _simpleTextLinkify = Linkify(
      text: galleryComment.context,
      onOpen: (link) => _onOpen(context, link),
      options: LinkifyOptions(humanize: false),
      maxLines: kMaxline,
      softWrap: true,
      textAlign: TextAlign.left,
      // 对齐方式
      overflow: TextOverflow.ellipsis,
      // 超出部分省略号
      style: TextStyle(
        fontSize: 13,
        color: CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
      ),
    );

    return Container(
//      height: 50,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ClipRRect(
        // 圆角
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: CupertinoDynamicColor.resolve(
              ThemeColors.commitBackground, context),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  _buildUsername(context),
                  const Spacer(),
                  Text(
                    galleryComment.score,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: CupertinoDynamicColor.resolve(
                          ThemeColors.commitText, context),
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
                  fontWeight: FontWeight.w600,
                  color: CupertinoDynamicColor.resolve(
                      ThemeColors.commitText, context),
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

  Widget _buildUsername(BuildContext context) {
    return GestureDetector(
      child: Text(
        galleryComment.name,
        style: const TextStyle(
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

  Future<void> _onOpen(BuildContext context, LinkableElement link) async {
    Global.logger.v('${link.url}');
    final RegExp regExp =
        RegExp(r'https?://e[-x]hentai.org/g/[0-9]+/[0-9a-z]+');
    if (await canLaunch(link.url)) {
      if (regExp.hasMatch(link.url)) {
        Global.logger.v('in ${link.url}');
        NavigatorUtil.goGalleryDetailPr(
          context,
          url: link.url,
        );
      } else {
        await launch(link.url);
      }
    } else {
      throw 'Could not launch $link';
    }
  }
}
