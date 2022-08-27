import 'package:fehviewer/common/controller/avatar_controller.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/comment_controller.dart';
import 'package:fehviewer/widget/expandable_linkify.dart';
import 'package:fehviewer/widget/text_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SelectableText;
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';
import 'package:flutter_linkify/flutter_linkify.dart' as clif;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:linkfy_text/linkfy_text.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../widget/eh_linkify_text.dart';

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
    /// 解析回复的评论
    final reptyComment = controller.parserCommentRepty(galleryComment);
    final reptyComments = controller.parserAllCommentRepty(galleryComment);

    /// 评论item
    return GetBuilder<CommentController>(
        init: CommentController(),
        tag: pageCtrlTag,
        id: galleryComment.id ?? 'None',
        builder: (CommentController _commentController) {
          return Container(
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
                      buildReply(context, reptyComments: reptyComments),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: simple
                          ? _buildSimpleExpTextLinkify(
                              context: context,
                              showTranslate:
                                  galleryComment.showTranslate ?? false)
                          : FullTextCustMergeText(
                              span: galleryComment.span,
                              showTranslate:
                                  galleryComment.showTranslate ?? false,
                              onOpenUrl: onOpenUrl,
                              controller: controller,
                            ),
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
          );
        });
  }

  /// 简单布局 可展开 带链接文字
  Widget _buildSimpleExpTextLinkify({
    bool showTranslate = false,
    TextStyle? style,
    required BuildContext context,
  }) {
    return ExpandableLinkify(
      text: showTranslate ? galleryComment.textTranslate : galleryComment.text,
      onOpen: (link) => onOpenUrl(context, url: link),
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

  Widget buildReply(
    BuildContext context, {
    required List<GalleryComment?> reptyComments,
  }) {
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
                    child: _buildUserWidget(
                      comment: reptyComment,
                      // fontSize: 12,
                    ).paddingOnly(bottom: 6),
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
        if (showRepty && !simple)
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

  Widget buildHeader(
    BuildContext context,
    CommentController commentController,
  ) {
    return Row(
      children: <Widget>[
        Expanded(child: _buildUserWidget()),
        if (galleryComment.id != '0' && !simple)
          GestureDetector(
            onTap: () => _showScoreDeatil(galleryComment.scoreDetails, context),
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
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          //   child: Icon(
          //     FontAwesomeIcons.userNinja,
          //     size: 15,
          //     color: ehTheme.commitIconColor,
          //   ),
          // ),
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
              if (Get.find<EhConfigService>().commentTrans.value && !simple)
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

  Widget _buildUserWidget({
    GalleryComment? comment,
    double fontSize = 13,
    double avatarSize = 28,
  }) {
    final EhConfigService _ehConfigService = Get.find();
    final AvatarController avatarController = Get.find();

    final _name = comment?.name ?? galleryComment.name;
    final _userId = comment?.menberId ?? galleryComment.menberId ?? '0';
    final _commentId = comment?.id ?? galleryComment.id ?? '0';
    final _future = avatarController.getUser(_userId);

    final _placeHold = Obx(() {
      final radius = _ehConfigService.avatarBorderRadiusType ==
              AvatarBorderRadiusType.roundedRect
          ? 8.0
          : avatarSize / 2;

      return _ehConfigService.avatarType == AvatarType.boringAvatar
          ? BoringAvatars(
              name: _name,
              colors: [...ThemeColors.catColorList],
              type: _ehConfigService.boringAvatarsType,
              square: true,
            )
          : TextAvatar(
              name: _name,
              colors: [...ThemeColors.catColorList],
              type: _ehConfigService.textAvatarsType,
              radius: radius,
            );
    });

    void tapName() {
      logger.v('search uploader:$_name');
      NavigatorUtil.goSearchPageWithParam(simpleSearch: 'uploader:$_name');
    }

    return Obx(() {
      final avatarUrl = avatarController.getAvatarUrl(_userId);
      final radius = _ehConfigService.avatarBorderRadiusType ==
              AvatarBorderRadiusType.roundedRect
          ? 8.0
          : avatarSize / 2;
      return GestureDetector(
        onTap: tapName,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_ehConfigService.showCommentAvatar)
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

  /// 显示评分详情
  void _showScoreDeatil(List<String>? scoreDeatils, BuildContext context) {
    // logger.d('scoreDeatils ${scoreDeatils} ');
    if (scoreDeatils == null || scoreDeatils.isEmpty) {
      return;
    }
    vibrateUtil.light();
    logger.v(scoreDeatils.join('   '));
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

  Widget _fullText(BuildContext context) {
    return clif.SelectableLinkify(
      onOpen: (link) => onOpenUrl(context, url: link.url),
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
  Widget _fullRitchText(BuildContext context) {
    return Text.rich(TextSpan(
      children:
          List<InlineSpan>.from(galleryComment.span.map((GalleryCommentSpan e) {
        if (e.imageUrl != null) {
          return WidgetSpan(
            child: GestureDetector(
              onTap: () => onOpenUrl(context, url: e.href!),
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
            color:
                CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
          );

          return clif.buildTextSpan(
            elements,
            style: Theme.of(context).textTheme.bodyText2!.merge(_custStyle),
            onOpen: (link) => onOpenUrl(context, url: link.url),
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
  Widget _fullTextCust(BuildContext context) {
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
      children: List<Widget>.from(_groups.map((List<GalleryCommentSpan> spans) {
        return Wrap(
          children: List<Widget>.from(spans.map((GalleryCommentSpan e) {
            if (e.imageUrl != null) {
              return GestureDetector(
                onTap: () => onOpenUrl(context, url: e.href!),
                child: Container(
                  constraints:
                      const BoxConstraints(maxWidth: 100, maxHeight: 140),
                  child: EhNetworkImage(
                    imageUrl: e.imageUrl!,
                    placeholder: (_, __) => const CupertinoActivityIndicator(),
                  ),
                ),
              );
            } else {
              return clif.SelectableLinkify(
                onOpen: (link) => onOpenUrl(context, url: link.url),
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

    const _w = CupertinoActivityIndicator(radius: kSizeVote / 2);

    return CupertinoButton(
      padding: widget.padding,
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

typedef OnOpenUrlCallback = void Function(
  BuildContext context, {
  String? url,
});

class FullTextCustMergeText extends StatelessWidget {
  const FullTextCustMergeText({
    Key? key,
    this.showTranslate = false,
    required this.span,
    required this.controller,
    required this.onOpenUrl,
  }) : super(key: key);

  final bool showTranslate;
  final List<GalleryCommentSpan> span;
  final CommentController controller;
  final OnOpenUrlCallback onOpenUrl;

  @override
  Widget build(BuildContext context) {
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

      // 后一个是不同类型
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

    final TextStyle _commentTextStyle = TextStyle(
      fontSize: 13,
      height: 1.2,
      color: CupertinoDynamicColor.resolve(ThemeColors.commitText, context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _groups.map((List<GalleryCommentSpan> spans) {
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children:
              List<Widget>.from(spans.map((GalleryCommentSpan commentSpan) {
            switch (commentSpan.sType) {
              case CommentSpanType.linkText: // 链接文字
                return Text.rich(
                  TextSpan(
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
                      ..onTap =
                          () => onOpenUrl(context, url: commentSpan.href!),
                  ),
                ).marginOnly(right: 2);
              case CommentSpanType.text: // 普通文字

                final String oriText = (showTranslate
                        ? commentSpan.translate
                        : commentSpan.text) ??
                    '';
                String _text = oriText.endsWith('\n')
                    ? oriText.substring(0, oriText.length - 1)
                    : oriText;

                _text = _text.startsWith('\n') ? _text.substring(1) : _text;

                return EhLinkifyText(
                  _text,
                  textStyle: _commentTextStyle,
                  onTap: (link) => onOpenUrl(context, url: link.value),
                  textAlign: TextAlign.start,
                  selectable: true,
                );

              // return Text(_text, style: _commentTextStyle);

              // return clif.SelectableLinkify(
              //   onOpen: (link) => onOpenUrl(context, url: link.url),
              //   text: _text,
              //   textAlign: TextAlign.start,
              //   // 对齐方式
              //   // style: CupertinoTheme.of(context)
              //   //     .textTheme
              //   //     .actionTextStyle
              //   //     .merge(_commentTextStyle),
              //   options: const LinkifyOptions(humanize: false),
              // );
              case CommentSpanType.image: // 图片
              case CommentSpanType.linkImage: // 带链接图片

                return GestureDetector(
                  onTap: () => onOpenUrl(context, url: commentSpan.href!),
                  child: Container(
                    constraints:
                        const BoxConstraints(maxWidth: 100, maxHeight: 140),
                    child: EhNetworkImage(
                      imageUrl: commentSpan.imageUrl ?? '',
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
      }).toList(),
    );
  }
}
