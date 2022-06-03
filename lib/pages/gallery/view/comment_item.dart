import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/comment_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:fehviewer/widget/eh_network_image.dart';
import 'package:fehviewer/widget/expandable_linkify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SelectableText;
import 'package:flutter_linkify/flutter_linkify.dart' as clif;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

const int kMaxline = 4;
const double kSizeVote = 15.0;
const double kSizeNotVote = 15.0;

class CommentItem extends StatelessWidget {
  const CommentItem(
      {Key? key, required this.galleryComment, this.simple = false})
      : super(key: key);
  final GalleryComment galleryComment;
  final bool simple;

  CommentController get controller => Get.find(tag: pageCtrlTag);

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
        options: const LinkifyOptions(humanize: false),
      );
    }

    /// Text.rich实现图文混排
    /// 文字不能选择操作
    Widget _fullRitchText() {
      return Text.rich(TextSpan(
        children: List<InlineSpan>.from(
            galleryComment.span.map((GalleryCommentSpan e) {
          if (e.imageUrl != null) {
            return WidgetSpan(
              child: GestureDetector(
                onTap: () => _onOpen(context, url: e.href!),
                child: Container(
                  constraints:
                      const BoxConstraints(maxWidth: 100, maxHeight: 140),
                  child: EhNetworkImage(
                    imageUrl: e.imageUrl!,
                    placeholder: (_, __) => const CupertinoActivityIndicator(),
                  ),
                  // child: NetworkExtendedImage(
                  //   url: e.imageUrl ?? '',
                  // ),
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            List<Widget>.from(_groups.map((List<GalleryCommentSpan> spans) {
          return Wrap(
            children: List<Widget>.from(spans.map((GalleryCommentSpan e) {
              if (e.imageUrl != null) {
                return GestureDetector(
                  onTap: () => _onOpen(context, url: e.href!),
                  child: Container(
                    constraints:
                        const BoxConstraints(maxWidth: 100, maxHeight: 140),
                    child: EhNetworkImage(
                      imageUrl: e.imageUrl!,
                      placeholder: (_, __) =>
                          const CupertinoActivityIndicator(),
                    ),
                    // child: NetworkExtendedImage(
                    //   url: e.imageUrl ?? '',
                    // ),
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
                    fontFamilyFallback: EHConst.fontFamilyFallback,
                  ),
                  options: const LinkifyOptions(humanize: false),
                );
              }
            }).toList()),
          );
        }).toList()),
      );
    }

    /// 分段实现混排
    /// 合并文字
    Widget _fullTextCustMergeText(
      List<GalleryCommentSpan> span, {
      bool showTranslate = false,
    }) {
      // 首先进行分组
      final List<List<GalleryCommentSpan>> _groups = [];

      for (int i = 0; i < span.length; i++) {
        // 当前片段
        final _span = span[i];

        // 下一个片段
        final _nextSpan = i < span.length - 1 ? span[i + 1] : null;

        // 前一个片段
        final _preSpan = i <= span.length - 1 && i != 0 ? span[i - 1] : null;

        final bool _curIsText = _span.imageUrl?.isEmpty ?? true;
        final bool _preIsText = _preSpan?.imageUrl?.isEmpty ?? true;
        final bool _curIsLast = i == span.length - 1;

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
        height: 1.2,
        color: CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
        fontFamilyFallback: EHConst.fontFamilyFallback,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            List<Widget>.from(_groups.map((List<GalleryCommentSpan> spans) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children:
                List<Widget>.from(spans.map((GalleryCommentSpan commentSpan) {
              switch (commentSpan.sType) {
                case CommentSpanType.linkText: // 链接文字
                  return Text.rich(TextSpan(
                    text: commentSpan.text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .merge(_commentTextStyle)
                        .copyWith(
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                    recognizer: controller.genTapGestureRecognizer()
                      ..onTap = () => _onOpen(context, url: commentSpan.href!),
                  )).marginOnly(right: 2);
                case CommentSpanType.text: // 普通文字

                  final String oriText = (showTranslate
                          ? commentSpan.translate
                          : commentSpan.text) ??
                      '';
                  String _text = oriText.endsWith('\n')
                      ? oriText.substring(0, oriText.length - 1)
                      : oriText;

                  _text = _text.startsWith('\n') ? _text.substring(1) : _text;

                  return clif.SelectableLinkify(
                    onOpen: (link) => _onOpen(context, link: link),
                    text: _text,
                    textAlign: TextAlign.start,
                    // 对齐方式
                    style: _commentTextStyle,
                    options: const LinkifyOptions(humanize: false),
                  );
                case CommentSpanType.image: // 图片
                case CommentSpanType.linkImage: // 带链接图片

                  return GestureDetector(
                    onTap: () => _onOpen(context, url: commentSpan.href!),
                    child: Container(
                      constraints:
                          const BoxConstraints(maxWidth: 100, maxHeight: 140),
                      child: EhNetworkImage(
                        imageUrl: commentSpan.imageUrl ?? '',
                        placeholder: (_, __) =>
                            const CupertinoActivityIndicator(),
                      ),
                      // child: NetworkExtendedImage(
                      //   url: commentSpan.imageUrl ?? '',
                      // ),
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

    /// 简单布局 可展开 带链接文字
    ExpandableLinkify _simpleExpTextLinkify(
        {bool showTranslate = false, TextStyle? style}) {
      return ExpandableLinkify(
        text:
            showTranslate ? galleryComment.textTranslate : galleryComment.text,
        onOpen: (link) => _onOpen(context, link: link),
        options: const LinkifyOptions(humanize: false),
        maxLines: kMaxline,
        softWrap: true,
        textAlign: TextAlign.left,
        // 对齐方式
        overflow: TextOverflow.ellipsis,
        // 超出部分省略号
        style: style ??
            TextStyle(
              fontSize: 13,
              height: 1.2,
              color: CupertinoDynamicColor.resolve(
                  ThemeColors.commitText, context),
              fontFamilyFallback: EHConst.fontFamilyFallback,
            ),
        expandText: L10n.of(context).expand,
        collapseText: L10n.of(context).collapse,
        colorExpandText:
            CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
      );
    }

    /// 解析回复的评论
    final reptyComment = controller.parserCommentRepty(galleryComment);

    /// 评论item
    return GetBuilder<CommentController>(
        init: CommentController(),
        tag: pageCtrlTag,
        id: galleryComment.id ?? 'None',
        builder: (CommentController _commentController) {
          return GestureDetector(
            onLongPress: () =>
                _showScoreDeatil(galleryComment.scoreDetails, context),
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                // 圆角
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: ehTheme.commentBackgroundColor,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildHeader(context, _commentController),
                      if (galleryComment.id != '0' && reptyComment != null)
                        buildReply(context, reptyComment: reptyComment),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                        child: simple
                            ? _simpleExpTextLinkify(
                                showTranslate:
                                    galleryComment.showTranslate ?? false)
                            : _fullTextCustMergeText(galleryComment.span,
                                showTranslate:
                                    galleryComment.showTranslate ?? false),
                      ),
                      buildTail(
                        context,
                        _commentController,
                        showRepty: galleryComment.id != '0' && !simple,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget buildReply(BuildContext context,
      {required GalleryComment reptyComment}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ehTheme.commentReplyBackgroundColor,
      ),
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildUsername(
                name: reptyComment.name,
                fontSize: 12,
              ).paddingOnly(bottom: 6),
            ],
          ),
          Text(
            reptyComment.text,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: CupertinoDynamicColor.resolve(
                  ThemeColors.commitText, context),
              fontFamilyFallback: EHConst.fontFamilyFallback,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTail(
    BuildContext context,
    CommentController commentController, {
    bool showRepty = false,
  }) {
    return Row(
      children: [
        Text(
          galleryComment.time,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color:
                CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
          ),
        ),
        const Spacer(),
        if (showRepty)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minSize: 0,
            child: Icon(
              FontAwesomeIcons.reply,
              size: 15,
              color: CupertinoDynamicColor.resolve(
                ThemeColors.commitText,
                context,
              ),
            ),
            onPressed: () {
              vibrateUtil.light();
              logger.i('rep ${galleryComment.id}');
              commentController.reptyComment(
                  reptyCommentId: galleryComment.id!);
            },
          ),
      ],
    );
  }

  Widget buildHeader(
    BuildContext context,
    CommentController commentController,
  ) {
    final EhConfigService _ehConfigService = Get.find();

    return Row(
      children: <Widget>[
        _buildUsername(),
        const Spacer(),
        CupertinoTheme(
          data: const CupertinoThemeData(primaryColor: ThemeColors.commitText),
          child: Row(
            children: <Widget>[
              // 翻译
              if (_ehConfigService.commentTrans.value)
                CupertinoTheme(
                  data: ehTheme.themeData!,
                  child: TranslateButton(
                    galleryComment: galleryComment,
                    commentController: commentController,
                  ),
                ),
              // 点赞
              if (galleryComment.canVote ?? false)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minSize: 0,
                  child: Icon(
                    galleryComment.vote! > 0
                        ? FontAwesomeIcons.solidThumbsUp
                        : FontAwesomeIcons.thumbsUp,
                    size: galleryComment.vote! > 0 ? kSizeVote : kSizeNotVote,
                    color: CupertinoDynamicColor.resolve(
                      ThemeColors.commitText,
                      context,
                    ),
                  ),
                  onPressed: () {
                    vibrateUtil.light();
                    logger.i('vote up ${galleryComment.id}');
                    commentController.commitVoteUp(galleryComment.id!);
                  },
                ),
              // 点踩
              if (galleryComment.canVote ?? false)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minSize: 0,
                  child: Icon(
                    galleryComment.vote! < 0
                        ? FontAwesomeIcons.solidThumbsDown
                        : FontAwesomeIcons.thumbsDown,
                    size: galleryComment.vote! < 0 ? kSizeVote : kSizeNotVote,
                    color: CupertinoDynamicColor.resolve(
                      ThemeColors.commitText,
                      context,
                    ),
                  ),
                  onPressed: () {
                    vibrateUtil.light();
                    logger.i('vote down ${galleryComment.id}');
                    commentController.commitVoteDown(galleryComment.id!);
                  },
                ),
              // 编辑回复
              if ((galleryComment.canEdit ?? false) && !simple)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    commentController.editComment(
                      id: galleryComment.id!,
                      oriComment: galleryComment.text,
                    );
                  },
                ),
            ],
          ),
        ),
        // 分值
        if (galleryComment.score.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 4),
            child: Icon(
              FontAwesomeIcons.adjust,
              size: kSizeNotVote - 1,
              color: CupertinoDynamicColor.resolve(
                ThemeColors.commitText,
                context,
              ),
            ),
          ),
        Text(
          galleryComment.score.startsWith('+')
              ? '+${galleryComment.score.substring(1)}'
              : galleryComment.score.startsWith('-')
                  ? galleryComment.score
                  : '+${galleryComment.score}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color:
                CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
          ),
        ),
      ],
    );
  }

  Widget _buildUsername({String? name, double? fontSize = 13}) {
    final _name = name ?? galleryComment.name;
    return GestureDetector(
      child: Text(
        name ?? galleryComment.name,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.activeBlue,
        ),
      ),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        logger.v('search uploader:$_name');
        NavigatorUtil.goSearchPageWithText(simpleSearch: 'uploader:$_name');
      },
    );
  }

  /// 打开文本中的url
  Future<void> _onOpen(BuildContext context,
      {LinkableElement? link, String? url}) async {
    vibrateUtil.light();

    final String? _openUrl = url ?? link?.url;
    final RegExp regGalleryUrl =
        RegExp(r'https?://e[-x]hentai.org/g/[0-9]+/[0-9a-z]+/?');
    final RegExp regGalleryPageUrl =
        RegExp(r'https://e[-x]hentai.org/s/([0-9a-z]+)/(\d+)-(\d+)');
    if (await canLaunchUrlString(_openUrl!)) {
      if (regGalleryUrl.hasMatch(_openUrl) ||
          regGalleryPageUrl.hasMatch(_openUrl)) {
        final String? _realUrl = regGalleryUrl.firstMatch(_openUrl)?.group(0) ??
            regGalleryPageUrl.firstMatch(_openUrl)?.group(0);
        logger.d('in $_realUrl');
        NavigatorUtil.goGalleryPage(
          url: _realUrl,
        );
      } else {
        await launchUrlString(_openUrl);
      }
    } else {
      throw 'Could not launch $_openUrl';
    }
  }

  /// 显示评分详情
  void _showScoreDeatil(List<String>? scoreDeatils, BuildContext context) {
    if (scoreDeatils == null || scoreDeatils.isEmpty) {
      return;
    }
    vibrateUtil.light();
    logger.d(scoreDeatils.join('   '));
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        content: Container(
            child: Column(
          children: scoreDeatils
              .map((e) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ))
              .toList(),
        )),
      ),
    );
  }
}

class TranslateButton extends StatefulWidget {
  const TranslateButton({
    Key? key,
    this.sizeVote = kSizeVote,
    required this.galleryComment,
    required this.commentController,
  }) : super(key: key);

  final double sizeVote;
  final GalleryComment galleryComment;
  final CommentController commentController;

  @override
  _TranslateButtonState createState() => _TranslateButtonState();
}

class _TranslateButtonState extends State<TranslateButton> {
  bool translating = false;

  @override
  Widget build(BuildContext context) {
    final _icon = Icon(
      FontAwesomeIcons.language,
      size: widget.sizeVote,
      color: widget.galleryComment.showTranslate ?? false
          ? CupertinoDynamicColor.resolve(
              CupertinoColors.activeBlue,
              context,
            )
          : CupertinoDynamicColor.resolve(
              ThemeColors.commitText,
              context,
            ),
    );

    const _w = CupertinoActivityIndicator(radius: kSizeVote / 2);

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      minSize: 0,
      child: translating ? _w : _icon,
      onPressed: () async {
        vibrateUtil.light();
        setState(() {
          translating = true;
        });
        await widget.commentController
            .commitTranslate(widget.galleryComment.id!);
        setState(() {
          translating = false;
        });
      },
    );
  }
}
