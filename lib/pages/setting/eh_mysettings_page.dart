import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import 'webview/web_mysetting_in.dart';

class EhMySettingsPage extends StatelessWidget {
  const EhMySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
            middle: Text(L10n.of(context).ehentai_settings),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    LineIcons.globeWithAmericasShown,
                    size: 24,
                  ),
                  onPressed: () async {
                    Get.to(() => InWebMySetting());
                  },
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    LineIcons.checkCircle,
                    size: 24,
                  ),
                  onPressed: () async {
                    // 保存配置
                  },
                ),
              ],
            )),
        child: SafeArea(
          child: ListViewEhMySettings(),
          bottom: false,
        ));
  }
}

class ListViewEhMySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
