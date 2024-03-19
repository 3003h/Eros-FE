import 'dart:io' as io;

import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/setting/controller/web_setting_controller.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide WebView;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'eh_webview.dart';

class InWebMySetting extends StatelessWidget {
  final CookieManager _cookieManager = CookieManager.instance();
  final EhSettingService ehSettingService = Get.find();

  @override
  Widget build(BuildContext context) {
    InAppWebViewController? _controller;

    final baseUrl = Api.getBaseUrl();

    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile.user.cookie,
      'host': Uri.parse(baseUrl).host,
    };

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 6),
        middle: Text(L10n.of(context).ehentai_settings),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.redoAlt,
                size: 22,
              ),
              onPressed: () async {
                _controller?.reload();
              },
            ),
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: const Icon(
                FontAwesomeIcons.circleCheck,
                size: 22,
              ),
              onPressed: () async {
                // 保存配置
                _controller?.evaluateJavascript(
                    source:
                        'document.querySelector("#apply > input[type=submit]").click();');
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(
              '$baseUrl/uconfig.php',
            ),
            // headers: _httpHeaders,
          ),
          initialOptions: inAppWebViewOptions,
          onWebViewCreated: (InAppWebViewController controller) {
            _controller = controller;
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url!;

            logger.d('to $uri');
            // if (!(uri.path == '/uconfig.php')) {
            //   logger.d('阻止打开 $uri');
            //   return NavigationActionPolicy.CANCEL;
            // }
            if (uri.host != Api.getBaseHost()) {
              logger.d('阻止打开 $uri');
              return NavigationActionPolicy.CANCEL;
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (InAppWebViewController controller, Uri? url) async {
            logger.d('Page Finished loading: $url');
            if (url == null) {
              return;
            }

            // 写入cookie到dio
            final _cookies =
                await _cookieManager.getCookies(url: WebUri.uri(url));

            final ioCookies = _cookies
                .map((e) => io.Cookie(e.name, e.value as String)
                  ..domain = e.domain
                  ..path = e.path
                  ..httpOnly = e.isHttpOnly ?? false
                  ..secure = e.isSecure ?? false)
                .toList();

            Global.cookieJar
                .saveFromResponse(Uri.parse(Api.getBaseUrl()), ioCookies);

            ehSettingService.selectProfile = ioCookies
                    .firstWhereOrNull((element) => element.name == 'sp')
                    ?.value ??
                '';

            // _cookieManager.getCookies(url: url).then((value) {
            //   final List<io.Cookie> _cookies = value
            //       .map((Cookie e) =>
            //           io.Cookie(e.name, e.value as String)..domain = e.domain)
            //       .toList();
            //
            //   logger.d('${_cookies.map((e) => e.toString()).join('\n')} ');
            //
            //   Global.cookieJar.delete(Uri.parse(Api.getBaseUrl()), true);
            //   Global.cookieJar
            //       .saveFromResponse(Uri.parse(Api.getBaseUrl()), _cookies);
            //
            //   ehSettingService.selectProfile = _cookies
            //           .firstWhereOrNull((element) => element.name == 'sp')
            //           ?.value ??
            //       '';
            // });
          },
        ),
      ),
    );

    return GetBuilder<WebSettingController>(
        init: WebSettingController(),
        builder: (controller) {
          return FutureBuilder<void>(
              future: controller.setcookieFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                return cpf;
              });
        });
  }
}
