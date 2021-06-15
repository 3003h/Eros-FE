import 'dart:io';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:fehviewer/utils/cust_lib/flutter_egg.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          middle: Text(S.of(context).about),
        ),
        child: SafeArea(
          bottom: false,
          child: ListViewAbout(),
        ));

    return cps;
  }
}

class ListViewAbout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();

    return Container(
      child: ListView(
        children: <Widget>[
          Egg(
            child: TextItem(
              '${Global.packageInfo.appName} ',
              desc: 'an e-hentai app',
              onTap: null,
            ),
            onTrigger: (int tapNum, int neededNum) {
              if (Platform.isIOS) {
                if (_ehConfigService.isSafeMode.value) {
                  showToast('你发现了不得了的东西');
                  logger.v('safeMode off');
                  _ehConfigService.isSafeMode.value = false;
                  Vibrate.feedback(FeedbackType.success);
                } else {
                  showToast('ヾ(￣▽￣)Bye~Bye~');
                  logger.v('safeMode on');
                  _ehConfigService.isSafeMode.value = true;
                  Vibrate.feedback(FeedbackType.error);
                }
              }
            },
          ),
          TextItem(
            'Version',
            desc:
                '${Global.packageInfo.version}(${Global.packageInfo.buildNumber})',
            onTap: null,
          ),
          TextItem(
            'Author',
            desc: 'honjow  <honjow311@gmail.com>',
            onTap: () => launch('mailto:honjow311@gmail.com'),
          ),
          if (!_ehConfigService.isSafeMode.value)
            TextItem(
              'Github',
              desc: 'https://github.com/honjow/FEhViewer',
              onTap: () => launch('https://github.com/honjow/FEhViewer'),
            ),
          TextItem(
            'Telegram',
            desc: 'https://t.me/f_ehviewer',
            onTap: () => launch('https://t.me/f_ehviewer'),
          ),
          TextItem(
            'Channel',
            desc: 'https://t.me/fehviewer',
            onTap: () => launch('https://t.me/fehviewer'),
            hideLine: true,
          ),
        ],
      ),
    );
  }
}
