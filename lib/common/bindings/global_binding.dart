import 'package:FEhViewer/common/controller/advance_search_controller.dart';
import 'package:FEhViewer/common/controller/ehconfig_controller.dart';
import 'package:get/get.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    // Get.put(EhConfigController(), permanent: true);
    // Get.put(AdvanceSearchController(), permanent: true);
    Get.lazyPut(() => EhConfigController(), fenix: true);
    Get.lazyPut(() => AdvanceSearchController(), fenix: true);
  }
}
