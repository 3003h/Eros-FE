import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.t('isDarkMode ${ehTheme.isDarkMode}');
    return Obx(() {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: ehTheme.isDarkMode
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarDividerColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
        child: CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          child: SafeArea(
            child: Container(
              child: const Center(
                child: Icon(
                  FontAwesomeIcons.layerGroup,
                  size: 100,
                  color: CupertinoColors.inactiveGray,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
