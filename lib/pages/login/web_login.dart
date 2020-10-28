import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebLogin extends StatelessWidget {
  const WebLogin({Key key, this.url, this.title}) : super(key: key);

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    final FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();

    final Set<JavascriptChannel> jsChannels = {
      JavascriptChannel(
          name: 'Print', onMessageReceived: (JavascriptMessage message) {}),
    };

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      final Uri _uri = Uri.parse(url);
      if (_uri.path == '/index.php' && _uri.query.isEmpty) {
        Global.logger.i("登录成功");
        flutterWebviewPlugin.getCookies().then((Map<String, String> _cookies) {
          // 返回 并带上参数
          NavigatorUtil.goBackWithParams(context, _cookies);
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
                Global.logger.i('cookies: $cookie');
              });
            },
          ),
        ),
        child: SafeArea(
          child: WebviewScaffold(
            userAgent: EHConst.CHROME_USER_AGENT,
            url: url,
            javascriptChannels: jsChannels,
            mediaPlaybackRequiresUserGesture: false,
          ),
        ));

    return cpf;
  }
}
