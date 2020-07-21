import 'dart:convert';

import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/pages/favorite_page.dart';
import 'package:FEhViewer/pages/gallery_detail/comment_page.dart';
import 'package:FEhViewer/pages/gallery_detail/gallery_detail_page.dart';
import 'package:FEhViewer/pages/home_page.dart';
import 'package:FEhViewer/pages/login_page.dart';
import 'package:FEhViewer/pages/setting/eh_setting_page.dart';
import 'package:FEhViewer/pages/splash_page.dart';
import 'package:FEhViewer/pages/user/browser.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    String title = params["title"]?.first ?? '';
    String galleryItemString = params["galleryItem"]?.first ?? '';
    GalleryItem galleryItem =
        GalleryItem.fromJson(jsonDecode(galleryItemString));
    return GalleryDetailPage(
      title: title,
      galleryItem: galleryItem,
    );
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
  })
};
