import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      child: ImagePageView(),
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
          // return Row(
          //   children: [
          //     Expanded(child: ViewImageExt(imageSer: index + 1)),
          //     Expanded(child: ViewImageExt(imageSer: index + 1))
          //   ],
          // );
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
