import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

enum LayoutMode {
  small,
  large,
}

LayoutMode get layoutMode => Get.find<LayoutServices>().layoutMode;
bool get isLayoutLarge => Get.find<LayoutServices>().isLayoutLarge;

EhLayout ehLayout = EhLayout();

class EhLayout {
  LayoutServices layoutServices = Get.find();
  GlobalKey<ExtendedImageSlidePageState> get slidePagekey =>
      layoutServices.slidePagekey;
}

class LayoutServices extends GetxService {
  LayoutMode layoutMode = LayoutMode.small;

  bool get isLayoutLarge => layoutMode == LayoutMode.large;

  final GlobalKey<ExtendedImageSlidePageState> slidePagekey =
      GlobalKey<ExtendedImageSlidePageState>();
}
