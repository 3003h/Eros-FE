import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart';

class WebLogin extends StatelessWidget {
  const WebLogin({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = 'login_web'.tr;
    final FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();

    final Set<JavascriptChannel> jsChannels = {
      JavascriptChannel(
          name: 'Print', onMessageReceived: (JavascriptMessage message) {}),
    };

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      final Uri _uri = Uri.parse(url);
      if (_uri.path == '/index.php' && _uri.query.isEmpty) {
        logger.i('登录成功');
        flutterWebviewPlugin.getCookies().then((Map<String, String> _cookies) {
          // 返回 并带上参数
          // NavigatorUtil.goBackWithParams(context, _cookies);
          Get.back(result: _cookies);
        });
      }
    });

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: const Icon(CupertinoIcons.add_circled_solid),
            onPressed: () {
              flutterWebviewPlugin.getCookies().then((cookie) {
                logger.i('cookies: $cookie');
              });
            },
          ),
        ),
        child: SafeArea(
          child: WebviewScaffold(
            userAgent: EHConst.CHROME_USER_AGENT,
            url: EHConst.URL_SIGN_IN,
            javascriptChannels: jsChannels,
            mediaPlaybackRequiresUserGesture: false,
          ),
        ));

    return cpf;
  }
}
