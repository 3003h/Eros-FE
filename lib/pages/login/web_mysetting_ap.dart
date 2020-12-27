import 'dart:io';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show CookieManager;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WebMySettingAP extends StatefulWidget {
  @override
  _WebMySettingAPState createState() => _WebMySettingAPState();
}

class _WebMySettingAPState extends State<WebMySettingAP> {
  final CookieManager _cookieManager = CookieManager.instance();

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
    super.dispose();
    flutterWebviewPlugin.close();
  }

  @override
  Widget build(BuildContext context) {
    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged viewState) {
      // logger.d(
      //     '${viewState.url}  ${viewState.type}  ${viewState.navigationType}');
      if (viewState.type == WebViewState.shouldStart &&
          !viewState.url.endsWith('/uconfig.php')) {
        logger.d('阻止打开 ${viewState.url}');
        flutterWebviewPlugin.stopLoading();
      }
    });

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 6),
        middle: Text(S.of(context).ehentai_settings),
        trailing: Container(
          width: 90,
          child: Row(
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
                  flutterWebviewPlugin.evalJavascript(
                      'document.querySelector("#apply > input[type=submit]").click();');
                },
              ),
            ],
          ),
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
