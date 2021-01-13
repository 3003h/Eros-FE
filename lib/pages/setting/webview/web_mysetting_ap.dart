import 'dart:io';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as inw;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 安卓使用
class WebMySettingAP extends StatefulWidget {
  @override
  _WebMySettingAPState createState() => _WebMySettingAPState();
}

class _WebMySettingAPState extends State<WebMySettingAP> {
  final inw.CookieManager _cookieManager = inw.CookieManager.instance();

  final FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    final List<Cookie> cookies =
        Global.cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));

    for (final Cookie cookie in cookies) {
      _cookieManager.setCookie(
          url: Api.getBaseUrl(), name: cookie.name, value: cookie.value);
    }
  }

  @override
  void dispose() {
    flutterWebviewPlugin.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged viewState) {
      logger.d(
          '${viewState.url}  ${viewState.type}  ${viewState.navigationType}');
      if (viewState.type == WebViewState.shouldStart &&
          !viewState.url.endsWith('/uconfig.php')) {
        logger.d('阻止打开 ${viewState.url}');
        flutterWebviewPlugin.stopLoading();
      } else if (viewState.type == WebViewState.finishLoad &&
          viewState.url.endsWith('/uconfig.php')) {
        // 写入cookie到dio
        _cookieManager.getCookies(url: viewState.url).then((value) {
          // List<Cookie> _cookies = value.forEach((key, value) { });
          final List<Cookie> _cookies = value
              .map((inw.Cookie e) => Cookie(e.name, e.value)..domain = e.domain)
              .toList();

          logger.d('${_cookies.map((e) => e.toString()).join('\n')} ');

          Global.cookieJar.delete(Uri.parse(Api.getBaseUrl()), true);
          Global.cookieJar
              .saveFromResponse(Uri.parse(Api.getBaseUrl()), _cookies);
        });
      }
    });

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 6),
        middle: Text(S.of(context).ehentai_settings),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.redo,
                size: 20,
              ),
              onPressed: () async {
                await flutterWebviewPlugin.reload();
              },
            ),
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.checkCircle,
                size: 24,
              ),
              onPressed: () async {
                // 保存配置
                flutterWebviewPlugin.evalJavascript(
                    'document.querySelector("#apply > input[type=submit]").click();');
                // flutterWebviewPlugin
                //     .getCookies()
                //     .then((Map<String, String> value) {
                //   value.forEach((key, value) {
                //     logger.d('$key  $value');
                //   });
                // });
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: WebviewScaffold(
          url: '${Api.getBaseUrl()}/uconfig.php',
          withZoom: true,
          withJavascript: true,
        ),
      ),
    );

    return cpf;
  }
}
