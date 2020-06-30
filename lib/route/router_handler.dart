import 'dart:convert';

import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/pages/favorite_page.dart';
import 'package:FEhViewer/pages/gallery_detail_page.dart';
import 'package:FEhViewer/pages/login_page.dart';
import 'package:FEhViewer/pages/setting/eh_setting_page.dart';
import 'package:FEhViewer/pages/splash_page.dart';

import 'package:FEhViewer/pages/home_page.dart';
import 'package:FEhViewer/pages/user/browser.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

final Map<String, Handler> pageRoutes = {
  // 闪屏
  EHRoutes.root: Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return SplashPage();
    },
  ),
  // home
  EHRoutes.home: Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return FEhHome();
  }),

  //
  EHRoutes.selFavorie: Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return SelFavorite();
  }),

  EHRoutes.ehSetting: Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return EhSettingPage();
  }),

  EHRoutes.login: Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return LoginPage();
  }),

  EHRoutes.webLogin: Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    String title = params["title"]?.first;
    String url = params["url"]?.first;

    return WebLogin(title: title, url: url);
  }),

  EHRoutes.galleryDetail: Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    String title = params["title"]?.first;
    String galleryItemString = params["galleryItem"]?.first;
    // Global.logger.v("galleryItemString   $galleryItemString");
    GalleryItem galleryItem =
        GalleryItem.fromJson(jsonDecode(galleryItemString));
    return GalleryDetailPage(
      title: title,
      galleryItem: galleryItem,
    );
  }),
};
