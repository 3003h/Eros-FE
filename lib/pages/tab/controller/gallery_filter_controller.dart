import 'package:eros_fe/common/controller/advance_search_controller.dart';
import 'package:eros_fe/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const double kHeight = 220.0;
const double kAdvanceHeight = 500.0;

class GalleryFilterController extends GetxController {
  final TextEditingController statrPageCtrl = TextEditingController();
  final TextEditingController endPageCtrl = TextEditingController();

  final AdvanceSearchController _advanceSearchController = Get.find();

  @override
  void onInit() {
    super.onInit();

    // statrPageCtrl.text = _advanceSearchController.advanceSearch.value.startPage;
    // endPageCtrl.text = _advanceSearchController.advanceSearch.value.endPage;
    final startPage = _advanceSearchController.advanceSearch.value.startPage;
    final endPage = _advanceSearchController.advanceSearch.value.endPage;
    statrPageCtrl.value = TextEditingValue(
      text: startPage ?? '',
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: (startPage ?? '').length,
        ),
      ),
    );

    endPageCtrl.value = TextEditingValue(
      text: endPage ?? '',
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: (endPage ?? '').length,
        ),
      ),
    );

    statrPageCtrl.addListener(() {
      _advanceSearchController.advanceSearch(_advanceSearchController
          .advanceSearch.value
          .copyWith(startPage: statrPageCtrl.text.trim().oN));
    });
    endPageCtrl.addListener(() {
      _advanceSearchController.advanceSearch(_advanceSearchController
          .advanceSearch.value
          .copyWith(endPage: endPageCtrl.text.trim().oN));
    });
  }
}
