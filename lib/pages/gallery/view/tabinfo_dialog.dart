import 'package:fehviewer/models/entity/tag_translat.dart';
import 'package:fehviewer/utils/db_util.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showTagInfoDialog(String text, {String type}) {
  VibrateUtil.medium();
  return showCupertinoDialog<void>(
      context: Get.context,
      barrierDismissible: true,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(text),
          content: TagDialogView(text: text, type: type),
          actions: <Widget>[],
        );
      });
}

class TagDialogView extends StatefulWidget {
  const TagDialogView({Key key, this.type, this.text}) : super(key: key);

  final String type;
  final String text;

  @override
  _TagDialogViewState createState() => _TagDialogViewState();
}

class _TagDialogViewState extends State<TagDialogView> {
  Future<TagTranslat> _future;

  Future<TagTranslat> _getTaginfo() async {
    final TagTranslat _taginfo =
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
    return FutureBuilder<TagTranslat>(
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
              final _taginfo = snapshot.data;
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
          return Container();
        });
  }
}
