import 'router_handler.dart';
import 'package:fluro/fluro.dart';

class EHRoutes {
  static const String root = "/";
  static const String home = "/home";
  static const String selFavorie = "/selFavoriePage";
  static const String ehSetting = "/ehSetting";
  static const String login = "/login";
  static const String webLogin = "/webLogin";

  static const String galleryDetail = "/galleryDetailPage";

  static void configureRoutes(Router router) {
    pageRoutes.forEach((path, handler) {
      router.define(path,
          handler: handler, transitionType: TransitionType.cupertino);
    });
  }
}
