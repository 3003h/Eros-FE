import 'dart:convert';

import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/pages/favorite_sel_page.dart';
import 'package:FEhViewer/pages/gallery_detail/comment_page.dart';
import 'package:FEhViewer/pages/gallery_view/gallery_view_page.dart';
import 'package:FEhViewer/pages/home_page.dart';
import 'package:FEhViewer/pages/login_page.dart';
import 'package:FEhViewer/pages/setting/eh_setting_page.dart';
import 'package:FEhViewer/pages/splash_page.dart';
import 'package:FEhViewer/pages/user/web_login.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

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
    return SelFavoritePage();
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

  EHRoutes.galleryDetailComment: Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    List<String> commentStringList = params["comment"] ?? [];
    List<GalleryComment> comments = List<GalleryComment>.from(commentStringList
        .map((commentString) =>
            GalleryComment.fromJson(jsonDecode(commentString)))
        .toList());

    return CommentPage(
      galleryComments: comments,
    );
  }),

  /*EHRoutes.galleryDetailView: Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    List<String> hrefs = params["href"] ?? [];
    String currentIndex = params["currentIndex"]?.first ?? '0';
    String showKey = params["showKey"]?.first ?? '';

    return GalleryViewPageE(
      hrefs: hrefs,
      index: int.parse(currentIndex),
      showKey: showKey,
    );
  }),*/
};
