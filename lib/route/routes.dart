import 'package:fluro/fluro.dart';

import 'router_handler.dart';

class EHRoutes {
  static const String root = '/';
  static const String home = '/home';
  static const String galleryList = '/galleryList';

  static const String selFavorie = '/selFavoriePage';

  static const String ehSetting = '/setting/ehSetting';
  static const String advancedSetting = '/setting/advancedSetting';
  static const String about = '/setting/about';

  static const String login = '/login';
  static const String webLogin = '/webLogin';

  static const String galleryDetail = '/galleryDetailPage';
  static const String galleryDetailComment = '/galleryDetailPage/comment';
  static const String galleryDetailView = '/galleryDetailPage/view';

  static void configureRoutes(Router router) {
    pageRoutes.forEach((String path, Handler handler) {
      router.define(path,
          handler: handler, transitionType: TransitionType.cupertino);
    });
  }
}
