import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_fav_parser.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/favcat.dart';
import 'package:fehviewer/pages/controller/fav_dialog_controller.dart';
import 'package:fehviewer/pages/controller/favorite_sel_controller.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class GalleryFavController extends GetxController {
  final RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set isLoading(bool value) => _isLoading.value = value;
  String favnote = '';

  final LocalFavController _localFavController = Get.find();
  final UserController _userController = Get.find();
  final EhConfigService _ehConfigService = Get.find();
  final FavDialogController _favDialogController = Get.find();
  final FavoriteSelectorController _favoriteSelectorController = Get.find();

  GalleryPageController get _pageController => Get.find(tag: pageCtrlDepth);

  GalleryItemController get _itemController =>
      Get.find(tag: _pageController.gid);

  @override
  void onInit() {
    super.onInit();

    _localFav.value = _pageController.localFav;

    // _favTitle 初始化
    if (_pageController.galleryItem.favTitle != null &&
        _pageController.galleryItem.favTitle!.isNotEmpty) {
      _favTitle.value = _pageController.galleryItem.favTitle ?? '';
    } else {
      _favTitle.value = localFav ? L10n.of(Get.context!).local_favorite : '';
    }

    // _favcat初始化
    if (_pageController.galleryItem.favcat != null &&
        _pageController.galleryItem.favcat!.isNotEmpty) {
      _favcat.value = _pageController.galleryItem.favcat ?? '';
    } else {
      _favcat.value = localFav ? 'l' : '';
    }
  }

  final RxBool _localFav = false.obs;

  bool get localFav => _pageController.localFav;

  final RxString _favTitle = L10n.of(Get.context!).notFav.obs;

  String get favTitle => _favTitle.value;

  final RxString _favcat = ''.obs;

  String get favcat => _favcat.value;

  void setFav(String favcat, String favtitle) {
    _favTitle.value = favtitle;
    _favcat.value = favcat;
    try {
      _itemController.setFavTitle(favTitle: favTitle, favcat: favcat);
    } catch (_) {}
  }

  bool get isFav => favcat.isNotEmpty || localFav;

  /// 添加到上次
  Future<bool> _addToLastFavcat(String _lastFavcat) async {
    isLoading = true;

    final String _favTitle =
        Global.profile.user.favcat![int.parse(_lastFavcat)].favTitle;

    try {
      await GalleryFavParser.galleryAddfavorite(
        _pageController.galleryItem.gid!,
        _pageController.galleryItem.token!,
        favcat: _lastFavcat,
        favnote: favnote,
      );
    } catch (e) {
      return false;
    } finally {
      isLoading = false;

      this._favTitle.value = _favTitle;
      _favcat.value = _lastFavcat;
      if (!_pageController.fromUrl) {
        _itemController.setFavTitle(favTitle: favTitle, favcat: favcat);
      }
    }
    return true;
  }

  /// 点击收藏按钮处理
  Future<bool?> tapFav() async {
    // logger.v('tapFav');

    /// 网络收藏或者本地收藏
    if (favcat.isNotEmpty || _pageController.localFav) {
      logger.d(' del fav');
      return delFav();
    } else {
      logger.d(' add fav');
      final String _lastFavcat = _ehConfigService.lastFavcat.value;

      // 添加到上次收藏夹
      if ((_ehConfigService.isFavLongTap.value) &&
          _lastFavcat != null &&
          _lastFavcat.isNotEmpty) {
        logger.v('添加到上次收藏夹 $_lastFavcat');
        return _addToLastFavcat(_lastFavcat);
      } else {
        // 手选收藏夹
        logger.v('手选收藏夹');
        return await _showAddFavDialog();
      }
    }
  }

  // 选择并收藏
  Future<bool?> _showAddFavDialog() async {
    final BuildContext context = Get.context!;
    final bool _isLogin = _userController.isLogin;

    /// [{'favId': favId, 'favTitle': favTitle}]
    // final List<Favcat> favList = _isLogin
    //     ? await GalleryFavParser.getFavcat(
    //         gid: _pageController.galleryItem.gid,
    //         token: _pageController.galleryItem.token,
    //       )
    //     : <Favcat>[];
    //
    // favList.add(Favcat(favId: 'l', favTitle: L10n.of(context).local_favorite));

    final List<Favcat> favList = _favoriteSelectorController.favcatList;

    // diaolog 获取选择结果
    final Favcat? result =
        await _favDialogController.showFavListDialog(context, favList);

    logger.v('$result  ${result.runtimeType}');

    if (result != null && result is Favcat) {
      logger.v('add fav ${result.favId}');

      isLoading = true;
      final String _favcat = result.favId;
      final String _favnote = result.note ?? '';
      final String _favTitle = result.favTitle;

      _ehConfigService.lastFavcat.value = _favcat;

      try {
        if (_favcat != 'l') {
          await GalleryFavParser.galleryAddfavorite(
            _pageController.galleryItem.gid!,
            _pageController.galleryItem.token!,
            favcat: _favcat,
            favnote: _favnote,
          );
        } else {
          _pageController.localFav = true;
          _localFavController.addLocalFav(_pageController.galleryItem);
        }
        final _oriFavcat = this._favcat.value;
        logger.v(' ${_pageController.galleryItem.toJson()}');
        if (_oriFavcat.isNotEmpty) {
          _favoriteSelectorController.decrease(_oriFavcat);
        }

        _favoriteSelectorController.increase(_favcat);
      } catch (e) {
        return false;
      } finally {
        isLoading = false;
        this._favTitle.value = _favTitle;
        this._favcat.value = _favcat;
        if (!_pageController.fromUrl) {
          _itemController.setFavTitle(favTitle: favTitle, favcat: favcat);
        }
      }
      return true;
    } else {
      return null;
    }
  }

  /// 删除收藏
  Future<bool> delFav() async {
    isLoading = true;

    try {
      if (favcat.isNotEmpty && favcat != 'l') {
        logger.v('删除网络收藏');
        await GalleryFavParser.galleryAddfavorite(
          _pageController.galleryItem.gid!,
          _pageController.galleryItem.token!,
        );
      } else {
        logger.v('取消本地收藏');
        _pageController.localFav = false;
        _localFavController.removeFav(_pageController.galleryItem);
      }
      _favoriteSelectorController.decrease(favcat);
    } catch (e) {
      return true;
    } finally {
      isLoading = false;
      _favTitle.value = '';
      _favcat.value = '';
      if (!_pageController.fromUrl) {
        logger.d('del fav ${_itemController.galleryItem.gid}');
        _itemController.setFavTitle(favTitle: '', favcat: '');
      }
    }
    return false;
  }

  // 长按事件
  Future<void> longTapFav() async {
    vibrateUtil.heavy();
    // 手选收藏夹
    await _showAddFavDialog();
  }
}
