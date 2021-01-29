import 'package:fehviewer/network/gallery_request.dart';

import 'tabview_controller.dart';

class PopularViewController extends TabViewController {
  @override
  void onInit() {
    fetchNormal = Api.getPopular;
    super.onInit();
  }
}
