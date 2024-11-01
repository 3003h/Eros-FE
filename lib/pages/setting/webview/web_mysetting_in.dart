import 'dart:io' as io;

import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/setting/controller/web_setting_controller.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'eh_webview.dart';

class InWebMySetting extends StatelessWidget {
  const InWebMySetting({super.key});

  @override
  Widget build(BuildContext context) {
    final CookieManager cookieManager = CookieManager.instance();
    final EhSettingService ehSettingService = Get.find();

    InAppWebViewController? inAppWebViewController;

    final baseUrl = Api.getBaseUrl();

    final Map<String, String> httpHeaders = {
      'Cookie': Global.profile.user.cookie,
      // 'host': Uri.parse(baseUrl).host,
    };

    logger.d('httpHeaders: $httpHeaders');

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
                FontAwesomeIcons.rotateRight,
                size: 22,
              ),
              onPressed: () async {
                inAppWebViewController?.reload();
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
                inAppWebViewController?.evaluateJavascript(
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
            headers: httpHeaders,
          ),
          initialSettings: inAppWebViewSettings,
          onWebViewCreated: (InAppWebViewController controller) {
            inAppWebViewController = controller;
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url!;

            logger.d('to $uri');
            if (uri.host != Api.getBaseHost()) {
              logger.d('阻止打开 $uri');
              return NavigationActionPolicy.CANCEL;
            }

            if (uri.path != '/uconfig.php' && kReleaseMode) {
              logger.e('阻止打开 $uri');
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
            final cookies =
                await cookieManager.getCookies(url: WebUri.uri(url));

            final ioCookies = cookies
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
