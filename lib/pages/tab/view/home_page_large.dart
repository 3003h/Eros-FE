import 'package:collection/collection.dart';
import 'package:fehviewer/common/controller/cache_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:fehviewer/pages/gallery/view/add_tags_page.dart';
import 'package:fehviewer/pages/gallery/view/all_preview_page.dart';
import 'package:fehviewer/pages/gallery/view/comment_page.dart';
import 'package:fehviewer/pages/gallery/view/gallery_info_page.dart';
import 'package:fehviewer/pages/gallery/view/gallery_page.dart';
import 'package:fehviewer/pages/setting/about_page.dart';
import 'package:fehviewer/pages/setting/advanced_setting_page.dart';
import 'package:fehviewer/pages/setting/controller/tab_setting_controller.dart';
import 'package:fehviewer/pages/setting/custom_hosts_page.dart';
import 'package:fehviewer/pages/setting/download_setting_page.dart';
import 'package:fehviewer/pages/setting/eh_setting_page.dart';
import 'package:fehviewer/pages/setting/log_page.dart';
import 'package:fehviewer/pages/setting/search_setting_page.dart';
import 'package:fehviewer/pages/setting/security_setting_page.dart';
import 'package:fehviewer/pages/setting/tab_setting.dart';
import 'package:fehviewer/pages/setting/webdav_setting_page.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/view/download_page.dart';
import 'package:fehviewer/pages/tab/view/quick_search_page.dart';
import 'package:fehviewer/route/app_pages.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/route/second_observer.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'empty.dart';
import 'home_page_small.dart';

class TabHomeLarge extends GetView<TabHomeController> {
  const TabHomeLarge({Key? key}) : super(key: key);

  double getSideWidth(BuildContext context) {
    if (context.width >= 1366) {
      return 420;
    }
    if (context.width >= 1024) {
      return 390;
    }
    if (context.width > 768) {
      return 320;
    }
    return 310;
  }

  @override
  Widget build(BuildContext context) {
    logger.d('width:${context.width} ${getSideWidth(context)}');
    return Row(
      children: [
        Container(
          width: getSideWidth(context),
          child: ClipRect(
            child: Navigator(
                key: Get.nestedKey(1),
                initialRoute: EHRoutes.home,
                onGenerateRoute: (settings) {
                  final GetPage? _route = AppPages.routes
                      .firstWhereOrNull((GetPage e) => e.name == settings.name);
                  if (_route != null &&
                      _route.name != EHRoutes.root &&
                      _route.name != EHRoutes.home) {
                    // logger.d('_route $_route');
                    return GetPageRoute(
                      page: _route.page,
                    );
                  } else {
                    return GetPageRoute(
                      page: () => TabHomeSmall(),
                    );
                  }
                }),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey4, context),
                width: 0.6,
              ),
              Expanded(
                child: ClipRect(
                  child: Navigator(
                    key: Get.nestedKey(2),
                    observers: [SecondNavigatorObserver()],
                    initialRoute: EHRoutes.empty,
                    onGenerateRoute: (settings) {
                      switch (settings.name) {
                        case EHRoutes.about:
                          return GetPageRoute(
                            settings: settings,
                            page: () => AboutPage(),
                            transition: Transition.fadeIn,
                            showCupertinoParallax: false,
                          );
                        case EHRoutes.ehSetting:
                          return GetPageRoute(
                            settings: settings,
                            page: () => EhSettingPage(),
                            transition: Transition.fadeIn,
                            showCupertinoParallax: false,
                          );
                        case EHRoutes.downloadSetting:
                          return GetPageRoute(
                            settings: settings,
                            page: () => DownloadSettingPage(),
                            transition: Transition.fadeIn,
                            showCupertinoParallax: false,
                          );
                        case EHRoutes.searchSetting:
                          return GetPageRoute(
                            settings: settings,
                            page: () => SearchSettingPage(),
                            transition: Transition.fadeIn,
                            showCupertinoParallax: false,
                          );
                        case EHRoutes.quickSearch:
                          return GetPageRoute(
                            settings: settings,
                            page: () => QuickSearchListPage(),
                          );
                        case EHRoutes.advancedSetting:
                          return GetPageRoute(
                            settings: settings,
                            page: () => AdvancedSettingPage(),
                            binding: BindingsBuilder(
                                () => Get.lazyPut(() => CacheController())),
                            transition: Transition.fadeIn,
                            showCupertinoParallax: false,
                          );
                        case EHRoutes.customHosts:
                          return GetPageRoute(
                            settings: settings,
                            page: () => CustomHostsPage(),
                          );
                        case EHRoutes.webDavSetting:
                          return GetPageRoute(
                            settings: settings,
                            page: () => WebDavSetting(),
                          );
                        case EHRoutes.logfile:
                          return GetPageRoute(
                            settings: settings,
                            page: () => LogPage(),
                          );
                        case EHRoutes.securitySetting:
                          return GetPageRoute(
                            settings: settings,
                            page: () => SecuritySettingPage(),
                            transition: Transition.fadeIn,
                            showCupertinoParallax: false,
                          );
                        case EHRoutes.galleryPage:
                          return GetPageRoute(
                            settings: settings,
                            page: () => GalleryMainPage(),
                            transition: Transition.fadeIn,
                            showCupertinoParallax: false,
                          );
                        case EHRoutes.galleryComment:
                          return GetPageRoute(
                            settings: settings,
                            page: () => CommentPage(),
                          );
                        case EHRoutes.galleryAllPreviews:
                          return GetPageRoute(
                            settings: settings,
                            page: () => const AllPreviewPage(),
                          );
                        case EHRoutes.addTag:
                          return GetPageRoute(
                            settings: settings,
                            page: () => AddTagPage(),
                            binding: BindingsBuilder(
                              () => Get.lazyPut(() => TagInfoController(),
                                  tag: pageCtrlDepth),
                            ),
                          );
                        case EHRoutes.galleryInfo:
                          return GetPageRoute(
                            settings: settings,
                            page: () => const GalleryInfoPage(),
                          );
                        case EHRoutes.pageSetting:
                          return GetPageRoute(
                            settings: settings,
                            page: () => TabSettingPage(),
                            binding: BindingsBuilder(
                              () => Get.lazyPut(() => TabSettingController()),
                            ),
                          );
                        case EHRoutes.empty:
                          return GetPageRoute(
                            settings: settings,
                            page: () => const EmptyPage(),
                            // page: () => Container(),
                          );
                        case EHRoutes.download:
                          return GetPageRoute(
                            settings: settings,
                            page: () => const DownloadTab(),
                          );
                        default:
                          return GetPageRoute(
                            settings: settings,
                            routeName: EHRoutes.empty,
                            page: () => const EmptyPage(),
                            // page: () => Container(),
                            transition: Transition.fadeIn,
                          );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          // child: CupertinoPageScaffold(child: Container()),
        ),
      ],
    );
  }
}
