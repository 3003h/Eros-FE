import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_license_page/flutter_custom_license_page.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../common/service/layout_service.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomLicensePage((context, licenseData) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: Text(L10n.of(context).license),
        ),
        child: CustomScrollView(slivers: [
          SliverSafeArea(
            sliver: MultiSliver(children: [_buildBody(licenseData, context)]),
          ),
        ]),
      );
    });
  }

  Widget _buildBody(
    AsyncSnapshot<LicenseData> licenseDataFuture,
    BuildContext context,
  ) {
    switch (licenseDataFuture.connectionState) {
      case ConnectionState.done:
        final LicenseData? licenseData = licenseDataFuture.data;
        final packages = licenseData?.packages ?? [];
        final packageLicenseBindings =
            licenseData?.packageLicenseBindings ?? {};

        if (licenseData == null) {
          return const SliverFillRemaining(
            child: Center(
              child: Text('licenseData is null'),
            ),
          );
        }

        return SliverCupertinoListSection.insetGrouped(
          hasLeading: false,
          additionalDividerMargin: 6,
          itemBuilder: (context, index) {
            return EhCupertinoListTile(
              title: Text(packages[index]),
              trailing: const CupertinoListTileChevron(),
              subtitle: Text(
                  '${packageLicenseBindings[licenseData.packages[index]]!.length} ${L10n.of(context).license}'),
              onTap: () {
                List<LicenseEntry> packageLicenses =
                    packageLicenseBindings[licenseData.packages[index]]!
                        .map((binding) => licenseData.licenses[binding])
                        .toList();
                Get.to(
                  _LicensePage(
                    currentPackage: licenseData.packages[index],
                    packageLicenses: packageLicenses,
                  ),
                  id: isLayoutLarge ? 2 : null,
                );
              },
            );
          },
          itemCount: packages.length,
        );

      default:
        return const SliverFillRemaining(
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
    }
  }
}

class _LicensePage extends StatelessWidget {
  const _LicensePage({
    super.key,
    required this.currentPackage,
    required this.packageLicenses,
  });
  final String currentPackage;
  final List<LicenseEntry> packageLicenses;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
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
              textScaler: const TextScaler.linear(0.8),
              // 等宽字体
              style: const TextStyle(
                  fontFamilyFallback: EHConst.monoFontFamilyFallback),
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
  }
}
