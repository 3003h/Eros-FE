import 'dart:async';
import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart' as fwp;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebMySetting extends StatefulWidget {
  @override
  _WebMySettingState createState() => _WebMySettingState();
}

class _WebMySettingState extends State<WebMySetting> {
  // WebViewController _controller;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  Future<void> _future;

  Future<void> _getCookies() async {
    final WebviewCookieManager cookieManager = WebviewCookieManager();
    final List<Cookie> cookies =
        (await Api.cookieJar).loadForRequest(Uri.parse(Api.getBaseUrl()));
    await cookieManager.setCookies(cookies);
  }

  @override
  void initState() {
    super.initState();
    _future = _getCookies();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Ehentai设置'),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: const Icon(FontAwesomeIcons.checkCircle),
            onPressed: () async {
              // (await _controller.future).reload();
              (await _controller.future).evaluateJavascript(
                  'document.querySelector("#apply > input[type=submit]").click();');
            },
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<void>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container();
                } else {
                  return WebView(
                    initialUrl: '${Api.getBaseUrl()}/uconfig.php',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      // _controller = webViewController;
                      _controller.complete(webViewController);
                    },
                    onPageStarted: (String url) {
                      print('Page started loading: $url');
                    },
                    gestureNavigationEnabled: true,
                    navigationDelegate: (NavigationRequest request) {
                      if (!request.url.endsWith('uconfig.php')) {
                        print('阻止打开 ${request.url}');
                        return NavigationDecision.prevent;
                      }
                      return NavigationDecision.navigate;
                    },
                  );
                }
              }),
        ));

    return cpf;
  }
}
