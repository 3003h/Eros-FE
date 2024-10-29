import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/setting/controller/web_setting_controller.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'eh_webview.dart';

class InWebMyTags extends StatelessWidget {
  const InWebMyTags({super.key});

  @override
  Widget build(BuildContext context) {
    InAppWebViewController? inAppWebViewController;

    final CupertinoPageScaffold cpf = CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 6),
        middle: Text(L10n.of(context).ehentai_my_tags),
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
          ],
        ),
      ),
      child: SafeArea(
        child: InAppWebView(
          initialUrlRequest:
              URLRequest(url: WebUri('${Api.getBaseUrl()}/mytags')),
          onWebViewCreated: (InAppWebViewController controller) {
            inAppWebViewController = controller;
          },
          initialSettings: inAppWebViewSettings,
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url!;

            logger.d('to $uri');
            if (!(uri.path == '/mytags')) {
              logger.d('阻止打开 $uri');
              return NavigationActionPolicy.CANCEL;
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (InAppWebViewController controller, Uri? url) async {
            logger.d('Page Finished loading: $url');
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
