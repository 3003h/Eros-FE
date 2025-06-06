import 'package:eros_fe/common/controller/tag_trans_controller.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/locale_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/gallery/controller/taginfo_controller.dart';
import 'package:eros_fe/pages/setting/controller/eh_mytags_controller.dart';
import 'package:eros_fe/store/db/entity/tag_translat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

Future<void> showTagInfoDialog(
  BuildContext context,
  String text, {
  required String type,
  required String translate,
  int vote = 0,
}) {
  vibrateUtil.medium();
  Get.lazyPut(() => TagInfoController(), tag: pageCtrlTag);
  final TagInfoController controller = Get.find(tag: pageCtrlTag);

  const bool showActionText = true;

  List<Widget> _getActions() {
    if (vote == 0) {
      return <Widget>[
        CupertinoDialogAction(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.thumbsUp).paddingOnly(right: 8),
              if (showActionText) Text(L10n.of(Get.context!).tag_vote_up),
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
                const Icon(FontAwesomeIcons.thumbsDown).paddingOnly(right: 8),
                if (showActionText) Text(L10n.of(Get.context!).tag_vote_down),
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
              const Icon(FontAwesomeIcons.arrowRotateLeft)
                  .paddingOnly(right: 8),
              if (showActionText) Text(L10n.of(Get.context!).tag_withdraw_vote),
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
              const Icon(FontAwesomeIcons.arrowRotateLeft)
                  .paddingOnly(right: 8),
              if (showActionText) Text(L10n.of(Get.context!).tag_withdraw_vote),
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
      context: context,
      barrierDismissible: true,
      builder: (_) {
        Widget _title() {
          if (translate != text && Get.find<LocaleService>().isLanguageCodeZh) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate,
                  textAlign: TextAlign.start,
                ),
                Text(
                  '$type:$text',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$type:$text'),
                const Text(
                  '',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            );
          }
        }

        Future<void> _tapAddToMyTags() async {
          Get.back();
          final _myTagsController = Get.find<EhMyTagsController>();
          await _myTagsController.showAddNewTagDialog(Get.context!,
              userTag: EhUsertag(
                title: '$type:$text',
                defaultColor: true,
                watch: true,
                tagWeight: '10',
              ));
        }

        return CupertinoAlertDialog(
          title: _title(),
          content: Get.find<LocaleService>().isLanguageCodeZh
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TagDialogView(text: text, type: type),
                  ],
                )
              : const SizedBox.shrink(),
          actions: [
            ..._getActions(),
            CupertinoDialogAction(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FontAwesomeIcons.tags).paddingOnly(right: 8),
                  if (showActionText)
                    Text(L10n.of(Get.context!).tag_add_to_mytag),
                ],
              ),
              onPressed: _tapAddToMyTags,
            ),
          ],
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

  Future<TagTranslat?> _getTagInfo() async {
    final TagTranslat? _tagInfo =
        await Get.find<TagTransController>().getTagTranslate(
      widget.text,
      widget.type,
    );
    return _tagInfo;
  }

  @override
  void initState() {
    super.initState();
    _future = _getTagInfo();
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
                    _future = _getTagInfo();
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

              Widget tagInfoView = Container(
                child: CupertinoTheme(
                  data: lTheme,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MarkdownBody(
                        data: _taginfo?.introMdImage ?? '',
                        selectable: true,
                        onTapLink: (String text, String? href, String title) {
                          onOpenUrl(url: href);
                        },
                        styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
                        styleSheet: MarkdownStyleSheet(
                          code: theme.textTheme.textStyle.copyWith(
                              backgroundColor: Colors.transparent,
                              color: CupertinoColors.systemPink,
                              fontSize:
                                  theme.textTheme.textStyle.fontSize! * 0.8,
                              fontFamilyFallback:
                                  EHConst.monoFontFamilyFallback),
                        ),
                        imageBuilder: (Uri uri, String? title, String? alt) {
                          return EhNetworkImage(
                            imageUrl: uri.toString(),
                            placeholder: (_, __) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CupertinoActivityIndicator(),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      MarkdownBody(
                        data: _taginfo?.links ?? '',
                        selectable: true,
                        onTapLink: (String text, String? href, String title) {
                          onOpenUrl(url: href);
                        },
                        styleSheet: MarkdownStyleSheet(
                          a: const TextStyle(
                            color: CupertinoColors.activeBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
                      ),
                    ],
                  ),
                ),
              );

              // tagInfoView = IntrinsicHeight(
              //   child: tagInfoView,
              // );

              return tagInfoView;
            }
          } else {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const CupertinoActivityIndicator(),
            );
          }
        });
  }
}
