import 'dart:io';

import 'package:FEhViewer/common/controller/ehconfig_controller.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/pages/setting/setting_base.dart';
import 'package:FEhViewer/utils/cust_lib/flutter_egg.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  final String _title = '关于';

  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_title),
        ),
        child: SafeArea(
          child: ListViewAbout(),
        ));

    return cps;
  }
}

class ListViewAbout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EhConfigController ehConfigController = Get.find();

    return Container(
      child: ListView(
        children: <Widget>[
          Egg(
            child: const TextItem(
              'FEhViewer',
              desc: '一个兴趣使然的e-hentai客户端',
              onTap: null,
            ),
            onTrigger: (int tapNum, int neededNum) {
              if (Platform.isIOS) {
                if (Global.profile.ehConfig.safeMode ?? true) {
                  showToast('你发现了不得了的东西');
                  logger.v('safeMode off');
                  ehConfigController.isSafeMode.value = false;
                  Vibrate.feedback(FeedbackType.success);
                } else {
                  showToast('ヾ(￣▽￣)Bye~Bye~');
                  logger.v('safeMode on');
                  ehConfigController.isSafeMode.value = true;
                  Vibrate.feedback(FeedbackType.error);
                }
              }
            },
          ),
          TextItem(
            '作者',
            desc: 'honjow  <honjow311@gmail.com>',
            onTap: () => launch('mailto:honjow311@gmail.com'),
          ),
          TextItem(
            'Telegram',
            desc: 'https://t.me/f_ehviewer',
            onTap: () => launch('https://t.me/f_ehviewer'),
          ),
          TextItem(
            '频道',
            desc: 'https://t.me/fehviewer',
            onTap: () => launch('https://t.me/fehviewer'),
          ),
          if (!Global.profile.ehConfig.safeMode)
            TextItem(
              'Github',
              desc: 'https://github.com/honjow/FEhViewer',
              onTap: () => launch('https://github.com/honjow/FEhViewer'),
            ),
        ],
      ),
    );
  }
}
