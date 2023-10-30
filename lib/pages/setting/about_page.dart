import 'package:fehviewer/common/controller/update_controller.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget cps = Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            middle: Text(L10n.of(context).about),
          ),
          child: SafeArea(
            bottom: false,
            child: ListViewAbout(),
          ));
    });

    return cps;
  }
}

class ListViewAbout extends StatelessWidget {
  ListViewAbout({Key? key}) : super(key: key);

  final EhSettingService _ehSettingService = Get.find();
  final UpdateController _updateController = Get.put(UpdateController());

  @override
  Widget build(BuildContext context) {
    const String debugLabel = kDebugMode
        ? 'Debug'
        : kProfileMode
            ? 'Profile'
            : '';
    return Container(
      child: ListView(
        children: <Widget>[
          // Egg(
          //   child: TextItem(
          //     '${Global.packageInfo.appName} ',
          //     desc: 'an unofficial e-hentai app',
          //     onTap: null,
          //   ),
          //   onTrigger: (int tapNum, int neededNum) {
          //     if (Platform.isIOS) {
          //       if (_ehSettingService.isSafeMode.value) {
          //         // showToast('你发现了不得了的东西');
          //         logger.t('safeMode off');
          //         _ehSettingService.isSafeMode.value = false;
          //         Vibrate.feedback(FeedbackType.success);
          //       } else {
          //         // showToast('ヾ(￣▽￣)Bye~Bye~');
          //         logger.t('safeMode on');
          //         _ehSettingService.isSafeMode.value = true;
          //         Vibrate.feedback(FeedbackType.error);
          //       }
          //     }
          //   },
          // ),
          TextItem(
            L10n.of(context).app_title,
            subTitle: 'An unofficial e-hentai app',
            onTap: null,
          ),
          if (!GetPlatform.isWindows)
            TextItem(
              L10n.of(context).version,
              subTitle:
                  '${Global.packageInfo.version}(${Global.packageInfo.buildNumber}) $debugLabel',
              onTap: null,
            ),
          if (!GetPlatform.isWindows)
            Obx(() {
              return TextItem(
                L10n.of(context).check_for_update,
                subTitle: !_updateController.isLastVersion
                    ? L10n.of(context)
                        .update_to_version(_updateController.lastVersion ?? '')
                    : '${L10n.of(context).latest_version} ${_updateController.lastVersion ?? ''}',
                onTap: () => _updateController.checkUpdate(showDialog: true),
              );
            }),
          TextItem(
            L10n.of(context).license,
            hideDivider: true,
            onTap: () {
              Get.toNamed(
                EHRoutes.license,
                id: isLayoutLarge ? 2 : null,
              );
            },
          ),
          // TextItem(
          //   L10n.of(context).donate,
          //   onTap: () {
          //     showCupertinoDialog(
          //       context: context,
          //       builder: (context) {
          //         return CupertinoAlertDialog(
          //           title: Text(L10n.of(context).donate),
          //           content: Container(
          //             // padding: const EdgeInsets.symmetric(vertical: 12),
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceAround,
          //               children: [
          //                 CupertinoButton(
          //                     child: Column(
          //                       children: [
          //                         ExtendedImage.asset(
          //                           'assets/images/afdian.png',
          //                           width: 50,
          //                         ),
          //                         const Text(
          //                           '爱发电',
          //                           textScaleFactor: 0.8,
          //                         ),
          //                       ],
          //                     ),
          //                     onPressed: () {
          //                       launchUrlString(
          //                         'https://afdian.net/@honjow',
          //                         mode: LaunchMode.externalApplication,
          //                       );
          //                     }),
          //                 // CupertinoButton(
          //                 //   child: Column(
          //                 //     children: [
          //                 //       ExtendedImage.asset(
          //                 //         'assets/images/dundun.png',
          //                 //         width: 40,
          //                 //       ).paddingSymmetric(vertical: 6),
          //                 //       const Text(
          //                 //         '顿顿饭',
          //                 //         textScaleFactor: 0.8,
          //                 //       ),
          //                 //     ],
          //                 //   ),
          //                 //   onPressed: () {
          //                 //     launchUrlString(
          //                 //       'https://dun.mianbaoduo.com/@honjow',
          //                 //       mode: LaunchMode.externalApplication,
          //                 //     );
          //                 //   },
          //                 // ),
          //               ],
          //             ),
          //           ),
          //           actions: [
          //             CupertinoDialogAction(
          //               child: Text(L10n.of(context).cancel),
          //               onPressed: Get.back,
          //             ),
          //           ],
          //         );
          //       },
          //     );
          //   },
          //   hideDivider: true,
          // ),
        ],
      ),
    );
  }
}
