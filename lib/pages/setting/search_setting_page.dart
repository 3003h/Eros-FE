import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchSettingPage extends StatelessWidget {
  const SearchSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).search),
      ),
      child: CustomScrollView(slivers: [
        SliverSafeArea(
          sliver: SliverCupertinoListSection.listInsetGrouped(children: [
            EhCupertinoListTile(
              title: Text(L10n.of(context).quick_search),
              trailing: const CupertinoListTileChevron(),
              onTap: () async {
                await Get.toNamed(
                  EHRoutes.quickSearch,
                  id: isLayoutLarge ? 2 : null,
                );
              },
            ),
          ]),
        ),
      ]),
    );
  }
}
