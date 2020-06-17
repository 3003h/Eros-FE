import 'router_handler.dart';
import 'package:fluro/fluro.dart';

class EHRoutes {
  static const String root = "/";
  static const String home = "/home";
  static const String selFavorie = "/favoriePage/selFavoriePage";
  static const String ehSetting = "/ehSetting";
  static const String login = "/login";

  static const String chanelDetail = '/chanelDetail';

  static const String httpPage = "/httpPage";

  static void configureRoutes(Router router) {
    // router.notFoundHandler = new Handler(
    //     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    //    print("ROUTE WAS NOT FOUND !!!");
    // });

    /// 第一个参数是路由地址，第二个参数是页面跳转和传参，第三个参数是默认的转场动画，可以看上图
    /// 我这边先不设置默认的转场动画，转场动画在下面会讲，可以在另外一个地方设置（可以看NavigatorUtil类）
    ///
    
    router.define(root, handler: splashPageHanderl);
    router.define(home, handler: homePageHanderl);

    router.define(selFavorie, handler: selFavoriteHanderl);
    router.define(ehSetting, handler: ehSettingHanderl);
    router.define(login, handler: loginHanderl);


    router.define(httpPage, handler: httpPageHanderl);
  }
}
