import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/view_ext_contorller.dart';
import '../controller/view_ext_state.dart';

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
  final ViewExtController controller = Get.put(ViewExtController());
  late AnimationController _doubleClickAnimationController;
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  List<double> doubleTapScales = <double>[1.0, 2.0];
  ViewExtState get vState => controller.vState;

  @override
  void initState() {
    super.initState();
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    Widget itemBuilder(BuildContext context, int index) {
      if (vState.loadType == LoadType.file) {
        final path = vState.imagePathList[index];
        final Widget image = ExtendedImage.file(
          File(path),
          fit: BoxFit.contain,
          enableSlideOutPage: true,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (ExtendedImageState state) {
            double? initialScale = 1.0;

            if (state.extendedImageInfo != null) {
              initialScale = initScale(
                  size: size,
                  initialScale: initialScale,
                  imageSize: Size(
                      state.extendedImageInfo!.image.width.toDouble(),
                      state.extendedImageInfo!.image.height.toDouble()));
            }
            return GestureConfig(
                inPageView: true,
                initialScale: initialScale!,
                maxScale: max(initialScale, 5.0),
                animationMaxScale: max(initialScale, 5.0),
                initialAlignment: InitialAlignment.center,
                //you can cache gesture state even though page view page change.
                //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
                cacheGesture: false);
          },
          onDoubleTap: (ExtendedImageGestureState state) {
            ///you can use define pointerDownPosition as you can,
            ///default value is double tap pointer down postion.
            final Offset? pointerDownPosition = state.pointerDownPosition;
            final double? begin = state.gestureDetails!.totalScale;
            double end;

            //remove old
            _doubleClickAnimation
                ?.removeListener(_doubleClickAnimationListener);

            //stop pre
            _doubleClickAnimationController.stop();

            //reset to use
            _doubleClickAnimationController.reset();

            if (begin == doubleTapScales[0]) {
              end = doubleTapScales[1];
            } else {
              end = doubleTapScales[0];
            }

            _doubleClickAnimationListener = () {
              state.handleDoubleTap(
                  scale: _doubleClickAnimation!.value,
                  doubleTapPosition: pointerDownPosition);
            };
            _doubleClickAnimation = _doubleClickAnimationController
                .drive(Tween<double>(begin: begin, end: end));

            _doubleClickAnimation!.addListener(_doubleClickAnimationListener);

            _doubleClickAnimationController.forward();
          },
        );

        return image.paddingSymmetric(horizontal: 2.0);
      } else {
        return Container(
          child: Text('$index'),
        );
      }
    }

    Widget result = ExtendedImageGesturePageView.builder(
      controller: controller.pageController,
      itemBuilder: itemBuilder,
      itemCount: vState.pageCount,
      onPageChanged: controller.handOnPageChanged,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
    );

    result = ExtendedImageSlidePage(
      child: result,
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
      resetPageDuration: const Duration(milliseconds: 300),
      slidePageBackgroundHandler: (Offset offset, Size pageSize) {
        double opacity = 0.0;
        opacity = offset.distance /
            (Offset(pageSize.width, pageSize.height).distance / 2.0);
        return Colors.black.withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
      },
    );

    // return result;

    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      child: result,
    );
  }
}
