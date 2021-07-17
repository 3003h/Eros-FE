// import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/extension.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/store/floor/entity/tag_translat.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:fehviewer/widget/network_extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showTagInfoDialog(String text,
    {required String type, required String translate, int vote = 0}) {
  vibrateUtil.medium();
  Get.lazyPut(() => TagInfoController(), tag: pageCtrlDepth);
  final TagInfoController controller = Get.find(tag: pageCtrlDepth);

  List<Widget> _getActions() {
    if (vote == 0) {
      return <Widget>[
        CupertinoDialogAction(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LineIcons.thumbsUp).paddingOnly(right: 8),
              Text(S.of(Get.context!).tag_vote_up),
            ],
          ),
          onPressed: () {
            Get.back();
            controller.tagVoteUp('$type:$text');
          },
        ),
        CupertinoDialogAction(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LineIcons.thumbsDown).paddingOnly(right: 8),
                Text(S.of(Get.context!).tag_vote_down),
              ],
            ),
            onPressed: () {
              Get.back();
              controller.tagVoteDown('$type:$text');
            }),
      ];
    } else if (vote == 1) {
      return <Widget>[
        CupertinoDialogAction(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LineIcons.undo).paddingOnly(right: 8),
              Text(S.of(Get.context!).tag_withdraw_vote),
            ],
          ),
          onPressed: () {
            Get.back();
            controller.tagVoteDown('$type:$text');
          },
        ),
      ];
    } else if (vote == -1) {
      return <Widget>[
        CupertinoDialogAction(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LineIcons.undo).paddingOnly(right: 8),
              Text(S.of(Get.context!).tag_vote_down),
            ],
          ),
          onPressed: () {
            Get.back();
            controller.tagVoteUp('$type:$text');
          },
        ),
      ];
    } else {
      return [];
    }
  }

  return showCupertinoDialog<void>(
      context: Get.context!,
      barrierDismissible: true,
      builder: (_) {
        Widget _title() {
          if (translate != text) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translate),
                Text('$type:$text', style: const TextStyle(fontSize: 12)),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$type:$text'),
                const Text(
                  '未提供翻译',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            );
          }
        }

        return CupertinoAlertDialog(
          title: _title(),
          content: TagDialogView(text: text, type: type),
          actions: _getActions(),
        );
      });
}

class TagDialogView extends StatefulWidget {
  const TagDialogView({Key? key, required this.type, required this.text})
      : super(key: key);

  final String type;
  final String text;

  @override
  _TagDialogViewState createState() => _TagDialogViewState();
}

class _TagDialogViewState extends State<TagDialogView> {
  late Future<TagTranslat?> _future;

  Future<TagTranslat?> _getTaginfo() async {
    final TagTranslat? _taginfo = await Get.find<TagTransController>()
        .getTagTranslate(widget.text, widget.type);
    return _taginfo;
  }

  @override
  void initState() {
    super.initState();
    _future = _getTaginfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TagTranslat?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  Icons.refresh,
                  size: 30,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    _future = _getTaginfo();
                  });
                },
              );
            } else {
              final TagTranslat? _taginfo = snapshot.data;
              final CupertinoThemeData theme = CupertinoTheme.of(context);
              final CupertinoThemeData lTheme = theme.copyWith(
                  textTheme: theme.textTheme.copyWith(
                      textStyle: theme.textTheme.textStyle.copyWith(
                fontSize: 14,
              )));
              return Container(
                child: CupertinoTheme(
                  data: lTheme,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SelectableText(
                      //   _taginfo?.intro ?? '',
                      //   textAlign: TextAlign.start,
                      //   style: const TextStyle(
                      //     height: 1.5,
                      //   ),
                      // ),
                      MarkdownBody(
                        data: _taginfo?.introMDimage ?? '',
                        selectable: true,
                        onTapLink: (String text, String? href, String title) {
                          _onOpen(context, href);
                        },
                        styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
                        styleSheet: MarkdownStyleSheet(
                          code: theme.textTheme.textStyle.copyWith(
                              backgroundColor: Colors.transparent,
                              // decoration: TextDecoration.underline,
                              // backgroundColor:
                              //     CupertinoColors.activeOrange.withOpacity(0.5),
                              // decorationStyle: TextDecorationStyle.dashed,
                              color: CupertinoColors.activeOrange,
                              fontSize:
                                  theme.textTheme.textStyle.fontSize! * 0.8,
                              fontFamilyFallback:
                                  EHConst.monoFontFamilyFallback),
                        ),
                        imageBuilder: (Uri uri, String? title, String? alt) {
                          // return CachedNetworkImage(
                          //   imageUrl: uri.toString(),
                          //   httpHeaders: {
                          //     'Cookie': Global.profile.user.cookie ?? '',
                          //   },
                          //   placeholder: (_, __) {
                          //     return const Padding(
                          //       padding: EdgeInsets.all(8.0),
                          //       child: CupertinoActivityIndicator(),
                          //     );
                          //   },
                          // );
                          return NetworkExtendedImage(
                            url: uri.toString(),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      MarkdownBody(
                        data: _taginfo?.links ?? '',
                        selectable: true,
                        onTapLink: (String text, String? href, String title) {
                          _onOpen(context, href);
                        },
                        styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
                      ),
                    ],
                  ),
                ),
              );
            }
          } else {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const CupertinoActivityIndicator(),
            );
          }
        });
  }

  Future<void> _onOpen(BuildContext context, String? url) async {
    vibrateUtil.light();

    final String? _openUrl = Uri.encodeFull(url ?? '');
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
