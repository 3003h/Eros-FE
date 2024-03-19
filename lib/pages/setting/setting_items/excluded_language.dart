import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/pages/setting/controller/eh_mysettings_controller.dart';
import 'package:eros_fe/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

const _kElStyle = TextStyle(fontSize: 14.0);
const _kElFlexLang = 10;
const _kElFlexSwitch = 10;

class ExcludedLanguagePage extends StatelessWidget {
  const ExcludedLanguagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).uc_exc_lang),
      ),
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      child: const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: ExcludedLanguageWidget(),
            ),
          )
        ],
      ),
    );
  }
}

class ExcludedLanguageWidget extends GetView<EhMySettingsController> {
  const ExcludedLanguageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _heard = Row(
      children: [
        const Expanded(
            flex: _kElFlexLang,
            child: Text(
              '',
              textAlign: TextAlign.right,
              style: _kElStyle,
            )),
        Expanded(
            flex: _kElFlexSwitch,
            child: Text(
              L10n.of(context).uc_Original,
              textAlign: TextAlign.center,
              style: _kElStyle,
            )),
        Expanded(
            flex: _kElFlexSwitch,
            child: Text(
              L10n.of(context).uc_Translated,
              textAlign: TextAlign.center,
              style: _kElStyle,
            )),
        Expanded(
            flex: _kElFlexSwitch,
            child: Text(
              L10n.of(context).uc_Rewrite,
              textAlign: TextAlign.center,
              style: _kElStyle,
            )),
      ],
    ).paddingOnly(bottom: 8.0);

    List<List<String?>> _elIds = [
      [L10n.of(context).uc_Japanese, null, '1024', '2048'],
      [L10n.of(context).uc_English, '1', '1025', '2049'],
      [L10n.of(context).uc_Chinese, '10', '1034', '2058'],
      [L10n.of(context).uc_Dutch, '20', '1044', '2068'],
      [L10n.of(context).uc_French, '30', '1054', '2078'],
      [L10n.of(context).uc_German, '40', '1064', '2088'],
      [L10n.of(context).uc_Hungarian, '50', '1074', '2098'],
      [L10n.of(context).uc_Italian, '60', '1084', '2108'],
      [L10n.of(context).uc_Korean, '70', '1094', '2118'],
      [L10n.of(context).uc_Polish, '80', '1104', '2128'],
      [L10n.of(context).uc_Portuguese, '90', '1114', '2138'],
      [L10n.of(context).uc_Russian, '100', '1124', '2148'],
      [L10n.of(context).uc_Spanish, '110', '1134', '2158'],
      [L10n.of(context).uc_Thai, '120', '1144', '2168'],
      [L10n.of(context).uc_Vietnamese, '120', '1154', '2178'],
      [L10n.of(context).uc_NA, '254', '1278', '2302'],
      [L10n.of(context).uc_Other, '255', '1279', '2303'],
    ];

    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        width: double.infinity,
        color: CupertinoDynamicColor.resolve(
            ehTheme.itemBackgroundColor!, context),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ),
            child: Column(
              children: [
                _heard,
                ..._elIds.map(
                  (e) => ExcludedLanguageBody(
                    language: e[0] ?? '',
                    oriId: e[1],
                    transId: e[2],
                    rewId: e[3],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class ExcludedLanguageBody extends StatelessWidget {
  const ExcludedLanguageBody({
    Key? key,
    required this.language,
    this.oriId,
    this.transId,
    this.rewId,
  }) : super(key: key);
  final String language;
  final String? oriId;
  final String? transId;
  final String? rewId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              flex: _kElFlexLang,
              child: Text(
                language,
                textAlign: TextAlign.right,
                style: _kElStyle,
              )),
          Expanded(
            flex: _kElFlexSwitch,
            child: ExcludedLanguageCheckBox(
              id: oriId,
            ),
          ),
          Expanded(
            flex: _kElFlexSwitch,
            child: ExcludedLanguageCheckBox(
              id: transId,
            ),
          ),
          Expanded(
            flex: _kElFlexSwitch,
            child: ExcludedLanguageCheckBox(
              id: rewId,
            ),
          ),
        ],
      ),
    );
  }
}

class ExcludedLanguageCheckBox extends GetView<EhMySettingsController> {
  const ExcludedLanguageCheckBox({
    Key? key,
    this.id,
  }) : super(key: key);
  final String? id;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Center(
        child: id != null
            ? GetBuilder<EhMySettingsController>(
                id: id,
                builder: (logic) {
                  return Theme(
                    data: ThemeData(
                      // 去掉水波纹效果
                      splashColor: Colors.transparent,
                      // 去掉点击效果
                      highlightColor: Colors.transparent,
                    ),
                    child: GFCheckbox(
                      size: 24.0,
                      activeBgColor: GFColors.DANGER,
                      inactiveBgColor: Colors.transparent,
                      activeBorderColor: GFColors.DANGER,
                      inactiveBorderColor: CupertinoDynamicColor.resolve(
                          CupertinoColors.label, context),
                      type: GFCheckboxType.circle,
                      onChanged: (val) {
                        vibrateUtil.light();
                        logic.ehSetting.setBoolXl(id!, val);
                        logic.update([id ?? '']);
                      },
                      value: logic.ehSetting.getBoolXl(id!),
                      inactiveIcon: null,
                    ),
                  );
                })
            : const SizedBox.shrink(),
      ),
    );
  }
}
