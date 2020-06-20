import 'package:FEhViewer/fehviewer/route/navigator_util.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FEhViewer/utils/fluro_convert_util.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebLogin extends StatelessWidget {
  const WebLogin({Key key, this.url, this.title}) : super(key: key);

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    /// 对 中文 进行解码
    String _title = FluroConvertUtils.fluroCnParamsDecode(title);

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
      debugPrint('url $_uri path ${_uri.path}  ${_uri.query}');


      if (_uri.path == "/index.php" && _uri.query == '') {
        debugPrint("登录成功");
        flutterWebviewPlugin.getCookies().then((Map<String, String> _cookies) {
          debugPrint('$_cookies');
        });
      } 
    });

    CupertinoPageScaffold cpf = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_title),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.add_circled_solid),
            onPressed: () {
              flutterWebviewPlugin.getCookies().then((m) {
                debugPrint('cookies: $m');
              });
            },
          ),
        ),
        child: SafeArea(
          child: WebviewScaffold(
            userAgent: EHConst.userAgent,
            url: url,
            javascriptChannels: jsChannels,
            mediaPlaybackRequiresUserGesture: false,
          ),
        ));

    return cpf;
  }
}
