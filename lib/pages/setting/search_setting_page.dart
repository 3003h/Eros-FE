import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:fehviewer/pages/tab/view/quick_search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: true,
          middle: Text(S.of(context).search),
        ),
        child: SafeArea(
          child: ListViewSearchSetting(),
          bottom: false,
        ));

    return cps;
  }
}

class ListViewSearchSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      // _buildPreloadImageItem(context),
      SelectorSettingItem(
        title: S.of(context).quick_search,
        selector: '',
        onTap: () {
          Get.to<String>(
            () => const QuickSearchListPage(autoSearch: false),
            transition: Transition.cupertino,
          );
        },
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
