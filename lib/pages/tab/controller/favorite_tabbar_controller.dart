import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/controller/favorite_sel_controller.dart';
import 'package:get/get.dart';

import 'default_tabview_controller.dart';

class FavoriteTabberController extends DefaultTabViewController {
  final FavoriteSelectorController favoriteSelectorController = Get.find();

  List<Favcat> get favcatList => favoriteSelectorController.favcatList;

  @override
  void onInit() {
    super.onInit();
  }
}
