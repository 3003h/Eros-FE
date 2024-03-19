import 'package:eros_fe/common/controller/cache_controller.dart';
import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/controller/fav_controller.dart';
import 'package:eros_fe/pages/gallery/controller/gallery_page_controller.dart';
import 'package:eros_fe/pages/item/controller/galleryitem_controller.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/utils/toast.dart';
import 'package:eros_fe/utils/vibrate.dart';
import 'package:get/get.dart';

import 'gallery_page_state.dart';

class GalleryFavController extends GetxController {
  final RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set isLoading(bool value) => _isLoading.value = value;
  String favnote = '';

  final EhSettingService _ehSettingService = Get.find();

  late GalleryPageController _pageController;
  GalleryPageState get _pageState => _pageController.gState;

  final CacheController cacheController = Get.find();

  GalleryItemController get _itemController =>
      Get.find(tag: _pageController.gState.gid);

  bool get isRegItemController =>
      Get.isRegistered<GalleryItemController>(tag: _pageController.gState.gid);

  final FavController favController = Get.find();

  @override
  void onInit() {
    super.onInit();
    _pageController = Get.find(tag: pageCtrlTag);

    _localFav.value = _pageState.localFav;

    // _favTitle 初始化
    if (_pageState.galleryProvider != null &&
        _pageState.galleryProvider?.favTitle != null &&
        _pageState.galleryProvider!.favTitle!.isNotEmpty) {
      _favTitle.value = _pageState.galleryProvider?.favTitle ?? '';
    } else {
      _favTitle.value = localFav ? L10n.of(Get.context!).local_favorite : '';
    }

    // _favcat初始化
    if (_pageState.galleryProvider != null &&
        _pageState.galleryProvider?.favcat != null &&
        _pageState.galleryProvider!.favcat!.isNotEmpty) {
      _favcat.value = _pageState.galleryProvider?.favcat ?? '';
    } else {
      _favcat.value = localFav ? 'l' : '';
    }
  }

  final RxBool _localFav = false.obs;

  bool get localFav => _pageState.localFav;

  final RxString _favTitle = L10n.of(Get.context!).notFav.obs;
  String get favTitle => _favTitle.value;

  final RxString _favcat = ''.obs;
  String get favcat => _favcat.value;

  void setFav(String favcat, String favtitle) {
    _favTitle.value = favtitle;
    _favcat.value = favcat;
    // logger.d('setFav $favcat $favtitle');
    if (favcat.isNotEmpty) {
      _ehSettingService.lastFavcat = favcat;
    }

    try {
      if (isRegItemController) {
        _itemController.setFavTitleAndFavcat(
            favTitle: favTitle, favcat: favcat);
      }
      _pageState.galleryProvider
          ?.copyWith(favcat: favcat.oN, favTitle: favtitle.oN);
    } catch (_) {}
  }

  bool get isFav => favcat.isNotEmpty || localFav;

  /// 添加到上次
  Future<bool> _addToLastFavcat(String _lastFavcat) async {
    isLoading = true;

    final String _favTitleFromProfile =
        Global.profile.user.favcat![int.parse(_lastFavcat) + 1].favTitle;

    try {
      await favController.addToLastFavcat(
        _pageState.galleryProvider?.gid ?? '0',
        _pageState.galleryProvider?.token ?? '',
        _lastFavcat,
      );
      setFav(_lastFavcat, _favTitleFromProfile);
      _removeGalleryCache();
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      _favTitle.value = _favTitleFromProfile;
      _favcat.value = _lastFavcat;
      _pageState.galleryProvider
          ?.copyWith(favcat: favcat.oN, favTitle: _favTitleFromProfile.oN);
      if (isRegItemController) {
        _itemController.setFavTitleAndFavcat(
            favTitle: favTitle, favcat: favcat);
      }
    }
    return true;
  }

  /// 点击收藏按钮处理
  Future<void> tapFav() async {
    /// 网络收藏或者本地收藏
    if (favcat.isNotEmpty || _pageState.localFav) {
      logger.d(' del fav');
      delFav();
    } else {
      logger.d(' add fav');
      final String _lastFavcat = _ehSettingService.lastFavcat;
      logger.d('上次收藏夹 $_lastFavcat');

      // 添加到上次收藏夹
      if ((_ehSettingService.isFavLongTap.value) && _lastFavcat.isNotEmpty) {
        logger.d('添加到上次收藏夹 $_lastFavcat');
        _addToLastFavcat(_lastFavcat);
      } else {
        // 手选收藏夹
        logger.d('手选收藏夹');
        await _selectToSave();
      }
    }
  }

  // 选择并收藏
  Future<void> _selectToSave() async {
    try {
      // 进行收藏
      final result = await favController.selectToSave(
        _pageState.galleryProvider?.gid ?? '0',
        _pageState.galleryProvider?.token ?? '',
        oriFavcat: favcat,
        startLoading: () => isLoading = true,
      );
      // 收藏后处理
      if (result != null) {
        final _favcatFromRult = result.favId;
        // final _favnoteFromRult = result.note ?? '';
        final _favTitleFromRult = result.favTitle;
        _favTitle.value = _favTitleFromRult;
        _favcat.value = _favcatFromRult;

        _pageState.galleryProvider = _pageState.galleryProvider?.copyWith(
            favcat: _favcatFromRult.oN, favTitle: _favTitleFromRult.oN);
        logger
            .d('after _showAddFavDialog ${_pageState.galleryProvider?.favcat}');
        setFav(favcat, favTitle);
        _removeGalleryCache();
      }
    } catch (e, stack) {
      showToast('$e\n$stack');
    } finally {
      isLoading = false;
    }
  }

  /// 删除收藏
  Future<void> delFav() async {
    isLoading = true;
    try {
      await favController.delFav(
        favcat,
        _pageState.galleryProvider?.gid ?? '0',
        _pageState.galleryProvider?.token ?? '',
      );
      _removeGalleryCache();
      _favTitle.value = '';
      _favcat.value = '';
      _pageState.galleryProvider =
          _pageState.galleryProvider?.copyWith(favcat: ''.oN, favTitle: ''.oN);
      setFav(favcat, favTitle);
    } catch (e, stack) {
      showToast('$e\n$stack');
    } finally {
      isLoading = false;
    }
  }

  // 长按事件
  Future<void> longTapFav() async {
    vibrateUtil.heavy();
    // 手选收藏夹
    await _selectToSave();
  }

  void _removeGalleryCache() {
    if (!isRegItemController) {
      return;
    }
    final url = _itemController.galleryProvider.url;
    logger.d('delete cache $url');
    cacheController.clearDioCache(path: '${Api.getBaseUrl()}$url');
  }
}
