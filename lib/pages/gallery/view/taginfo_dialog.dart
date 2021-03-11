import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/entity/tag_translat.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:fehviewer/utils/db_util.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

Future<void> showTagInfoDialog(String text,
    {required String type, int vote = 0}) {
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
        return CupertinoAlertDialog(
          title: Text('$type:$text'),
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
    final TagTranslat? _taginfo =
        await dbUtil.getTagTrans(widget.text, namespace: widget.type);
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
              return Container(
                child: Text(
                  _taginfo?.intro ?? '',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    height: 1.5,
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
}
