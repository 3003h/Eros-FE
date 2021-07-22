import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/pages/image_view_ext/view/view_ext.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/view_ext_contorller.dart';
import '../controller/view_ext_state.dart';
import 'view_image_ext.dart';

typedef DoubleClickAnimationListener = void Function();

class ViewRepository {
  ViewRepository({
    this.index = 0,
    this.loadType = LoadType.network,
    this.files,
  });

  final int index;
  final List<String>? files;
  final LoadType loadType;
}

class ViewExtPage extends StatefulWidget {
  const ViewExtPage({Key? key}) : super(key: key);

  @override
  _ViewExtPageState createState() => _ViewExtPageState();
}

class _ViewExtPageState extends State<ViewExtPage>
    with TickerProviderStateMixin {
  final ViewExtController controller = Get.find();

  ViewExtState get vState => controller.vState;

  @override
  Widget build(BuildContext context) {
    return const CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ImagePlugins(
          child: ImageGestureDetector(
            child: ImagePageView(),
          ),
        ),
      ),
    );
  }
}

class ImagePageView extends GetView<ViewExtController> {
  const ImagePageView({Key? key, this.reverse = false}) : super(key: key);

  final bool reverse;

  ViewExtState get vState => controller.vState;

  @override
  Widget build(BuildContext context) {
    return ExtendedImageSlidePage(
      child: ExtendedImageGesturePageView.builder(
        controller: controller.pageController,
        itemBuilder: (BuildContext context, int index) {
          /// 单页
          return ViewImageExt(imageSer: index + 1);
        },
        itemCount: vState.pageCount,
        onPageChanged: controller.handOnPageChanged,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        reverse: reverse,
      ),
      slideAxis: SlideAxis.vertical,
      slideType: SlideType.onlyImage,
      resetPageDuration: const Duration(milliseconds: 300),
      slidePageBackgroundHandler: (Offset offset, Size pageSize) {
        double opacity = 0.0;
        opacity = offset.distance /
            (Offset(pageSize.width, pageSize.height).distance / 2.0);
        return Colors.black.withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
      },
    );
  }
}

///  显示顶栏 底栏 slider等
class ImagePlugins extends GetView<ViewExtController> {
  const ImagePlugins({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  ViewExtState get vState => controller.vState;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          GetBuilder<ViewExtController>(
            id: idViewBar,
            builder: (logic) {
              return AnimatedPositioned(
                curve: Curves.fastOutSlowIn,
                duration: const Duration(milliseconds: 300),
                top: logic.vState.topBarOffset,
                // top: 50,
                child: const ViewTopBar(),
              );
            },
          ),
          GetBuilder<ViewExtController>(
            id: idViewBar,
            builder: (logic) {
              return AnimatedPositioned(
                curve: Curves.fastOutSlowIn,
                duration: const Duration(milliseconds: 300),
                bottom: logic.vState.bottomBarOffset,
                child: const ViewBottomBar(),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 控制触摸手势事件
class ImageGestureDetector extends GetView<ViewExtController> {
  const ImageGestureDetector({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        child,
        // 非中心触摸区
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: controller.tapLeft,
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: controller.tapRight,
              ),
            ),
          ],
        ),
        // 中心触摸区
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Container(
            // key: controller.vState.centkey,
            height: context.height / 4,
            width: context.width / 2.5,
          ),
          onTap: controller.handOnTapCent,
        ),
      ],
    );
  }
}
