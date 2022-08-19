import 'dart:io';

import 'package:fehviewer/common/controller/cache_controller.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:fehviewer/pages/gallery/view/add_tags_page.dart';
import 'package:fehviewer/pages/gallery/view/all_preview_page.dart';
import 'package:fehviewer/pages/gallery/view/comment_page.dart';
import 'package:fehviewer/pages/gallery/view/gallery_info_page.dart';
import 'package:fehviewer/pages/gallery/view/sliver/gallery_page_sliver.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/pages/image_view/view/view_page.dart';
import 'package:fehviewer/pages/login/controller/login_controller.dart';
import 'package:fehviewer/pages/login/view/login_page.dart';
import 'package:fehviewer/pages/login/view/web_login_in.dart';
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
import 'package:fehviewer/pages/tab/bindings/splash_binding.dart';
import 'package:fehviewer/pages/tab/view/download_page.dart';
import 'package:fehviewer/pages/tab/view/empty.dart';
import 'package:fehviewer/pages/tab/view/favorite_sel_page.dart';
import 'package:fehviewer/pages/tab/view/history_page.dart';
import 'package:fehviewer/pages/tab/view/home_page.dart';
import 'package:fehviewer/pages/tab/view/quick_search_page.dart';
import 'package:fehviewer/pages/tab/view/search_page.dart';
import 'package:fehviewer/pages/tab/view/splash_page.dart';
import 'package:fehviewer/pages/tab/view/tabbar/custom_profile_setting_page.dart';
import 'package:fehviewer/pages/tab/view/tabbar/custom_profiles_page.dart';
import 'package:fehviewer/pages/tab/view/tabbar/custom_tabbar_page.dart';
import 'package:fehviewer/pages/tab/view/tabbar/favorite_tabbar_page.dart';
import 'package:fehviewer/pages/tab/view/toplist_page.dart';
import 'package:fehviewer/pages/tab/view/unlock_page.dart';
import 'package:get/get.dart';

import '../pages/tab/view/home_page_small.dart';
import '../pages/tab/view/search_image_page.dart';
import 'routes.dart';

const Duration kUnLockPageTransitionDuration = Duration(milliseconds: 200);

class AppPages {
  static final List<GetPage> routes = <GetPage>[
    GetPage(
      name: EHRoutes.root,
      page: () => SplashPage(),
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
      transitionDuration: kUnLockPageTransitionDuration,
    ),
    GetPage(
      name: EHRoutes.home,
      page: () => HomePage(),
      // page: () => TabHomeSmall(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: EHRoutes.selFavorie,
      page: () => FavoriteSelectorPage(),
    ),
    GetPage(
      name: EHRoutes.ehSetting,
      page: () => const EhSettingPage(),
    ),
    GetPage(
      name: EHRoutes.advancedSetting,
      page: () => const AdvancedSettingPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => CacheController())),
    ),
    GetPage(
      name: EHRoutes.about,
      page: () => AboutPage(),
    ),
    GetPage(
      name: EHRoutes.license,
      page: () => customLicensePage,
    ),
    GetPage(
      name: EHRoutes.downloadSetting,
      page: () => DownloadSettingPage(),
    ),
    GetPage(
      name: EHRoutes.searchSetting,
      page: () => SearchSettingPage(),
    ),
    GetPage(
      name: EHRoutes.securitySetting,
      page: () => SecuritySettingPage(),
    ),
    GetPage(
      name: EHRoutes.readSeting,
      page: () => const ReadSettingPage(),
    ),
    GetPage(
      name: EHRoutes.login,
      page: () => const LoginPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => LoginController()),
      ),
    ),
    GetPage<List<Cookie>>(
      name: EHRoutes.webLogin,
      page: () => WebLoginViewIn(),
    ),
    GetPage(
      name: EHRoutes.galleryComment,
      page: () => CommentPage(),
    ),
    GetPage(
      name: EHRoutes.galleryAllPreviews,
      page: () => const AllPreviewPage(),
    ),
    GetPage(
      name: EHRoutes.addTag,
      page: () => AddTagPage(),
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
      page: () => TabSettingPage(),
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
      opaque: false,
      // showCupertinoParallax: false,
    ),
    GetPage(
      name: EHRoutes.galleryPage,
      // page: () => GalleryMainPage(),
      page: () => GallerySliverPage(),
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
      page: () => QuickSearchListPage(),
    ),
    GetPage(
      name: EHRoutes.customHosts,
      page: () => const CustomHostsPage(),
    ),
    GetPage(
      name: EHRoutes.webDavSetting,
      page: () => const WebDavSetting(),
    ),
    GetPage(
      name: EHRoutes.avatarSetting,
      page: () => const AvatarSettingPage(),
    ),
    GetPage(
      name: EHRoutes.tagTranslat,
      page: () => const TagTranslatePage(),
    ),
    GetPage(
      name: EHRoutes.logfile,
      page: () => LogPage(),
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
      page: () => const ImageHidePage(),
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
      name: EHRoutes.customlist,
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
}
