import 'dart:async';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// 闪屏页
class SplashPage extends StatefulWidget {
  const SplashPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  StreamSubscription _intentDataStreamSubscription;
  String _sharedText;

  @override
  void dispose() {
    // _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> startHome(String url) async {
    // String _url = await ReceiveSharingIntent.getInitialText();
    //
    // setState(() {
    //   _sharedText = _url;
    // });

    if (url != null && url.isNotEmpty) {
      Global.logger.v('open $url');
      await Future<void>.delayed(const Duration(milliseconds: 300), () {
        NavigatorUtil.goGalleryDetailReplace(context, url: url);
      });
    } else {
      Global.logger.v('url is Empty,jump to home');
      await Future<void>.delayed(const Duration(milliseconds: 500), () {
        NavigatorUtil.goHomePage(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      Global.logger.v('value(memory): $value');
      setState(() {
        _sharedText = value;
        Global.logger.v('Shared: $_sharedText');
      });
      startHome(_sharedText);
    }, onError: (err) {
      Global.logger.e('getLinkStream error: $err');
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      Global.logger.v('value(closed): $value');
      setState(() {
        _sharedText = value;
        Global.logger.v('Shared: $_sharedText');
      });
      startHome(_sharedText);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget container = (_sharedText != null && _sharedText.isNotEmpty)
        ? Container(
            child:
                const Center(child: CupertinoActivityIndicator(radius: 20.0)),
          )
        : Container(
            child: Center(
              child: Column(
                // center the children
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.local_cafe,
                    // FontAwesomeIcons.heading,
                    size: 150.0,
                    color: Colors.grey,
                  ),
                  Text(
                    S.of(context).welcome_text,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    S.of(context).app_title,
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
          );

    return Scaffold(
//      backgroundColor: Colors.white,
      body: container,
    );
  }
}
