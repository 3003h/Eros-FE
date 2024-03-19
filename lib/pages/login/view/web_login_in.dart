import 'dart:io' as io;

import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/utils/logger.dart';
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

    InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
        ));

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        transitionBetweenRoutes: false,
      ),
      child: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(EHConst.URL_SIGN_IN)),
          initialOptions: options,
          onWebViewCreated: (InAppWebViewController webViewController) {
            _controller = webViewController;
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
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
                logger.d(' $cookies');
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
