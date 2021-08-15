import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/route/routes.dart';

import 'tabview_controller.dart';

class PopularViewController extends TabViewController {
  @override
  void onInit() {
    fetchNormal = Api.getPopular;
    tabTag = EHRoutes.popular;
    super.onInit();
  }
}
