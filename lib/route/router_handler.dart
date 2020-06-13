import 'package:FEhViewer/pages/favorite_page.dart';
import 'package:FEhViewer/pages/splash_page.dart';

import 'package:FEhViewer/pages/home_page.dart';
import 'package:FEhViewer/pages/http_test.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';


// 闪屏
Handler splashPageHanderl = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return SplashPage();
  },
);

// 正常路由跳转 homepage
Handler homePageHanderl = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return FEhHome();
});

Handler httpPageHanderl = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return HttpTestRoute();
});

Handler selFavoriteHanderl = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SelFavorite();
});

