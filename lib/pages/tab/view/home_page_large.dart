import 'dart:math';

import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/route/app_pages.dart';
import 'package:fehviewer/route/first_observer.dart';
import 'package:fehviewer/route/main_observer.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/route/second_observer.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'home_page_small.dart';

const kMinWidth = 320.0;

class TabHomeLarge extends GetView<TabHomeController> {
  const TabHomeLarge({
    Key? key,
    this.sideProportion = 0.0,
  }) : super(key: key);
  final double sideProportion;

  double getSideWidth(BuildContext context) {
    double _width = kMinWidth;

    if (context.width >= 1366) {
      _width = 420;
    }
    if (context.width >= 1024) {
      _width = 390;
    }

    _width = kMinWidth + (context.width - 2 * kMinWidth) * sideProportion;
    logger.t('width:${context.width} $_width}');
    return min(max(_width, kMinWidth), context.width - kMinWidth);
  }

  @override
  Widget build(BuildContext context) {
    // logger.d('width:${context.width} ${getSideWidth(context)}');
    final mainNavigatorObserver = MainNavigatorObserver();
    return Row(
      children: [
        AnimatedContainer(
          width: getSideWidth(context),
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
          child: ClipRect(
            child: Navigator(
                key: Get.nestedKey(1),
                observers: [
                  FirstNavigatorObserver(),
                  if (mainNavigatorObserver.navigator == null)
                    mainNavigatorObserver
                ],
                onGenerateRoute: (settings) {
                  final GetPage? _route = AppPages.routes
                      .firstWhereOrNull((GetPage e) => e.name == settings.name);
                  if (_route != null &&
                      _route.name != EHRoutes.root &&
                      _route.name != EHRoutes.home) {
                    return GetPageRoute(
                      settings: settings,
                      showCupertinoParallax: false,
                      page: _route.page,
                    );
                  } else {
                    return GetPageRoute(
                      settings: settings,
                      page: () => const TabHomeSmall(),
                      showCupertinoParallax: false,
                    );
                  }
                }),
          ),
        ),
        Expanded(
          child: SideControllerbar(
            child: Row(
              children: [
                Container(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
                  width: 0.6,
                ),
                Expanded(
                  child: ClipRect(
                    child: Navigator(
                      key: Get.nestedKey(2),
                      observers: [SecondNavigatorObserver()],
                      // observers: [MainNavigatorObserver()],
                      initialRoute: EHRoutes.empty,
                      onGenerateRoute: AppPages.onGenerateRoute,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SideControllerbar extends StatefulWidget {
  const SideControllerbar({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  _SideControllerbarState createState() => _SideControllerbarState();
}

class _SideControllerbarState extends State<SideControllerbar> {
  bool isTapDown = false;
  final LayoutServices layoutServices = Get.find();

  Widget _normalBar({bool dragging = false}) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        color:
            CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context)
                .withOpacity(0.7),
        borderRadius: BorderRadius.circular(dragging ? 5.0 : 1.5),
      ),
      margin: EdgeInsets.only(
          left: dragging ? 5.0 : 2.0, right: dragging ? 5.0 : 20.0),
      height: dragging ? 80 : 55,
      width: dragging ? 10 : 3,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
      child: const SizedBox.expand(),
    );
  }

  Widget getbar() {
    return _normalBar(dragging: isTapDown);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        widget.child,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (details) {
            setState(() {
              isTapDown = true;
            });
          },
          onPanEnd: (_) {
            setState(() {
              isTapDown = false;
            });
          },
          onPanCancel: () {
            setState(() {
              isTapDown = false;
            });
          },
          onPanUpdate: (details) {
            final proportion = layoutServices.sideProportion +
                details.delta.dx / (context.width - 2 * kMinWidth);

            layoutServices.sideProportion = max(min(1.0, proportion), 0.0);
          },
          child: getbar(),
        ),
      ],
    );
  }
}
