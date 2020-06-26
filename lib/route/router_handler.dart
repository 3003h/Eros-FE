import 'package:FEhViewer/pages/favorite_page.dart';
import 'package:FEhViewer/pages/login_page.dart';
import 'package:FEhViewer/pages/setting/eh_setting_page.dart';
import 'package:FEhViewer/pages/splash_page.dart';

import 'package:FEhViewer/pages/home_page.dart';
import 'package:FEhViewer/pages/http_test.dart';
import 'package:FEhViewer/pages/user/browser.dart';
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

Handler ehSettingHanderl = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return EhSettingPage();
});

Handler loginHanderl = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return LoginPage();
});

Handler webLoginHanderl = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  String title = params["title"]?.first;
  String url = params["url"]?.first;
//  debugPrint('title $title   url $url');
  return WebLogin(title: title, url: url);
});
