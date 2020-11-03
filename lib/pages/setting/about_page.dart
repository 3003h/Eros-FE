import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/pages/setting/setting_base.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_egg/flutter_egg.dart';

class AboutPage extends StatelessWidget {
  final String _title = '关于';

  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: ThemeColors.navigationBarBackground,
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
    return Container(
      child: ListView(
        children: <Widget>[
          Egg(
            child: TextItem(
              'FEhViewer',
              desc: '一个兴趣使然的e-hentai客户端',
            ),
            onTrigger: (int tapNum, int neededNum) {
              if (Platform.isIOS) {
                if (Global.profile.ehConfig.safeMode ?? true) {
                  showToast('你发现了不得了的东西');
                  Global.logger.v('safeMode off');
                  Global.profile.ehConfig.safeMode = false;
                  Global.saveProfile();
                } else {
                  showToast('ヾ(￣▽￣)Bye~Bye~');
                  Global.logger.v('safeMode on');
                  Global.profile.ehConfig.safeMode = true;
                  Global.saveProfile();
                }
              }
            },
          ),
          TextItem(
            '作者',
            desc: 'honjow  <honjow311@gmail.com>',
          ),
        ],
      ),
    );
  }
}
