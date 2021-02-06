import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:translator/translator.dart';

Future<void> showTranslatorDialog(String inputText, {String from, String to}) {
  VibrateUtil.medium();
  return showCupertinoModalPopup<void>(
      context: Get.context,
      // barrierDismissible: true,
      builder: (_) {
        // return CupertinoAlertDialog(
        //   title: const Text('Translator'),
        //   content: TranslatorDialogView(inputText, from: from, to: to),
        //   actions: <Widget>[],
        // );
        return CupertinoActionSheet(
          title: Column(
            children: [
              const Text('Translator',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TranslatorDialogView(inputText, from: from, to: to)
            ],
          ),
          actions: const <Widget>[],
        );
      });
}

class TranslatorDialogView extends StatefulWidget {
  const TranslatorDialogView(this.inputText, {Key key, this.from, this.to})
      : super(key: key);

  final String inputText;
  final String from;
  final String to;

  @override
  _TranslatorDialogViewState createState() => _TranslatorDialogViewState();
}

class _TranslatorDialogViewState extends State<TranslatorDialogView> {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<Translation> _future;

  Future<Translation> _getTrans() async {
    try {
      final Translation _trans =
          await _translator.translate(widget.inputText, to: 'zh-cn');
      return _trans;
    } catch (e, stack) {
      logger.e('$e\n$stack');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _future = _getTrans();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Translation>(
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
                    _future = _getTrans();
                  });
                },
              );
            } else {
              final _trans = snapshot.data;
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Text(
                    _trans?.text ?? '',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      height: 1.5,
                      color: CupertinoDynamicColor.resolve(
                          ThemeColors.commitText, context),
                    ),
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
