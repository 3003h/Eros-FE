import 'package:eros_fe/models/base/eh_models.dart';
import 'package:get/get.dart';

import '../global.dart';

enum LayoutMode {
  small,
  large,
}

LayoutMode get layoutMode => Get.find<LayoutServices>().layoutMode;
bool get isLayoutLarge => Get.find<LayoutServices>().isLayoutLarge;

EhLayoutHelper ehLayoutHelper = EhLayoutHelper();

class EhLayoutHelper {
  LayoutServices layoutServices = Get.find();

  bool get isLayoutLarge => layoutServices.isLayoutLarge;
}

class LayoutServices extends GetxService {
  LayoutMode layoutMode = LayoutMode.small;
  bool get isLayoutLarge => layoutMode == LayoutMode.large;

  late EhLayout _ehLayout;

  final _half = false.obs;
  bool get half => _half.value;
  set half(bool val) => _half.value = val;

  final _sideProportion = 0.0.obs;
  double get sideProportion => _sideProportion.value;
  set sideProportion(double val) => _sideProportion.value = val;

  @override
  void onInit() {
    super.onInit();

    _ehLayout = hiveHelper.getEhLayout();
    sideProportion = _ehLayout.sideProportion ?? 0.0;

    debounce<double>(
      _sideProportion,
      (double val) {
        _ehLayout = _ehLayout.copyWith(sideProportion: val.oN);
        hiveHelper.setEhLayout(_ehLayout);
      },
      time: const Duration(milliseconds: 3000),
    );
  }
}
