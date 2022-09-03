import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_license_page/flutter_custom_license_page.dart';
import 'package:get/get.dart';

import '../../common/service/layout_service.dart';

final Widget customLicensePage = CustomLicensePage((context, licenseData) {
  return Obx(() {
    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).license),
      ),
      child: body(licenseData, context),
    );
  });
});

Widget body(
  AsyncSnapshot<LicenseData> licenseDataFuture,
  BuildContext context,
) {
  switch (licenseDataFuture.connectionState) {
    case ConnectionState.done:
      LicenseData? licenseData = licenseDataFuture.data;
      return ListView(
        children: [
          ...licenseDataFuture.data!.packages.map(
            (currentPackage) {
              return SelectorSettingItem(
                title: currentPackage,
                desc:
                    '${licenseData!.packageLicenseBindings[currentPackage]!.length} ${L10n.of(context).license}',
                onTap: () {
                  List<LicenseEntry> packageLicenses = licenseData
                      .packageLicenseBindings[currentPackage]!
                      .map((binding) => licenseData.licenses[binding])
                      .toList();
                  Get.to(
                    Obx(() {
                      return CupertinoPageScaffold(
                        backgroundColor: !ehTheme.isDarkMode
                            ? CupertinoColors.secondarySystemBackground
                            : null,
                        navigationBar: CupertinoNavigationBar(
                          middle: Text(
                            currentPackage,
                          ),
                        ),
                        child: ListView.separated(
                          itemCount: packageLicenses.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                packageLicenses[index]
                                    .paragraphs
                                    .map((paragraph) => paragraph.text)
                                    .join('\n'),
                                textScaleFactor: 0.8,
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              height: 12,
                              indent: 12,
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.systemGrey4, context),
                            );
                          },
                        ),
                      );
                    }),
                    id: isLayoutLarge ? 2 : null,
                  );
                },
              );
            },
          ),
        ],
      );
    default:
      return const Center(
        child: CupertinoActivityIndicator(),
      );
  }
}
