import 'package:FEhViewer/common/global.dart';
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
    /// 对 中文 进行解码
    // String _title = FluroConvertUtils.decodeRouteParam(title);

    final flutterWebviewPlugin = new FlutterWebviewPlugin();

    final Set<JavascriptChannel> jsChannels = [
      JavascriptChannel(
          name: 'Print',
          onMessageReceived: (JavascriptMessage message) {
            print(message.message);
          }),
    ].toSet();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      var _uri = Uri.parse(url);
      Global.logger.i('url $_uri path ${_uri.path}  ${_uri.query}');

      if (_uri.path == "/index.php" && _uri.query == '') {
        Global.logger.i("登录成功");
        flutterWebviewPlugin.getCookies().then((Map<String, String> _cookies) {
          Global.logger.i('$_cookies');
        });
      }
    });

    CupertinoPageScaffold cpf = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.add_circled_solid),
            onPressed: () {
              flutterWebviewPlugin.getCookies().then((m) {
                Global.logger.i('cookies: $m');
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
