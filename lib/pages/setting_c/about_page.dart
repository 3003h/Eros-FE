import 'dart:io';

import 'package:fehviewer/common/controller/update_controller.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  String get debugLabel => kDebugMode
      ? 'Debug'
      : kProfileMode
          ? 'Profile'
          : '';

  @override
  Widget build(BuildContext context) {
    final UpdateController _updateController = Get.put(UpdateController());

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(L10n.of(context).about),
          ),
          MultiSliver(children: [
            CupertinoListSection.insetGrouped(
              hasLeading: false,
              additionalDividerMargin: 6,
              children: [
                CupertinoListTile(
                  title: Text(L10n.of(context).app_title),
                  subtitle: const Text('An unofficial e-hentai app'),
                ),
                if (!Platform.isWindows || !Platform.isLinux)
                  CupertinoListTile(
                    title: Text(L10n.of(context).version),
                    subtitle: Text(
                        '${Global.packageInfo.version}(${Global.packageInfo.buildNumber}) $debugLabel'),
                  ),
                if (!Platform.isWindows || !Platform.isLinux)
                  CupertinoListTile(
                    title: Text(L10n.of(context).check_for_update),
                    trailing: Obx(() {
                      if (_updateController.isChecking) {
                        return const CupertinoActivityIndicator();
                      } else {
                        return const CupertinoListTileChevron();
                      }
                    }),
                    onTap: () {
                      _updateController.checkUpdate(showDialog: true);
                    },
                    subtitle: Text(!_updateController.isLastVersion
                        ? L10n.of(context).update_to_version(
                            _updateController.lastVersion ?? '')
                        : '${L10n.of(context).latest_version} ${_updateController.lastVersion ?? ''}'),
                  ),
                CupertinoListTile(
                  title: Text(L10n.of(context).license),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    Get.toNamed(EHRoutes.license);
                  },
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
