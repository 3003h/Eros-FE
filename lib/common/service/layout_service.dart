import 'package:get/get.dart';

enum LayoutMode {
  small,
  large,
}

LayoutMode get layoutMode => Get.find<LayoutServices>().layoutMode;
bool get isLayoutLarge => Get.find<LayoutServices>().isLayoutLarge;

class LayoutServices extends GetxService {
  LayoutMode layoutMode = LayoutMode.small;

  bool get isLayoutLarge => layoutMode == LayoutMode.large;
}
