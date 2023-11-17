import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/favcat.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/gallery/view/gallery_favcat.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'favorite_sel_controller.dart';

class FavController extends GetxController {
  final EhSettingService _ehSettingService = Get.find();
  final LocalFavController _localFavController = Get.find();

  // 收藏输入框控制器
  final TextEditingController _favnoteController = TextEditingController();
  FixedExtentScrollController _fixedExtentScrollController =
      FixedExtentScrollController();

  final FavoriteSelectorController _favoriteSelectorController = Get.find();

  Future<Favcat?> showFavListDialog(
    BuildContext context,
    List<Favcat> favList,
  ) async {
    return _ehSettingService.isFavPicker.value
        ? await _showAddFavPicker(context, favList)
        : await _showAddFavList(context, favList);
  }

  Future<void> _getFavaddInfo(String gid, String token) async {
    final favAdd = await galleryGetFavorite(gid, token);
    final favNote = favAdd.favNote ?? '';
    _favnoteController.text = favNote;
    final favcats = favAdd.favcats;
    final selectFav = favAdd.selectFavcat;
    final fav = int.tryParse(selectFav ?? '0') ?? 0;
    _fixedExtentScrollController.animateToItem(
      fav,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  /// 添加收藏 Picker 形式
  Future<Favcat?> _showAddFavPicker(
      BuildContext context, List<Favcat> favList) async {
    int _favIndex = 2;

    final List<Widget> _favPickerList = List<Widget>.from(
        favList.where((value) => value.favId != 'a').map((Favcat e) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 4),
                  child: Icon(
                    FontAwesomeIcons.solidHeart,
                    color: ThemeColors.favColor[e.favId],
                    size: 18,
                  ),
                ),
                Text(e.favTitle),
              ],
            ))).toList();

    return showCupertinoDialog<Favcat>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: GestureDetector(
            onLongPress: () {
              _ehSettingService.isFavPicker.value = false;
              showToast('切换样式');
            },
            child: Text(L10n.of(context).add_to_favorites),
          ),
          content: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 250,
                  child: CupertinoPicker(
                    scrollController: _fixedExtentScrollController,
                    itemExtent: 30,
                    onSelectedItemChanged: (int index) {
                      _favIndex = index;
                    },
                    children: _favPickerList,
                  ),
                ),
                CupertinoTextField(
                  controller: _favnoteController,
                  maxLines: null,
                  decoration: BoxDecoration(
                    color: ehTheme.favnoteTextFieldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(L10n.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(L10n.of(context).ok),
              onPressed: () {
                // 返回数据
                Get.back(
                    result: favList[_favIndex]
                        .copyWith(note: _favnoteController.text));
              },
            ),
          ],
        );
      },
    );
  }

  /// 添加收藏 List形式
  Future<Favcat?> _showAddFavList(
    BuildContext context,
    List<Favcat> favList,
  ) async {
    final List<Widget> _favcatList = List<Widget>.from(favList
        .where((value) => value.favId != 'a')
        .map((Favcat fav) => FavCatAddListItem(
              text: fav.favTitle,
              favcat: fav.favId,
              totNum: fav.totNum,
              onTap: () {
                // 返回数据
                Get.back(result: fav.copyWith(note: _favnoteController.text));
              },
            ))).toList();

    logger.t(_favcatList.length);

    return showCupertinoDialog<Favcat?>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: GestureDetector(
            onLongPress: () {
              _ehSettingService.isFavPicker.value = true;
              showToast('切换样式');
            },
            child: Text(L10n.of(context).add_to_favorites),
          ),
          content: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ..._favcatList,
                CupertinoTextField(
                  controller: _favnoteController,
                  maxLines: null,
                  decoration: BoxDecoration(
                    color: ehTheme.favnoteTextFieldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  placeholder: 'Favorites note',
                ).paddingOnly(top: 8.0),
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(L10n.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  /// 点击收藏按钮处理
  Future<Favcat?> addFav(
    String gid,
    String token, {
    String oriFavcat = '',
    String oriFavnote = '',
  }) async {
    logger.d('bbb add fav $gid $token');
    final String? _lastFavcat = _ehSettingService.lastFavcat;

    _favnoteController.text = oriFavnote;

    // 添加到上次收藏夹
    if ((_ehSettingService.isFavLongTap.value) &&
        _lastFavcat != null &&
        _lastFavcat.isNotEmpty) {
      logger.t('添加到上次收藏夹');
      return addToLastFavcat(gid, token, _lastFavcat, oriFavcat: oriFavcat);
    } else {
      // 手选收藏夹
      logger.t('手选收藏夹');
      return await selectToSave(gid, token, oriFavcat: oriFavcat);
    }
  }

  // 选择并收藏
  Future<Favcat?> selectToSave(
    String gid,
    String token, {
    String oriFavcat = '',
    VoidCallback? startLoading,
  }) async {
    _favnoteController.clear();
    final BuildContext context = Get.context!;

    final List<Favcat> favList = _favoriteSelectorController.favcatList;

    if (oriFavcat.isNotEmpty) {
      final _oriFav = int.tryParse(oriFavcat) ?? 0;
      logger.d('_oriFav $_oriFav');
      _fixedExtentScrollController =
          FixedExtentScrollController(initialItem: _oriFav);
    } else {
      _fixedExtentScrollController = FixedExtentScrollController();
    }

    // 异步获取原note信息等
    _getFavaddInfo(gid, token);

    // diaolog 获取选择结果
    Favcat? result;
    try {
      result = await showFavListDialog(context, favList);
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }

    logger.t('$result  ${result.runtimeType}');

    if (result != null) {
      startLoading?.call();
      logger.t('add fav $result');

      final String _favcat = result.favId;
      final String _favnote = result.note ?? '';
      final String _favTitle = result.favTitle;
      try {
        if (_favcat != 'l') {
          await galleryAddFavorite(
            gid,
            token,
            favcat: _favcat,
            favnote: _favnote,
          );
        } else {
          // _localFavController.addLocalFav(_pageController.galleryProvider);
          // todo
          _localFavController.addLocalFav(
              Get.find<GalleryItemController>(tag: gid).galleryProvider);
          logger.d('addLocalFav');
        }
      } catch (e) {
        rethrow;
      }
      if (oriFavcat.isNotEmpty) {
        _favoriteSelectorController.decrease(oriFavcat);
      }
      _favoriteSelectorController.increase(_favcat);

      return result;
    } else {
      return null;
    }
  }

  Future<Favcat> addToLastFavcat(
    String gid,
    String token,
    String _lastFavcat, {
    String oriFavcat = '',
    String oriFavnote = '',
  }) async {
    final String _favTitle =
        Global.profile.user.favcat?[int.parse(_lastFavcat)].favTitle ?? '...';

    try {
      await galleryAddFavorite(gid, token, favcat: _lastFavcat, favnote: '');
    } catch (e) {
      rethrow;
    }
    if (oriFavcat.isNotEmpty) {
      _favoriteSelectorController.decrease(oriFavcat);
    }
    _favoriteSelectorController.increase(_lastFavcat);
    return Favcat(favTitle: _favTitle, favId: _lastFavcat);
  }

  /// 删除收藏
  Future<void> delFav(String favcat, String gid, String token) async {
    if (favcat.isNotEmpty && favcat != 'l') {
      logger.t('取消网络收藏');
      await galleryAddFavorite(gid, token);
    } else {
      logger.t('取消本地收藏');
      _localFavController.removeFavByGid(gid);
    }
    _favoriteSelectorController.decrease(favcat);
  }
}
