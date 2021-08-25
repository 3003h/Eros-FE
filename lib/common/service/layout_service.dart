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
  // GlobalKey<ExtendedImageSlidePageState> get slidePagekey =>
  //     layoutServices.slidePagekey;

  bool get isLayoutLarge => layoutServices.isLayoutLarge;
}

class LayoutServices extends GetxService {
  LayoutMode layoutMode = LayoutMode.small;

  bool get isLayoutLarge => layoutMode == LayoutMode.large;

  final _half = false.obs;
  bool get half => _half.value;
  set half(bool val) => _half.value = val;

  // final GlobalKey<ExtendedImageSlidePageState> slidePagekey =
  //     GlobalKey<ExtendedImageSlidePageState>();
}
