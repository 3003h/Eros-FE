import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_main/controller/comment_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/cust_lib/flutter_linkify.dart' as linkify;
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:fehviewer/widget/expandable_linkify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

const int kMaxline = 4;

class CommentItem extends StatelessWidget {
  const CommentItem(
      {Key key, @required this.galleryComment, this.simple = false})
      : super(key: key);
  final GalleryComment galleryComment;
  final bool simple;

  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();
    // final CommentController _commentController = Get.find();

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
      textAlign: TextAlign.left,
      // 对齐方式
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
      maxLines: kMaxline + 1,
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

    final ExpandableLinkify _simpleExpTextLinkify = ExpandableLinkify(
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

    return GetBuilder<CommentController>(
        init: CommentController(),
        id: galleryComment.id ?? 'None',
        builder: (CommentController _commentController) {
          return Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: ClipRRect(
              // 圆角
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: _ehConfigService.isPureDarkTheme.value
                    ? CupertinoDynamicColor.resolve(
                        ThemeColors.commitBackground, context)
                    : CupertinoDynamicColor.resolve(
                        ThemeColors.commitBackgroundGray, context),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _buildUsername(context),
                        const Spacer(),
                        if (!simple)
                          CupertinoTheme(
                            data: const CupertinoThemeData(
                                primaryColor: ThemeColors.commitText),
                            child: Row(
                              children: <Widget>[
                                if (galleryComment.canVote)
                                  CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    minSize: 0,
                                    child: Icon(
                                      galleryComment.vote > 0
                                          ? FontAwesomeIcons.solidThumbsUp
                                          : FontAwesomeIcons.thumbsUp,
                                      size: 14,
                                    ),
                                    onPressed: () {
                                      VibrateUtil.light();
                                      logger.i('vote up ${galleryComment.id}');
                                      _commentController
                                          .commitVoteUp(galleryComment.id);
                                    },
                                  ),
                                if (galleryComment.canVote)
                                  CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    minSize: 0,
                                    child: Icon(
                                      galleryComment.vote < 0
                                          ? FontAwesomeIcons.solidThumbsDown
                                          : FontAwesomeIcons.thumbsDown,
                                      size: 14,
                                    ),
                                    onPressed: () {
                                      VibrateUtil.light();
                                      logger
                                          .i('vote down ${galleryComment.id}');
                                      _commentController
                                          .commitVoteDown(galleryComment.id);
                                    },
                                  ),
                                if (galleryComment.canEdit)
                                  CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    minSize: 0,
                                    child: const Icon(
                                      FontAwesomeIcons.edit,
                                      size: 14,
                                    ),
                                    onPressed: () {
                                      VibrateUtil.light();
                                      logger.i('edit ${galleryComment.id}');
                                    },
                                  ),
                              ],
                            ),
                          ),
                        Text(
                          galleryComment.score,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: CupertinoDynamicColor.resolve(
                                ThemeColors.commitText, context),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                      child: simple ? _simpleExpTextLinkify : _fullTextLinkify,
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
                  ],
                ),
              ),
            ),
          );
        });
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
        logger.v('search uploader:${galleryComment.name}');
        NavigatorUtil.goGalleryListBySearch(
            simpleSearch: 'uploader:${galleryComment.name}');
      },
    );
  }

  Future<void> _onOpen(BuildContext context, LinkableElement link) async {
    logger.v(' ${link.url}');
    final RegExp regExp =
        RegExp(r'https?://e[-x]hentai.org/g/[0-9]+/[0-9a-z]+');
    if (await canLaunch(link.url)) {
      if (regExp.hasMatch(link.url)) {
        logger.v('in ${link.url}');
        NavigatorUtil.goGalleryPage(
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
