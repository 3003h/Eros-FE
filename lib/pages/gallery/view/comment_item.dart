import 'package:fehviewer/common/controller/avatar_controller.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/comment_controller.dart';
import 'package:fehviewer/widget/expandable_linkify.dart';
import 'package:fehviewer/widget/text_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide SelectableText;
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:linkify/linkify.dart';

const int kMaxline = 4;
const double kSizeVote = 15.0;
const double kSizeNotVote = 15.0;

class CommentItem extends StatelessWidget {
  const CommentItem({
    Key? key,
    required this.galleryComment,
    this.simple = false,
  }) : super(key: key);
  final GalleryComment galleryComment;
  final bool simple;

  CommentController get controller => Get.find(tag: pageCtrlTag);

  @override
  Widget build(BuildContext context) {
    /// 解析回复的评论
    final reptyComment = controller.parserCommentRepty(galleryComment);
    final reptyComments = controller.parserAllCommentRepty(galleryComment);

    final TextStyle _commentTextStyle = TextStyle(
      fontSize: 13,
      height: 1.5,
      color: CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
    );

    Widget commentItem;

    commentItem = GetBuilder<CommentController>(
      init: CommentController(),
      tag: pageCtrlTag,
      id: galleryComment.id ?? 'None',
      builder: (_commentController) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ehTheme.commentBackgroundColor,
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CommentHead(
                  commentController: _commentController,
                  galleryComment: galleryComment,
                  simple: simple,
                ),
                if (galleryComment.id != '0' && reptyComment != null)
                  _CommentReply(reptyComments: reptyComments),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: simple
                      ? _buildSimpleExpTextLinkify(
                          context: context,
                          style: _commentTextStyle,
                          showTranslate: galleryComment.showTranslate ?? false,
                        )
                      : buildComment(_commentTextStyle, context),
                ),
                _CommentTail(
                  commentController: _commentController,
                  showRepty: galleryComment.id != '0' && !simple,
                  simple: simple,
                  galleryComment: galleryComment,
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!simple) {
      commentItem = SelectionArea(child: commentItem);
    }

    return commentItem;
  }

  Widget buildComment(
    TextStyle _commentTextStyle,
    BuildContext context, {
    int? maxLines,
  }) {
    if (galleryComment.element == null ||
        galleryComment.element is! dom.Element?) {
      return Container();
    }

    final dom.Element element = galleryComment.element as dom.Element;
    final dom.Element? translateElement =
        galleryComment.translatedElement as dom.Element?;

    final dom.Element showElement = (galleryComment.showTranslate ?? false)
        ? translateElement ?? element
        : element;

    return Text.rich(
      TextSpan(
        style: _commentTextStyle,
        children: showElement.nodes.map((e) => buildCommentTile(e)).toList(),
      ),
      maxLines: maxLines,
    );
  }

  InlineSpan buildCommentTile(dom.Node node) {
    if (node is dom.Text) {
      return TextSpan(text: node.text);
    }

    if (node is! dom.Element) {
      return TextSpan(text: node.text);
    }

    if (node.localName == 'div' && node.attributes['id'] == 'spa') {
      return const TextSpan();
    }

    if (node.localName == 'br') {
      return const TextSpan(text: '\n');
    }

    if (node.localName == 'span') {
      return TextSpan(
        style: _parseTextStyle(node),
        children: node.nodes.map((e) => buildCommentTile(e)).toList(),
      );
    }

    if (node.localName == 'strong') {
      return TextSpan(
        style: const TextStyle(fontWeight: FontWeight.bold),
        children: node.nodes.map((e) => buildCommentTile(e)).toList(),
      );
    }

    if (node.localName == 'em') {
      return TextSpan(
        style: const TextStyle(fontStyle: FontStyle.italic),
        children: node.nodes.map((e) => buildCommentTile(e)).toList(),
      );
    }

    if (node.localName == 'del') {
      return TextSpan(
        style: const TextStyle(decoration: TextDecoration.lineThrough),
        children: node.nodes.map((e) => buildCommentTile(e)).toList(),
      );
    }

    if (node.localName == 'img') {
      final src = node.attributes['src'];
      if (src != null) {
        return WidgetSpan(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 120, maxHeight: 160),
            child: EhNetworkImage(
              imageUrl: src,
              placeholder: (_, __) => const CupertinoActivityIndicator(),
            ),
          ),
        );
      }
    }

    // link
    if (node.localName == 'a') {
      return TextSpan(
        text: node.text, // 不设置会导致recognizer无效
        style: const TextStyle(color: CupertinoColors.activeBlue),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            onOpenUrl(url: node.attributes['href'] ?? '');
          },
        children: node.children.map((e) => buildCommentTile(e)).toList(),
      );
    }

    logger.e('Can not parse $node');
    return TextSpan(text: node.text);
  }

  TextStyle? _parseTextStyle(dom.Element node) {
    final style = node.attributes['style'];
    if (style == null) {
      return null;
    }

    final Map<String, String> styleMap = Map.fromEntries(
      style
          .split(';')
          .map((e) => e.split(':'))
          .where((e) => e.length == 2)
          .map((e) => MapEntry(e[0].trim(), e[1].trim())),
    );

    return TextStyle(
      color: styleMap['color'] == null
          ? null
          : Color(int.parse(styleMap['color']!.substring(1), radix: 16) +
              0xFF000000),
      fontWeight: styleMap['font-weight'] == 'bold' ? FontWeight.bold : null,
      fontStyle: styleMap['font-style'] == 'italic' ? FontStyle.italic : null,
      decoration: styleMap['text-decoration'] == 'underline'
          ? TextDecoration.underline
          : null,
    );
  }

  /// 简单布局 可展开 带链接文字
  Widget _buildSimpleExpTextLinkify({
    bool showTranslate = false,
    TextStyle? style,
    required BuildContext context,
  }) {
    return ExpandableLinkify(
      text: showTranslate ? galleryComment.translatedText : galleryComment.text,
      onOpen: (link) => onOpenUrl(url: link),
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
            color:
                CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
          ),
      expandText: L10n.of(context).expand,
      collapseText: L10n.of(context).collapse,
      colorExpandText:
          CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
    );
  }
}

