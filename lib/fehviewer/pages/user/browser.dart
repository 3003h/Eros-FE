import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:FEhViewer/utils/fluro_convert_util.dart';

class WebLogin extends StatelessWidget {
  const WebLogin({Key key, this.url, this.title}) : super(key: key);

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    /// 对 中文 进行解码
    String _title = FluroConvertUtils.fluroCnParamsDecode(title);

    debugPrint('$_title   $url');

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_title),
        ),
        child: SafeArea(
          child: WebView(
            initialUrl: url,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ));
  }
}
