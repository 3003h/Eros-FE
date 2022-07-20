import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget cps = Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            transitionBetweenRoutes: true,
            middle: Text(L10n.of(context).search),
          ),
          child: SafeArea(
            child: ListViewSearchSetting(),
            bottom: false,
          ));
    });

    return cps;
  }
}

class ListViewSearchSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      SelectorSettingItem(
        title: L10n.of(context).quick_search,
        selector: '',
        onTap: () async {
          await Get.toNamed(
            EHRoutes.quickSearch,
            id: isLayoutLarge ? 2 : null,
          );
        },
        hideDivider: true,
      ),
    ];
    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }
}
