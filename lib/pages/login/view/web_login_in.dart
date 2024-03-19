import 'dart:io' as io;

import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class WebLoginViewIn extends StatelessWidget {
  WebLoginViewIn({
    Key? key,
  }) : super(key: key);

  final CookieManager _cookieManager = CookieManager.instance();

  @override
  Widget build(BuildContext context) {
    final String title = L10n.of(context).login_web;
    InAppWebViewController _controller;
    final WebviewCookieManager cookieManager = WebviewCookieManager();

    final InAppWebViewSettings settings = InAppWebViewSettings(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        useHybridComposition: true,
        allowsInlineMediaPlayback: true);

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        transitionBetweenRoutes: false,
      ),
      child: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(EHConst.URL_SIGN_IN)),
          initialSettings: settings,
          onWebViewCreated: (InAppWebViewController webViewController) {
            _controller = webViewController;
          },
          onPermissionRequest: (controller, permissionRequest) async {
            return PermissionResponse(action: PermissionResponseAction.GRANT);
          },
          // onLoadStart: (InAppWebViewController controller, Uri? url) {
          //   logger.d('Page started loading: $url');
          //
          //   if (url == null) {
          //     return;
          //   }
          //
          //   if (!(url.path == '/uconfig.php') && !(url.path == '/index.php')) {
          //     logger.d('阻止打开 $url');
          //     controller.stopLoading();
          //   }
          // },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url!;

            final act = uri.queryParameters['act'];

            logger.d('to $uri');
            if (uri.path == '/index.php' && act != null && act != 'Login') {
              logger.d('阻止打开 $uri');
              return NavigationActionPolicy.CANCEL;
            } else if (uri.path == '/uconfig.php' || uri.path == '/index.php') {
              return NavigationActionPolicy.ALLOW;
            }

            logger.d('阻止打开 $uri');
            return NavigationActionPolicy.CANCEL;
          },
          onLoadStop: (InAppWebViewController controller, Uri? uri) async {
            logger.d('Page Finished loading: $uri');

            if (uri == null) {
              return;
            }

            if (uri.path == '/index.php' && uri.queryParameters.isEmpty) {
              // final Map<String, String> cookieMap = <String, String>{};
              // 返回 cookie
              _cookieManager
                  .getCookies(url: WebUri.uri(uri))
                  .then((List<Cookie> cookies) {
                // logger.d('>>>>>>>>>>>>>>>> cookies $cookies');
                // value.forEach((Cookie cookie) =>
                //     cookieMap[cookie.name] = cookie.value as String);

                Get.back<List<io.Cookie>>(
                    result: cookies
                        .map((e) => io.Cookie(e.name, '${e.value}'))
                        .toList());
              });
            }
          },
        ),
      ),
    );

    return cpf;
  }
}
