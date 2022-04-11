import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/extension.dart';
import 'package:fehviewer/pages/setting/controller/eh_mysettings_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../component/setting_base.dart';

const kFavList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

class FavoritesRenameItem extends GetView<EhMySettingsController> {
  const FavoritesRenameItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...kFavList.map((e) {
          return TextInputItem(
            // title: '$e',
            icon: Icon(
              FontAwesomeIcons.solidHeart,
              color: ThemeColors.favColor['$e'],
            ).paddingOnly(left: 4, right: 8),
            textAlign: TextAlign.left,
            initValue: controller.ehSetting.favMap['$e'] ?? '',
            onChanged: (val) => controller.ehSetting.setFavname('$e', val),
          );
        }).toList(),
      ],
    );
  }
}
