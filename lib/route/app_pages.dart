import 'package:eros_fe/common/controller/cache_controller.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/gallery/controller/taginfo_controller.dart';
import 'package:eros_fe/pages/gallery/view/add_tags_page.dart';
import 'package:eros_fe/pages/gallery/view/all_thumbnails_page.dart';
import 'package:eros_fe/pages/gallery/view/comment_page.dart';
import 'package:eros_fe/pages/gallery/view/gallery_info_page.dart';
import 'package:eros_fe/pages/gallery/view/sliver/gallery_page.dart';
import 'package:eros_fe/pages/image_view/controller/view_controller.dart';
import 'package:eros_fe/pages/image_view/view/view_page.dart';
import 'package:eros_fe/pages/login/controller/login_controller.dart';
import 'package:eros_fe/pages/login/view/login_page.dart';
import 'package:eros_fe/pages/login/view/web_login_in.dart';
import 'package:eros_fe/pages/setting/about_page.dart';
import 'package:eros_fe/pages/setting/advanced_setting_page.dart';
import 'package:eros_fe/pages/setting/avatar_setting_page.dart';
import 'package:eros_fe/pages/setting/block/block_rule_edit_page.dart';
import 'package:eros_fe/pages/setting/block/block_rules_page.dart';
import 'package:eros_fe/pages/setting/block/blockers_page.dart';
import 'package:eros_fe/pages/setting/controller/tab_setting_controller.dart';
import 'package:eros_fe/pages/setting/custom_hosts_page.dart';
import 'package:eros_fe/pages/setting/download_setting_page.dart';
import 'package:eros_fe/pages/setting/eh_mysettings_page.dart';
import 'package:eros_fe/pages/setting/eh_setting_page.dart';
import 'package:eros_fe/pages/setting/image_block/image_block_page.dart';
import 'package:eros_fe/pages/setting/image_block/phash_list_page.dart';
import 'package:eros_fe/pages/setting/item_width_setting_page.dart';
import 'package:eros_fe/pages/setting/layout_setting_page.dart';
import 'package:eros_fe/pages/setting/license_page.dart';
import 'package:eros_fe/pages/setting/log_page.dart';
import 'package:eros_fe/pages/setting/mysql/mysql_sync_page.dart';
import 'package:eros_fe/pages/setting/mytags/eh_mytags_page.dart';
import 'package:eros_fe/pages/setting/mytags/eh_usertag_page.dart';
import 'package:eros_fe/pages/setting/proxy_page.dart';
import 'package:eros_fe/pages/setting/read_setting_page.dart';
import 'package:eros_fe/pages/setting/search_setting_page.dart';
import 'package:eros_fe/pages/setting/security_setting_page.dart';
import 'package:eros_fe/pages/setting/tabbar_setting_page.dart';
import 'package:eros_fe/pages/setting/tag_translat_page.dart';
import 'package:eros_fe/pages/setting/webdav/login_webdav.dart';
import 'package:eros_fe/pages/setting/webdav/webdav_setting_page.dart';
import 'package:eros_fe/pages/tab/bindings/splash_binding.dart';
import 'package:eros_fe/pages/tab/view/download_page.dart';
import 'package:eros_fe/pages/tab/view/empty.dart';
import 'package:eros_fe/pages/tab/view/favorite_sel_page.dart';
import 'package:eros_fe/pages/tab/view/history_page.dart';
import 'package:eros_fe/pages/tab/view/home_page.dart';
import 'package:eros_fe/pages/tab/view/quick_search_page.dart';
import 'package:eros_fe/pages/tab/view/search_image_page.dart';
import 'package:eros_fe/pages/tab/view/search_page.dart';
import 'package:eros_fe/pages/tab/view/splash_page.dart';
import 'package:eros_fe/pages/tab/view/tabbar/custom_profile_setting_page.dart';
import 'package:eros_fe/pages/tab/view/tabbar/custom_profiles_page.dart';
import 'package:eros_fe/pages/tab/view/tabbar/custom_tabbar_page.dart';
import 'package:eros_fe/pages/tab/view/tabbar/favorite_tabbar_page.dart';
import 'package:eros_fe/pages/tab/view/toplist_page.dart';
import 'package:eros_fe/pages/tab/view/unlock_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const Duration kUnLockPageTransitionDuration = Duration(milliseconds: 200);

