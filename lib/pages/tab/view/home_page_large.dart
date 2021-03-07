import 'package:fehviewer/pages/tab/bindings/tabhome_binding.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_page_small.dart';

class TabHomeLarge extends GetView<TabHomeController> {
  const TabHomeLarge({Key? key, this.wide = false}) : super(key: key);
  final bool wide;

  @override
  Widget build(BuildContext context) {
    print('width:${context.width}');
    return Row(
      children: [
        Container(
          width: wide ? 375 : 320,
          child: Navigator(
              key: Get.nestedKey(1),
              initialRoute: EHRoutes.home,
              onGenerateRoute: (settings) {
                switch (settings.name) {
                  default:
                    return GetPageRoute(
                      page: () => TabHomeSmall(),
                      binding: TabHomeBinding(),
                    );
                }
              }),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                color: CupertinoColors.systemGrey4,
                width: 0.6,
              ),
              Expanded(
                child: Navigator(
                    key: Get.nestedKey(2),
                    // initialRoute: Routes.HOME,
                    onGenerateRoute: (settings) {
                      switch (settings.name) {
                        default:
                          return GetPageRoute(
                            page: () => CupertinoPageScaffold(
                              // navigationBar: CupertinoNavigationBar(),
                              child: Container(),
                            ),
                            transition: Transition.fadeIn,
                          );
                      }
                    }),
              ),
            ],
          ),
          // child: CupertinoPageScaffold(child: Container()),
        ),
      ],
    );
  }
}