class _CommentReply extends StatelessWidget {
  const _CommentReply({Key? key, required this.reptyComments})
      : super(key: key);
  final List<GalleryComment?> reptyComments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reptyComments.map((reptyComment) {
        if (reptyComment == null) {
          return const SizedBox.shrink();
        }
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ehTheme.commentReplyBackgroundColor,
          ),
          padding: const EdgeInsets.all(6),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _CommentUser(
                        comment: reptyComment,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                reptyComment.text,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: CupertinoDynamicColor.resolve(
                      ThemeColors.commitText, context),
                  fontFamilyFallback: EHConst.fontFamilyFallback,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CommentTail extends StatelessWidget {
  const _CommentTail({
    Key? key,
    required this.commentController,
    this.showRepty = false,
    required this.galleryComment,
    required this.simple,
  }) : super(key: key);
  final GalleryComment galleryComment;
  final CommentController commentController;
  final bool showRepty;
  final bool simple;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          galleryComment.time,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ehTheme.commitIconColor,
          ),
        ),
        const Spacer(),
        // 编辑回复
        if ((galleryComment.canEdit ?? false) && !simple)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minSize: 0,
            child: Icon(
              FontAwesomeIcons.penToSquare,
              size: kSizeNotVote,
              color: ehTheme.commitIconColor,
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
        // 点赞
        if ((galleryComment.canVote ?? false) && !simple)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minSize: 0,
            child: Icon(
              galleryComment.vote! > 0
                  ? FontAwesomeIcons.solidThumbsUp
                  : FontAwesomeIcons.thumbsUp,
              size: galleryComment.vote! > 0 ? kSizeVote : kSizeNotVote,
              color: ehTheme.commitIconColor,
            ),
            onPressed: () {
              vibrateUtil.light();
              logger.i('vote up ${galleryComment.id}');
              commentController.commitVoteUp(galleryComment.id!);
            },
          ),
        // 点踩
        if ((galleryComment.canVote ?? false) && !simple)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minSize: 0,
            child: Icon(
              galleryComment.vote! < 0
                  ? FontAwesomeIcons.solidThumbsDown
                  : FontAwesomeIcons.thumbsDown,
              size: galleryComment.vote! < 0 ? kSizeVote : kSizeNotVote,
              color: ehTheme.commitIconColor,
            ),
            onPressed: () {
              vibrateUtil.light();
              logger.i('vote down ${galleryComment.id}');
              commentController.commitVoteDown(galleryComment.id!);
            },
          ),
        if (showRepty && !simple && commentController.isLogin)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minSize: 0,
            child: Icon(
              // FontAwesomeIcons.reply,
              // FontAwesomeIcons.at,
              FontAwesomeIcons.message,
              size: 15,
              color: ehTheme.commitIconColor,
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
}

class _CommentUser extends StatelessWidget {
  const _CommentUser({
    Key? key,
    required this.comment,
    this.fontSize = 13,
    this.avatarSize = 28,
  }) : super(key: key);

  final GalleryComment comment;
  final double fontSize;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final EhSettingService _ehSettingService = Get.find();
    final AvatarController avatarController = Get.find();

    final _name = comment.name;
    final _userId = comment.memberId ?? '0';
    final _commentId = comment.id ?? '0';
    final _future = avatarController.getUser(_userId);

