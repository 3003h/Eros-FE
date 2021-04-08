import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/comment_controller.dart';
import 'package:fehviewer/pages/gallery/view/translator_dialog.dart';
import 'package:fehviewer/route/navigator_util.dart';
// import 'package:fehviewer/utils/cust_lib/flutter_linkify.dart' as clif;
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:fehviewer/widget/expandable_linkify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SelectableText;
import 'package:flutter_linkify/flutter_linkify.dart' as clif;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';

const int kMaxline = 4;

class CommentItem extends StatelessWidget {
  const CommentItem(
      {Key? key, required this.galleryComment, this.simple = false})
      : super(key: key);
  final GalleryComment galleryComment;
  final bool simple;

  CommentController get controller => Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();

    Widget _fullText() {
      return clif.SelectableLinkify(
        onOpen: (link) => _onOpen(context, link: link),
        text: galleryComment.text,
//      softWrap: true,
        textAlign: TextAlign.left,
        // 对齐方式
        style: TextStyle(
          fontSize: 14,
          color: CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
        ),
        options: LinkifyOptions(humanize: false),
      );
    }

    /// Text.rich实现图文混排
    /// 文字不能选择操作
    Widget _fullRitchText() {
      return Text.rich(TextSpan(
        children: List<InlineSpan>.from(
            galleryComment.span.map((GalleryCommentSpan e) {
          if (e.imageUrl != null) {
            final Map<String, String> _httpHeaders = {
              'Cookie': Global.profile.user.cookie ?? '',
            };
            return WidgetSpan(
              child: GestureDetector(
                onTap: () => _onOpen(context, url: e.href!),
                child: Container(
                  constraints:
                      const BoxConstraints(maxWidth: 100, maxHeight: 140),
                  child: CachedNetworkImage(
                    httpHeaders: _httpHeaders,
                    imageUrl: e.imageUrl!,
                    placeholder: (_, __) => const CupertinoActivityIndicator(),
                  ),
                ),
              ),
            );
          } else {
            final elements = linkify(
              e.text ?? '',
              options: const LinkifyOptions(humanize: false),
              linkifiers: defaultLinkifiers,
            );

            TextStyle _custStyle = TextStyle(
              fontSize: 14,
              color: CupertinoDynamicColor.resolve(
                  ThemeColors.commitText, context),
            );

            return clif.buildTextSpan(
              elements,
              style: Theme.of(context).textTheme.bodyText2!.merge(_custStyle),
              onOpen: (link) => _onOpen(context, link: link),
              linkStyle: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .merge(_custStyle)
                  .copyWith(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  )
                  .merge(null),
            );
          }
        }).toList()),
      ));
    }

