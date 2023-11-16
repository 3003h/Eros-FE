import 'package:fehviewer/common/controller/mysql_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'mysql_login.dart';

class MysqlSyncPage extends StatelessWidget {
  const MysqlSyncPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String _title = 'MySQL Sync';
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(_title),
        // trailing: _buildListButtons(context),
      ),
      child: MysqlSettingView(),
    );
  }

// Widget _buildListButtons(BuildContext context) {
//   return Obx(() {
//     return Container(
//       child: controller.validAccount
//           ? const SizedBox.shrink()
//           : CupertinoButton(
//               minSize: 40,
//               padding: const EdgeInsets.all(0),
//               child: const Icon(
//                 CupertinoIcons.person_add,
//                 size: 26,
//               ),
//               onPressed: () async {
//                 final result = await Get.toNamed(
//                   EHRoutes.loginWebDAV,
//                   id: isLayoutLarge ? 2 : null,
//                 );
//                 if (result != null && result is bool && result) {
//                   Get.back();
//                 }
//               },
//             ),
//     );
//   });
// }
}

class MysqlSettingView extends GetView<MysqlController> {
  const MysqlSettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          sliver: MultiSliver(
            children: [
              SliverCupertinoListSection.listInsetGrouped(
                children: [
                  Obx(() {
                    return EhCupertinoListTile(
                      title: controller.isValidAccount
                          ? const Text('MySQL')
                          : Text(L10n.of(context).login),
                      subtitle: controller.isValidAccount
                          ? Text(controller.connectionText)
                          : null,
                      trailing: const CupertinoListTileChevron(),
                      onTap: () async {
                        if (controller.isValidAccount) {
                          // 登出
                          showCupertinoDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: Text('Logout?'),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: Text(L10n.of(context).cancel),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text(L10n.of(context).ok),
                                    onPressed: () async {
                                      // 登出
                                      controller.isValidAccount = false;
                                      Get.back();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // 登录
                          await Get.to(
                            () => const MysqlLogin(),
                            id: isLayoutLarge ? 2 : null,
                          );
                        }
                      },
                    );
                  }),
                ],
              ),
              if (kDebugMode)
                SliverCupertinoListSection.listInsetGrouped(
                  children: [
                    EhCupertinoListTile(
                      title: Text('Test ...'),
                      onTap: () {
                        controller.test();
                      },
                    ),
                  ],
                ),
              SliverCupertinoListSection.listInsetGrouped(
                children: [
                  EhCupertinoSwitchListTile(
                    title: Text(L10n.of(context).sync_history),
                    value: controller.syncHistory,
                    onChanged: (val) {
                      controller.syncHistory = val;
                    },
                  ),
                  EhCupertinoSwitchListTile(
                    title: Text(L10n.of(context).sync_read_progress),
                    value: controller.syncReadProgress,
                    onChanged: (val) {
                      controller.syncReadProgress = val;
                    },
                  ),
                  // EhCupertinoSwitchListTile(
                  //   title: Text(L10n.of(context).sync_group),
                  //   value: controller.syncGroupProfile,
                  //   onChanged: (val) {
                  //     controller.syncGroupProfile = val;
                  //   },
                  // ),
                  // EhCupertinoSwitchListTile(
                  //   title: Text(L10n.of(context).sync_quick_search),
                  //   value: controller.syncQuickSearch,
                  //   onChanged: (val) {
                  //     controller.syncQuickSearch = val;
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
