import 'dart:convert';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/galleryComment.dart';
import 'package:FEhViewer/models/galleryItem.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'application.dart';
import 'routes.dart';

class NavigatorUtil {
  // 返回
  static void goBack(BuildContext context) {
    /// 其实这边调用的是
//    Navigator.pop(context);
    Application.router.pop(context);
  }

  // 带参数的返回
  static void goBackWithParams(BuildContext context, result) {
    Navigator.pop(context, result);
  }

  // 路由返回指定页面
  static void goBackUrl(BuildContext context, String title) {
    Navigator.popAndPushNamed(context, title);
  }

  // 跳转到主页面
  static void goHomePage(BuildContext context) {
    Application.router.navigateTo(context, EHRoutes.home, replace: true);
  }

  /// 跳转到 转场动画 页面 ， 这边只展示 inFromLeft ，剩下的自己去尝试下，
  /// 框架自带的有 native，nativeModal，inFromLeft，inFromRight，inFromBottom，fadeIn，custom
  static Future jump(BuildContext context, String title) {
    return Application.router.navigateTo(context, title);
  }

  /// 框架自带的有 native，nativeModal，inFromLeft，inFromRight，inFromBottom，fadeIn，custom
  static Future jumpLeft(BuildContext context, String title) {
    return Application.router
        .navigateTo(context, title, transition: TransitionType.inFromLeft);

    /// 指定了 转场动画
  }

  // static Future jumpRemove(BuildContext context) {
  //    return Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(
  //             builder: (context) => IndexPage(),            ),
  //    (route) => route == null);
  // }

  /// 自定义 转场动画
  static Future gotransitionCustomDemoPage(BuildContext context, String title) {
    var transition = (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return new ScaleTransition(
        scale: animation,
        child: new RotationTransition(
          turns: animation,
          child: child,
        ),
      );
    };
    return Application.router.navigateTo(context, title,
        transition: TransitionType.custom,

        /// 指定是自定义动画
        transitionBuilder: transition,

        /// 自定义的动画
        transitionDuration: const Duration(milliseconds: 600));

    /// 时间
  }

  /// 使用 IOS 的 Cupertino 的转场动画
  static Future gotransitionCupertinoDemoPage(
      BuildContext context, String title) {
    return Application.router
        .navigateTo(context, title, transition: TransitionType.cupertino);
  }

  // // 跳转到主页面IndexPage并删除当前路由
  // static void goToHomeRemovePage(BuildContext context) {
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(
  //             builder: (context) => IndexPage(),
  //     ), (route) => route == null);
  // }

  // // 跳转到登录页并删除当前路由
  // static void goToLoginRemovePage(BuildContext context) {
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(
  //             builder: (context) => Login(),
  //         ), (route) => route == null);
  // }

  // 跳转到selfav
  static void goSelFavPage(BuildContext context) {
    Application.router.navigateTo(context, EHRoutes.selFavorie,
        transition: TransitionType.cupertino);
  }

  // goBrowser
  static void goWebLogin(BuildContext context, String title, String url) {
    final encodeUrl = Uri.encodeComponent(url);
    final encodeTitle = Uri.encodeComponent(title);
    Global.logger.i('encodeTitle $encodeTitle');
    Application.router.navigateTo(
        context, EHRoutes.webLogin + "?title=$encodeTitle&url=$encodeUrl",
        transition: TransitionType.cupertino);
  }

  /// 转到画廊页面
  static void goGalleryDetail(
    BuildContext context,
    String title,
    GalleryItem galleryItem, {
    @required fromTabIndex,
  }) {
    final encodeGalleryItem =
        Uri.encodeComponent(jsonEncode(galleryItem.toJson()));
    final encodeTitle = Uri.encodeComponent(title);
    Application.router.navigateTo(
        context,
        EHRoutes.galleryDetail +
            "?title=$encodeTitle&galleryItem=$encodeGalleryItem&fromTabIndex=$fromTabIndex",
        transition: TransitionType.cupertino);
  }

  /// 转到画廊评论页面
  static void goGalleryDetailComment(
      BuildContext context, List<GalleryComment> comments) {
    final encodeComments = List<String>.from(comments
        .map((comment) => Uri.encodeComponent(jsonEncode(comment.toJson())))
        .toList());

    final queryString = encodeComments.map((e) => 'comment=$e').join('&');

    Application.router.navigateTo(
        context, EHRoutes.galleryDetailComment + "?$queryString",
        transition: TransitionType.cupertino);
  }

  ///
  static void goGalleryViewPage(
      BuildContext context, List<String> images, int currentIndex) {
    final encodeImages = List<String>.from(
        images.map((image) => Uri.encodeComponent(image)).toList());

    var queryString = encodeImages.map((e) => 'image=$e').join('&');

    Application.router.navigateTo(
        context,
        EHRoutes.galleryDetailView +
            "?$queryString" +
            '&currentIndex=$currentIndex',
        transition: TransitionType.cupertino);
  }
}
