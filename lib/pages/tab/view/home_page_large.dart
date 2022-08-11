import 'dart:math';

import 'package:fehviewer/common/controller/cache_controller.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:fehviewer/pages/gallery/view/add_tags_page.dart';
import 'package:fehviewer/pages/gallery/view/all_preview_page.dart';
import 'package:fehviewer/pages/gallery/view/comment_page.dart';
import 'package:fehviewer/pages/gallery/view/gallery_info_page.dart';
import 'package:fehviewer/pages/gallery/view/sliver/gallery_page_sliver.dart';
import 'package:fehviewer/pages/setting/about_page.dart';
import 'package:fehviewer/pages/setting/advanced_setting_page.dart';
import 'package:fehviewer/pages/setting/avatar_setting_page.dart';
import 'package:fehviewer/pages/setting/controller/tab_setting_controller.dart';
import 'package:fehviewer/pages/setting/custom_hosts_page.dart';
import 'package:fehviewer/pages/setting/download_setting_page.dart';
import 'package:fehviewer/pages/setting/eh_mysettings_page.dart';
import 'package:fehviewer/pages/setting/eh_setting_page.dart';
import 'package:fehviewer/pages/setting/image_hide/phash_list_page.dart';
import 'package:fehviewer/pages/setting/image_hide_page.dart';
import 'package:fehviewer/pages/setting/license_page.dart';
import 'package:fehviewer/pages/setting/log_page.dart';
import 'package:fehviewer/pages/setting/mytags/eh_mytags_page.dart';
import 'package:fehviewer/pages/setting/mytags/eh_usertag_page.dart';
import 'package:fehviewer/pages/setting/search_setting_page.dart';
import 'package:fehviewer/pages/setting/security_setting_page.dart';
import 'package:fehviewer/pages/setting/tab_setting.dart';
import 'package:fehviewer/pages/setting/tag_translat_page.dart';
import 'package:fehviewer/pages/setting/view/login_webdav.dart';
import 'package:fehviewer/pages/setting/view_setting_page.dart';
import 'package:fehviewer/pages/setting/webdav_setting_page.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/view/download_page.dart';
import 'package:fehviewer/pages/tab/view/quick_search_page.dart';
import 'package:fehviewer/pages/tab/view/tabbar/custom_profile_setting_page.dart';
import 'package:fehviewer/pages/tab/view/tabbar/custom_profiles_page.dart';
import 'package:fehviewer/route/app_pages.dart';
import 'package:fehviewer/route/main_observer.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/route/second_observer.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../route/first_observer.dart';
import 'empty.dart';
import 'home_page_small.dart';

const kMinWidth = 320.0;

class TabHomeLarge extends GetView<TabHomeController> {
  const TabHomeLarge({
    Key? key,
    this.sideProportion = 0.0,
  }) : super(key: key);
  final double sideProportion;

  double getSideWidth(BuildContext context) {
    double _width = kMinWidth;

    if (context.width >= 1366) {
      _width = 420;
    }
    if (context.width >= 1024) {
      _width = 390;
    }

    _width = kMinWidth + (context.width - 2 * kMinWidth) * sideProportion;
    logger.v('width:${context.width} $_width}');
    return min(max(_width, kMinWidth), context.width - kMinWidth);
  }