class AppPages {
  static final List<GetPage> routes = <GetPage>[
    GetPage(
      name: EHRoutes.root,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: EHRoutes.empty,
      page: () => const EmptyPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: EHRoutes.unlockPage,
      page: () => const UnLockPage(),
      transition: Transition.noTransition,
      // transitionDuration: kUnLockPageTransitionDuration,
    ),
    GetPage(
      name: EHRoutes.home,
      page: () => const HomePage(),
      // page: () => const TabHomeSmall(),
      // transition: Transition.fadeIn,
    ),
    GetPage(
      name: EHRoutes.selFavorite,
      page: () => const FavoriteSelectorPage(),
    ),
    GetPage(
      name: EHRoutes.ehSetting,
      page: () => const EhSettingPage(),
    ),
    GetPage(
      name: EHRoutes.layoutSetting,
      page: () => const LayoutSettingPage(),
    ),
    GetPage(
      name: EHRoutes.itemWidthSetting,
      page: () => const ItemWidthSettingPage(),
    ),
    GetPage(
      name: EHRoutes.advancedSetting,
      page: () => const AdvancedSettingPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => CacheController())),
    ),
    GetPage(
      name: EHRoutes.about,
      page: () => const AboutPage(),
    ),
    GetPage(
      name: EHRoutes.license,
      page: () => const LicensePage(),
    ),
    GetPage(
      name: EHRoutes.downloadSetting,
      page: () => const DownloadSettingPage(),
    ),
    GetPage(
      name: EHRoutes.searchSetting,
      page: () => const SearchSettingPage(),
    ),
    GetPage(
      name: EHRoutes.securitySetting,
      page: () => const SecuritySettingPage(),
    ),
    GetPage(
      name: EHRoutes.readSetting,
      page: () => const ReadSettingPage(),
    ),
    GetPage(
      name: EHRoutes.login,
      page: () => const LoginPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => LoginController()),
      ),
    ),
    GetPage(
      name: EHRoutes.webLogin,
      page: () => WebLoginViewIn(),
    ),
    GetPage(
      name: EHRoutes.galleryComment,
      page: () => const CommentPage(),
    ),
    GetPage(
      name: EHRoutes.galleryAllThumbnails,
      page: () => const AllThumbnailsPage(),
    ),
    GetPage(
      name: EHRoutes.addTag,
      page: () => const AddTagPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => TagInfoController(), tag: pageCtrlTag),
      ),
    ),
    GetPage(
      name: EHRoutes.galleryInfo,
      page: () => const GalleryInfoPage(),
    ),
    GetPage(
      name: EHRoutes.pageSetting,
      page: () => const TabbarSettingPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => TabSettingController()),
      ),
    ),
    GetPage(
      name: EHRoutes.history,
      page: () => const HistoryTab(),
    ),
    GetPage(
      name: EHRoutes.favorite,
      // page: () => const FavoriteTab(),
      page: () => const FavoriteTabTabBarPage(),
    ),
    GetPage(
      name: EHRoutes.favoriteTabbar,
      page: () => const FavoriteTabTabBarPage(),
    ),
    GetPage(
      name: EHRoutes.toplist,
      page: () => const ToplistTab(),
      // page: () => const ToplistTabDebug(),
    ),
    GetPage(
      name: EHRoutes.download,
      page: () => const DownloadTab(),
    ),
    GetPage(
      name: EHRoutes.gallery,
      // page: () => const GalleryListTab(),
      page: () => const CustomTabbarList(),
    ),
    GetPage(
      name: EHRoutes.galleryViewExt,
      page: () => const ViewPage(),
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut(() => ViewExtController(), fenix: true);
      }),
      // opaque: kDebugMode,
      opaque: GetPlatform.isIOS,
      showCupertinoParallax: false,
    ),
    GetPage(
      name: EHRoutes.galleryPage,
      // page: () => const GallerySliverPage(),
      page: () => const GalleryPage(),
      preventDuplicates: false,
    ),
    GetPage(
      name: EHRoutes.search,
      page: () => const GallerySearchPage(),
      // page: () => const SearchPage(),
      // page: () => const EmptyPage(),
      preventDuplicates: false,
    ),
    GetPage(
      name: EHRoutes.quickSearch,
      page: () => const QuickSearchListPage(),
    ),
    GetPage(
      name: EHRoutes.customHosts,
      page: () => const CustomHostsPage(),
    ),
    GetPage(
      name: EHRoutes.proxySetting,
      page: () => const ProxyPage(),
    ),
    GetPage(
      name: EHRoutes.webDavSetting,
      page: () => const WebDavSetting(),
    ),
    GetPage(
      name: EHRoutes.mysqlSync,
      page: () => const MysqlSyncPage(),
    ),
    GetPage(
      name: EHRoutes.avatarSetting,
      page: () => const AvatarSettingPage(),
    ),
    GetPage(
      name: EHRoutes.tagTranslate,
      page: () => const TagTranslatePage(),
    ),
    GetPage(
      name: EHRoutes.blockers,
      page: () => const BlockersPage(),
    ),
    GetPage(
      name: EHRoutes.blockRules,
      page: () => const BlockRulesPage(),
    ),
    GetPage(
      name: EHRoutes.blockRuleEdit,
      page: () => const BlockRuleEditPage(),
    ),
    GetPage(
      name: EHRoutes.logfile,
      page: () => const LogPage(),
    ),
    GetPage(
      name: EHRoutes.mySettings,
      page: () => const EhMySettingsPage(),
    ),
    GetPage(
      name: EHRoutes.myTags,
      page: () => const EhMyTagsPage(),
    ),
    GetPage(
      name: EHRoutes.userTags,
      page: () => const EhUserTagsPage(),
    ),
    GetPage(
      name: EHRoutes.imageHide,
      page: () => const ImageBlockPage(),
    ),
    GetPage(
      name: EHRoutes.mangaHidedImage,
      page: () => const PHashImageListPage(),
    ),
    GetPage(
      name: EHRoutes.loginWebDAV,
      page: () => const LoginWebDAV(),
    ),
    GetPage(
      name: EHRoutes.customList,
      page: () => const CustomTabbarList(),
    ),
    GetPage(
      name: EHRoutes.customProfiles,
      page: () => const CustomProfilesPage(),
    ),
    GetPage(
      name: EHRoutes.customProfileSetting,
      page: () => const CustomProfileSettingPage(),
    ),
    GetPage(
      name: EHRoutes.searchImage,
      page: () => SearchImagePage(),
    )
  ];

  static RouteFactory get onGenerateRoute => (settings) {
        switch (settings.name) {
          case EHRoutes.about:
            return GetPageRoute(
              settings: settings,
              page: () => const AboutPage(),
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
          case EHRoutes.layoutSetting:
            return GetPageRoute(
              settings: settings,
              page: () => const LayoutSettingPage(),
              transition: Transition.fadeIn,
              showCupertinoParallax: false,
            );
          case EHRoutes.itemWidthSetting:
            return GetPageRoute(
              settings: settings,
              page: () => const ItemWidthSettingPage(),
            );
          case EHRoutes.readSetting:
            return GetPageRoute(
              settings: settings,
              page: () => const ReadSettingPage(),
              transition: Transition.fadeIn,
              showCupertinoParallax: false,
            );
          case EHRoutes.downloadSetting:
            return GetPageRoute(
              settings: settings,
              page: () => const DownloadSettingPage(),
              transition: Transition.fadeIn,
              showCupertinoParallax: false,
            );
          case EHRoutes.searchSetting:
            return GetPageRoute(
              settings: settings,
              page: () => const SearchSettingPage(),
              transition: Transition.fadeIn,
              showCupertinoParallax: false,
            );
          case EHRoutes.quickSearch:
            return GetPageRoute(
              settings: settings,
              page: () => const QuickSearchListPage(),
            );
          case EHRoutes.advancedSetting:
            return GetPageRoute(
              settings: settings,
              page: () => const AdvancedSettingPage(),
              binding:
                  BindingsBuilder(() => Get.lazyPut(() => CacheController())),
              transition: Transition.fadeIn,
              showCupertinoParallax: false,
            );
          case EHRoutes.customHosts:
            return GetPageRoute(
              settings: settings,
              page: () => const CustomHostsPage(),
            );
          case EHRoutes.proxySetting:
            return GetPageRoute(
              settings: settings,
              page: () => const ProxyPage(),
            );
          case EHRoutes.webDavSetting:
            return GetPageRoute(
              settings: settings,
              page: () => const WebDavSetting(),
            );
          case EHRoutes.mysqlSync:
            return GetPageRoute(
              settings: settings,
              page: () => const MysqlSyncPage(),
            );
          case EHRoutes.tagTranslate:
            return GetPageRoute(
              settings: settings,
              page: () => const TagTranslatePage(),
            );
          case EHRoutes.blockers:
            return GetPageRoute(
              settings: settings,
              page: () => const BlockersPage(),
            );
          case EHRoutes.blockRules:
            return GetPageRoute(
              settings: settings,
              page: () => const BlockRulesPage(),
            );
          case EHRoutes.blockRuleEdit:
            return GetPageRoute(
              settings: settings,
              page: () => const BlockRuleEditPage(),
            );
          case EHRoutes.avatarSetting:
            return GetPageRoute(
              settings: settings,
              page: () => const AvatarSettingPage(),
            );
          case EHRoutes.logfile:
            return GetPageRoute(
              settings: settings,
              page: () => const LogPage(),
            );
          case EHRoutes.securitySetting:
            return GetPageRoute(
              settings: settings,
              page: () => const SecuritySettingPage(),
              transition: Transition.fadeIn,
              showCupertinoParallax: false,
            );
          case EHRoutes.galleryPage:
            return GetPageRoute(
              settings: settings,
              // page: () => const GallerySliverPage(),
              page: () => const GalleryPage(),
              transition: Transition.fadeIn,
              showCupertinoParallax: false,
              // fullscreenDialog: true,
            );
          case EHRoutes.galleryComment:
            return GetPageRoute(
              settings: settings,
              page: () => const CommentPage(),
            );
          case EHRoutes.galleryAllThumbnails:
            return GetPageRoute(
              settings: settings,
              page: () => const AllThumbnailsPage(),
            );
          case EHRoutes.addTag:
            return GetPageRoute(
              settings: settings,
              page: () => const AddTagPage(),
              binding: BindingsBuilder(
                () => Get.lazyPut(() => TagInfoController(), tag: pageCtrlTag),
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
              page: () => const TabbarSettingPage(),
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
              page: () => const ImageBlockPage(),
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
              transition: Transition.fadeIn,
            );
          case EHRoutes.license:
            return GetPageRoute(
              settings: settings,
              page: () => const LicensePage(),
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
      };
}
