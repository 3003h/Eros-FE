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

  static const String chanelDetail = '/chanelDetail';

  static const String httpPage = "/httpPage";

  static void configureRoutes(Router router) {
    // router.notFoundHandler = new Handler(
    //     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    //    print("ROUTE WAS NOT FOUND !!!");
    // });

    router.define(root,
        handler: splashPageHanderl, transitionType: TransitionType.cupertino);

    router.define(home,
        handler: homePageHanderl, transitionType: TransitionType.cupertino);

    router.define(selFavorie,
        handler: selFavoriteHanderl, transitionType: TransitionType.cupertino);

    router.define(ehSetting,
        handler: ehSettingHanderl, transitionType: TransitionType.cupertino);

    router.define(login,
        handler: loginHanderl, transitionType: TransitionType.cupertino);

    router.define(webLogin,
        handler: webLoginHanderl, transitionType: TransitionType.cupertino);

    router.define(galleryDetail,
        handler: galleryDetailHanderl,
        transitionType: TransitionType.cupertino);

    router.define(httpPage,
        handler: httpPageHanderl, transitionType: TransitionType.cupertino);
  }
}