    final _placeHold = Obx(() {
      final radius = _ehSettingService.avatarBorderRadiusType ==
              AvatarBorderRadiusType.roundedRect
          ? 8.0
          : avatarSize / 2;

      return _ehSettingService.avatarType == AvatarType.boringAvatar
          ? BoringAvatars(
              name: _name,
              colors: [...ThemeColors.catColorList],
              type: _ehSettingService.boringAvatarsType,
              square: true,
            )
          : TextAvatar(
              name: _name,
              colors: [...ThemeColors.catColorList],
              type: _ehSettingService.textAvatarsType,
              radius: radius,
            );
    });

    void tapName() {
      logger.t('search uploader:$_name');
      NavigatorUtil.goSearchPageWithParam(simpleSearch: 'uploader:$_name');
    }

    return Obx(() {
      final avatarUrl = avatarController.getAvatarUrl(_userId);
      final radius = _ehSettingService.avatarBorderRadiusType ==
              AvatarBorderRadiusType.roundedRect
          ? 8.0
          : avatarSize / 2;
      return GestureDetector(
        onTap: tapName,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_ehSettingService.showCommentAvatar)
              Container(
                width: avatarSize,
                height: avatarSize,
                margin: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? EhNetworkImage(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _placeHold,
                          errorWidget: (_, __, ___) => _placeHold,
                        )
                      : FutureBuilder<User?>(
                          future: _future,
                          builder: (context, snapshot) {
                            late final String? avatarUrl;
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              avatarUrl = snapshot.data?.avatarUrl;
                              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                                return EhNetworkImage(
                                  imageUrl: avatarUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => _placeHold,
                                  errorWidget: (_, __, ___) => _placeHold,
                                );
                              } else {
                                return _placeHold;
                              }
                            } else {
                              return _placeHold;
                            }
                          }),
                ),
              ),
            Text(
              _name,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CommentHead extends StatelessWidget {
  const _CommentHead({
    Key? key,
    required this.commentController,
    required this.galleryComment,
    required this.simple,
  }) : super(key: key);
  final CommentController commentController;
  final GalleryComment galleryComment;
  final bool simple;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: _CommentUser(comment: galleryComment)),
        if (galleryComment.id != '0' && !simple)
          GestureDetector(
            onTap: () => _showScoreDetail(galleryComment.scoreDetails, context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 分值
                Container(
                  decoration: BoxDecoration(
                    color: ehTheme.commitIconColor,
                    // border:
                    //     Border.all(color: ehTheme.commitIconColor!, width: 1.4),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Center(
                    child: Text(
                      galleryComment.score.startsWith('+')
                          ? '+${galleryComment.score.substring(1)}'
                          : galleryComment.score.startsWith('-')
                              ? galleryComment.score
                              : '+${galleryComment.score}',
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        // color: ehTheme.commitIconColor,
                        color: ehTheme.commentBackgroundColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (galleryComment.id == '0')
          Container(
            decoration: BoxDecoration(
              color: ehTheme.commitIconColor,
              borderRadius: BorderRadius.circular(9),
            ),
            constraints: const BoxConstraints(minWidth: 18),
            height: 18,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Center(
              child: Text(
                'UP',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  // color: ehTheme.commitIconColor,
                  color: ehTheme.commentBackgroundColor,
                ),
              ),
            ),
          ),
        CupertinoTheme(
          data: const CupertinoThemeData(primaryColor: ThemeColors.commitText),
          child: Row(
            children: <Widget>[
              // 翻译
              if (Get.find<EhSettingService>().commentTrans.value && !simple)
                CupertinoTheme(
                  data: ehTheme.themeData!,
                  child: TranslateButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    galleryComment: galleryComment,
                    commentController: commentController,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class TranslateButton extends StatefulWidget {
  const TranslateButton({
    Key? key,
    this.sizeVote = kSizeVote,
    required this.galleryComment,
    required this.commentController,
    this.padding,
  }) : super(key: key);

  final double sizeVote;
  final GalleryComment galleryComment;
  final CommentController commentController;
  final EdgeInsetsGeometry? padding;

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
          : ehTheme.commitIconColor,
    );

    const _loadIcon = CupertinoActivityIndicator(radius: kSizeVote / 2);

    return CupertinoButton(
      padding: widget.padding,
      minSize: 0,
      child: translating ? _loadIcon : _icon,
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

typedef OnOpenUrlCallback = void Function(
  BuildContext context, {
  String? url,
});

/// 显示评分详情
void _showScoreDetail(List<String>? scores, BuildContext context) {
  if (scores == null || scores.isEmpty) {
    return;
  }
  vibrateUtil.light();
  logger.t(scores.join('   '));
  showCupertinoDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => CupertinoAlertDialog(
      content: Container(
          child: Column(
        children: scores
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