  @override
  Widget build(BuildContext context) {
    // logger.d('width:${context.width} ${getSideWidth(context)}');
    final mainNavigatorObserver = MainNavigatorObserver();
    return Row(
      children: [
        AnimatedContainer(
          width: getSideWidth(context),
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
          child: ClipRect(
            child: Navigator(
                key: Get.nestedKey(1),
                observers: [
                  FirstNavigatorObserver(),
                  if (mainNavigatorObserver.navigator != null)
                    mainNavigatorObserver
                ],
                onGenerateRoute: (settings) {
                  final GetPage? _route = AppPages.routes
                      .firstWhereOrNull((GetPage e) => e.name == settings.name);
                  if (_route != null &&
                      _route.name != EHRoutes.root &&
                      _route.name != EHRoutes.home) {
                    return GetPageRoute(
                      settings: settings,
                      showCupertinoParallax: false,
                      page: _route.page,
                    );
                  } else {
                    return GetPageRoute(
                      settings: settings,
                      page: () => const TabHomeSmall(),
                      showCupertinoParallax: false,
                    );
                  }
                }),
          ),
        ),
        Expanded(
          child: SideControllerbar(
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
                      // observers: [MainNavigatorObserver()],
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
                              page: () => const EhSettingPage(),
                              transition: Transition.fadeIn,
                              showCupertinoParallax: false,
                            );
                          case EHRoutes.readSeting:
                            return GetPageRoute(
                              settings: settings,
                              page: () => const ReadSettingPage(),
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
                              page: () => const AdvancedSettingPage(),
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
                          case EHRoutes.tagTranslat:
                            return GetPageRoute(
                              settings: settings,
                              page: () => TagTranslatePage(),
                            );
                          case EHRoutes.avatarSetting:
                            return GetPageRoute(
                              settings: settings,
                              page: () => AvatarSettingPage(),
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
                              page: () => GallerySliverPage(),
                              transition: Transition.fadeIn,
                              showCupertinoParallax: false,
                              // fullscreenDialog: true,
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
                                    tag: pageCtrlTag),
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
                              popGesture: false,
                              transition: Transition.fadeIn,
                            );
                          case EHRoutes.download:
                            return GetPageRoute(
                              settings: settings,
                              page: () => const DownloadTab(),
                            );
                          case EHRoutes.mySettings:
                            return GetPageRoute(
                              settings: settings,
                              page: () => const EhMySettingsPage(),
                            );
                          case EHRoutes.myTags:
                            return GetPageRoute(
                              settings: settings,
                              page: () => const EhMyTagsPage(),
                            );
                          case EHRoutes.userTags:
                            return GetPageRoute(
                              settings: settings,
                              page: () => const EhUserTagsPage(),
                            );
                          case EHRoutes.imageHide:
                            return GetPageRoute(
                              settings: settings,
                              page: () => const ImageHidePage(),
                            );
                          case EHRoutes.mangaHidedImage:
                            return GetPageRoute(
                              settings: settings,
                              page: () => const PHashImageListPage(),
                            );
                          case EHRoutes.loginWebDAV:
                            return GetPageRoute(
                              settings: settings,
                              page: () => const LoginWebDAV(),
                            );
                          case EHRoutes.customProfiles:
                            return GetPageRoute(
                              settings: settings,
                              page: () => const CustomProfilesPage(),
                            );
                          case EHRoutes.customProfileSetting:
                            return GetPageRoute(
                              settings: settings,
                              page: () => const CustomProfileSettingPage(),
                            );
                          case EHRoutes.license:
                            return GetPageRoute(
                              settings: settings,
                              page: () => customLicensePage,
                            );
                          default:
                            return GetPageRoute(
                              settings: settings,
                              routeName: EHRoutes.empty,
                              page: () => const EmptyPage(),
                              popGesture: false,
                              transition: Transition.fadeIn,
                            );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SideControllerbar extends StatefulWidget {
  const SideControllerbar({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  _SideControllerbarState createState() => _SideControllerbarState();
}

class _SideControllerbarState extends State<SideControllerbar> {
  bool isTapDown = false;
  final LayoutServices layoutServices = Get.find();

  Widget _normalBar({bool dragging = false}) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        color:
            CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context)
                .withOpacity(0.7),
        borderRadius: BorderRadius.circular(dragging ? 5.0 : 1.5),
      ),
      margin: EdgeInsets.only(
          left: dragging ? 5.0 : 2.0, right: dragging ? 5.0 : 20.0),
      height: dragging ? 80 : 55,
      width: dragging ? 10 : 3,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
      child: const SizedBox.expand(),
    );
  }

  Widget getbar() {
    return _normalBar(dragging: isTapDown);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        widget.child,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (details) {
            setState(() {
              isTapDown = true;
            });
          },
          onPanEnd: (_) {
            setState(() {
              isTapDown = false;
            });
          },
          onPanCancel: () {
            setState(() {
              isTapDown = false;
            });
          },
          onPanUpdate: (details) {
            final proportion = layoutServices.sideProportion +
                details.delta.dx / (context.width - 2 * kMinWidth);

            layoutServices.sideProportion = max(min(1.0, proportion), 0.0);
          },
          child: getbar(),
        ),
      ],
    );
  }
}