    /// 分段实现混排
    /// 文字可复制 但是只能分段复制
    Widget _fullTextCust() {
      // 首先按照换行进行分组
      final separates = <int>[];
      for (int i = 0; i < galleryComment.span.length; i++) {
        final _span = galleryComment.span[i];
        if (_span.text == '\n') {
          separates.add(i);
        }
      }

      separates.insert(0, -1);
      separates.add(galleryComment.span.length);

      if (separates.length > 2) {
        logger.v('$separates');
      }

      // logger.v('$separates');

      final List<List<GalleryCommentSpan>> _groups = [];
      for (int j = 0; j < separates.length - 1; j++) {
        final _start = separates[j] + 1;
        final _end = separates[j + 1];
        if (_end < _start) {
          continue;
        }

        final _group = galleryComment.span.sublist(_start, _end);
        if (_group.isNotEmpty) {
          _groups.add(_group);
        } else {
          // 空行
          _groups.add([const GalleryCommentSpan(text: '')]);
        }
      }

      // logger.v('${_groups.length}');

      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              List<Widget>.from(_groups.map((List<GalleryCommentSpan> spans) {
            return Wrap(
              children: List<Widget>.from(spans.map((GalleryCommentSpan e) {
                if (e.imageUrl != null) {
                  final Map<String, String> _httpHeaders = {
                    'Cookie': Global.profile.user.cookie ?? '',
                  };

                  return GestureDetector(
                    onTap: () => _onOpen(context, url: e.href!),
                    child: Container(
                      constraints:
                          const BoxConstraints(maxWidth: 100, maxHeight: 140),
                      child: CachedNetworkImage(
                        httpHeaders: _httpHeaders,
                        imageUrl: e.imageUrl!,
                        placeholder: (_, __) =>
                            const CupertinoActivityIndicator(),
                      ),
                    ),
                  );
                } else {
                  return clif.SelectableLinkify(
                    onOpen: (link) => _onOpen(context, link: link),
                    text: e.text ?? '',
                    textAlign: TextAlign.left,
                    // 对齐方式
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoDynamicColor.resolve(
                          ThemeColors.commitText, context),
                    ),
                    options: const LinkifyOptions(humanize: false),
                  );
                }
              }).toList()),
            );
          }).toList()),
        ),
      );
    }

    /// 分段实现混排
    /// 合并文字
    Widget _fullTextCustMergeText() {
      // 首先进行分组

      final List<List<GalleryCommentSpan>> _groups = [];
      /*for (int i = 0; i < galleryComment.span.length; i++) {
        final _span = galleryComment.span[i];
        final _nextSpan = i < galleryComment.span.length - 1
            ? galleryComment.span[i + 1]
            : null;
        final _preSpan = i < galleryComment.span.length - 1 && i != 0
            ? galleryComment.span[i - 1]
            : null;

        final bool _nextOthType = (_span.imageUrl?.isEmpty ?? true) !=
            (_nextSpan?.imageUrl?.isEmpty ?? true);
        final bool _curSpace =
            (_span.imageUrl?.isEmpty ?? true) && _span.text == ' ';

        final bool _pSpace =
            (_preSpan?.imageUrl?.isEmpty ?? true) && _preSpan?.text == ' ';

        logger.v('${_span.toJson()} \n-----\n$_nextOthType  $_curSpace');

        if (_nextSpan != null && _nextOthType && !_curSpace && !_pSpace) {
          _groups.add([_span]);
        } else {
          if (_groups.isNotEmpty) {
            _groups.last.add(_span);
          } else {
            _groups.add([_span]);
          }
        }
      }*/

      for (int i = 0; i < galleryComment.span.length; i++) {
        // 当前片段
        final _span = galleryComment.span[i];

        // 下一个片段
        final _nextSpan = i < galleryComment.span.length - 1
            ? galleryComment.span[i + 1]
            : null;

        // 前一个片段
        final _preSpan = i <= galleryComment.span.length - 1 && i != 0
            ? galleryComment.span[i - 1]
            : null;

        final bool _curIsText = _span.imageUrl?.isEmpty ?? true;
        final bool _preIsText = _preSpan?.imageUrl?.isEmpty ?? true;
        final bool _curIsLast = i == galleryComment.span.length - 1;

        // 前一个是不同类型
        final bool _preOthType = (_span.imageUrl?.isEmpty ?? true) !=
            (_preSpan?.imageUrl?.isEmpty ?? true);

        // 下一个是不同类型
        final bool _nextOthType = (_span.imageUrl?.isEmpty ?? true) !=
            (_nextSpan?.imageUrl?.isEmpty ?? true);

        // 前一个是文本并且换行结尾
        final bool _preEndWithBr = (_preSpan?.imageUrl?.isEmpty ?? true) &&
            (_preSpan?.text?.endsWith('\n') ?? false);

        // 当前span为文本并且换行结尾
        final bool _curSpanEndWithBr = (_span.imageUrl?.isEmpty ?? true) &&
            (_span.text?.endsWith('\n') ?? false);

        // logger.v('${_span.toJson()} '
        //     '\n-----\n'
        //     '下一个类型不同$_nextOthType  当前为文本并且结尾换行$_curSpanEndWithBr\n'
        //     '前一个类型不同$_preOthType 当前为最后一个$_curIsLast');

        if ((!_preIsText && _nextOthType && _curSpanEndWithBr) ||
            (_preIsText && _preEndWithBr) ||
            (_preOthType && _curIsLast)) {
          // logger.v('新分组 -> ${_curIsText ? _span.text : '[image]'} ');
          _groups.add([_span]);
        } else {
          if (_groups.isNotEmpty) {
            // logger.v('追加到末尾分组 -> ${_curIsText ? _span.text : '[image]'} ');
            _groups.last.add(_span);
          } else {
            // logger.v('新分组 -> ${_curIsText ? _span.text : '[image]'} ');
            _groups.add([_span]);
          }
        }
      }

      // logger.v('${_groups.length}');

      final TextStyle _commentTextStyle = TextStyle(
        fontSize: 14,
        color: CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            List<Widget>.from(_groups.map((List<GalleryCommentSpan> spans) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List<Widget>.from(spans.map((GalleryCommentSpan e) {
              switch (e.sType) {
                case CommentSpanType.linkText:
                  return Text.rich(TextSpan(
                    text: e.text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .merge(_commentTextStyle)
                        .copyWith(
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                    recognizer: controller.genTapGestureRecognizer()
                      ..onTap = () => _onOpen(context, url: e.href!),
                  )).marginOnly(right: 2);
                case CommentSpanType.text:
                  final String oriText = e.text ?? '';
                  String _text = oriText.endsWith('\n')
                      ? oriText.substring(0, oriText.length - 1)
                      : oriText;

                  _text = _text.startsWith('\n') ? _text.substring(1) : _text;

                  return clif.SelectableLinkify(
                    onOpen: (link) => _onOpen(context, link: link),
                    text: _text,
                    textAlign: TextAlign.left,
                    // 对齐方式
                    style: _commentTextStyle,
                    options: LinkifyOptions(humanize: false),
                  );
                case CommentSpanType.image:
                case CommentSpanType.linkImage:
                  final Map<String, String> _httpHeaders = {
                    'Cookie': Global.profile.user.cookie ?? '',
                  };

                  return GestureDetector(
                    onTap: () => _onOpen(context, url: e.href!),
                    child: Container(
                      constraints:
                          const BoxConstraints(maxWidth: 100, maxHeight: 140),
                      child: CachedNetworkImage(
                        httpHeaders: _httpHeaders,
                        imageUrl: e.imageUrl ?? '',
                        placeholder: (_, __) =>
                            const CupertinoActivityIndicator(),
                      ),
                    ),
                  );
                default:
                  return const SizedBox();
              }
            }).toList()),
          );
        }).toList()),
      );
    }

    final ExpandableLinkify _simpleExpTextLinkify = ExpandableLinkify(
      text: galleryComment.text,
      onOpen: (link) => _onOpen(context, link: link),
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
      expandText: '展开',
      collapseText: '收起',
      colorExpandText:
          CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
    );

    const double kSizeVote = 14.0;
    const double kSizeNotVote = 13.0;
    return GetBuilder<CommentController>(
        init: CommentController(),
        tag: pageCtrlDepth,
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
                        CupertinoTheme(
                          data: const CupertinoThemeData(
                              primaryColor: ThemeColors.commitText),
                          child: Row(
                            children: <Widget>[
                              if (_ehConfigService.commentTrans.value)
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  minSize: 0,
                                  child: Icon(
                                    FontAwesomeIcons.language,
                                    size: kSizeVote,
                                    color: CupertinoDynamicColor.resolve(
                                      ThemeColors.commitText,
                                      context,
                                    ),
                                  ),
                                  onPressed: () {
                                    vibrateUtil.light();
                                    showTranslatorDialog(galleryComment.text);
                                  },
                                ),
                              if (galleryComment.canVote ?? false)
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  minSize: 0,
                                  child: Icon(
                                    galleryComment.vote! > 0
                                        ? FontAwesomeIcons.solidThumbsUp
                                        : FontAwesomeIcons.thumbsUp,
                                    size: galleryComment.vote! > 0
                                        ? kSizeVote
                                        : kSizeNotVote,
                                    color: CupertinoDynamicColor.resolve(
                                      ThemeColors.commitText,
                                      context,
                                    ),
                                  ),
                                  onPressed: () {
                                    vibrateUtil.light();
                                    logger.i('vote up ${galleryComment.id}');
                                    _commentController
                                        .commitVoteUp(galleryComment.id!);
                                  },
                                ),
                              if (galleryComment.canVote ?? false)
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  minSize: 0,
                                  child: Icon(
                                    galleryComment.vote! < 0
                                        ? FontAwesomeIcons.solidThumbsDown
                                        : FontAwesomeIcons.thumbsDown,
                                    size: galleryComment.vote! < 0
                                        ? kSizeVote
                                        : kSizeNotVote,
                                    color: CupertinoDynamicColor.resolve(
                                      ThemeColors.commitText,
                                      context,
                                    ),
                                  ),
                                  onPressed: () {
                                    vibrateUtil.light();
                                    logger.i('vote down ${galleryComment.id}');
                                    _commentController
                                        .commitVoteDown(galleryComment.id!);
                                  },
                                ),
                              if (galleryComment.canEdit ?? false)
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  minSize: 0,
                                  child: Icon(
                                    FontAwesomeIcons.edit,
                                    size: kSizeNotVote,
                                    color: CupertinoDynamicColor.resolve(
                                      ThemeColors.commitText,
                                      context,
                                    ),
                                  ),
                                  onPressed: () {
                                    vibrateUtil.light();
                                    logger.i('edit ${galleryComment.id}');
                                    _commentController.editComment(
                                      id: galleryComment.id!,
                                      oriComment: galleryComment.text,
                                    );
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
                      child: simple
                          ? _simpleExpTextLinkify
                          : _fullTextCustMergeText(),
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

  Future<void> _onOpen(BuildContext context,
      {LinkableElement? link, String? url}) async {
    vibrateUtil.light();

    final String? _openUrl = url ?? link?.url;
    final RegExp regExp =
        RegExp(r'https?://e[-x]hentai.org/g/[0-9]+/[0-9a-z]+/?');
    if (await canLaunch(_openUrl!)) {
      if (regExp.hasMatch(_openUrl)) {
        final String? _realUrl = regExp.firstMatch(_openUrl)?.group(0);
        logger.v('in $_realUrl');
        NavigatorUtil.goGalleryPage(
          url: _realUrl,
        );
      } else {
        await launch(_openUrl);
      }
    } else {
      throw 'Could not launch $_openUrl';
    }
  }
}
