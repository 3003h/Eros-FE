import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_fav_parser.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/favcat.dart';
import 'package:fehviewer/pages/gallery/view/gallery_favcat.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'favorite_sel_controller.dart';

class FavDialogController extends GetxController {
  final EhConfigService _ehConfigService = Get.find();
  final UserController _userController = Get.find();
  final LocalFavController _localFavController = Get.find();

  // 收藏输入框控制器
  final TextEditingController _favnoteController = TextEditingController();

  final FavoriteSelectorController _favoriteSelectorController = Get.find();

  Future<Favcat?> showFavListDialog(
      BuildContext context, List<Favcat> favList) async {
    return _ehConfigService.isFavPicker.value
        ? await _showAddFavPicker(context, favList)
        : await _showAddFavList(context, favList);
  }

  /// 添加收藏 Picker 形式
  Future<Favcat?> _showAddFavPicker(
      BuildContext context, List<Favcat> favList) async {
    int _favindex = 0;

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
              _ehConfigService.isFavPicker.value = false;
              showToast('切换样式');
            },
            child: Text(L10n.of(context).add_to_favorites),
          ),
          content: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 150,
                  child: CupertinoPicker(
                    itemExtent: 30,
                    onSelectedItemChanged: (int index) {
                      _favindex = index;
                    },
                    children: _favPickerList,
                  ),
                ),
                CupertinoTextField(
                  controller: _favnoteController,
//                  autofocus: true,
                  decoration: BoxDecoration(
                    color: ehTheme.favnoteTextFieldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  onEditingComplete: () {
                    // 返回数据
                    Get.back(
                        result: favList[_favindex]
                            .copyWith(note: _favnoteController.text));
                  },
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
                // 添加收藏
                final Map<String, String> favMap = <String, String>{
                  'favcat': '$_favindex',
                  'favTitle': favList[_favindex].favTitle,
                  'favnode': _favnoteController.text
                };
                // 返回数据
                Get.back(
                    result: favList[_favindex]
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
      BuildContext context, List<Favcat> favList) async {
    final List<Widget> _favcatList = List<Widget>.from(favList
        .where((value) => value.favId != 'a')
        .map((Favcat fav) => FavcatAddListItem(
              text: fav.favTitle,
              favcat: fav.favId,
              totNum: fav.totNum,
              onTap: () {
                // 返回数据
                Get.back(result: fav.copyWith(note: _favnoteController.text));
              },
            ))).toList();

    logger.v(_favcatList.length);

    return showCupertinoDialog<Favcat?>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: GestureDetector(
            onLongPress: () {
              _ehConfigService.isFavPicker.value = true;
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
                  decoration: BoxDecoration(
                    color: ehTheme.favnoteTextFieldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  placeholder: 'Favorites note',
                  onEditingComplete: () {
                    // 点击键盘完成
                  },
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
  Future<Favcat?> tapAddFav(String gid, String token,
      {String oriFavcat = ''}) async {
    logger.d(' add fav $gid $token');
    final String? _lastFavcat = _ehConfigService.lastFavcat.value;

    // 添加到上次收藏夹
    if ((_ehConfigService.isFavLongTap.value) &&
        _lastFavcat != null &&
        _lastFavcat.isNotEmpty) {
      logger.v('添加到上次收藏夹');
      return _addToLastFavcat(gid, token, _lastFavcat, oriFavcat: oriFavcat);
    } else {
      // 手选收藏夹
      logger.v('手选收藏夹');
      return await _showAddFavDialog(gid, token, oriFavcat: oriFavcat);
    }
  }

  // 选择并收藏
  Future<Favcat?> _showAddFavDialog(String gid, String token,
      {String oriFavcat = ''}) async {
    final BuildContext context = Get.context!;
    final bool _isLogin = _userController.isLogin;

    /// [{'favId': favId, 'favTitle': favTitle}]
    // final List<Favcat> favList = _isLogin
    //     ? await GalleryFavParser.getFavcat(
    //         gid: gid,
    //         token: token,
    //       )
    //     : <Favcat>[];
    //
    // // favList.add({'favId': 'l', 'favTitle': L10n.of(context).local_favorite});
    // favList.add(Favcat(favId: 'l', favTitle: L10n.of(context).local_favorite));

    final List<Favcat> favList = _favoriteSelectorController.favcatList;
    logger.d(' ${favList.length}');

    // diaolog 获取选择结果
    Favcat? result;
    try {
      result = await showFavListDialog(context, favList);
    } catch (e, stack) {
      logger.e('$e\n$stack');
    }

    logger.v('$result  ${result.runtimeType}');

    if (result != null && result is Favcat) {
      logger.v('add fav $result');

      final String _favcat = result.favId;
      final String _favnote = result.note ?? '';
      final String _favTitle = result.favTitle;
      try {
        if (_favcat != 'l') {
          await GalleryFavParser.galleryAddfavorite(
            gid,
            token,
            favcat: _favcat,
            favnote: _favnote,
          );
        } else {
          // _localFavController.addLocalFav(_pageController.galleryItem);
          // todo
          _localFavController.addLocalFav(
              Get.find<GalleryItemController>(tag: gid).galleryItem);
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

  Future<Favcat> _addToLastFavcat(String gid, String token, String _lastFavcat,
      {String oriFavcat = ''}) async {
    final String _favTitle =
        Global.profile.user.favcat?[int.parse(_lastFavcat)].favTitle ?? '...';

    try {
      await GalleryFavParser.galleryAddfavorite(gid, token,
          favcat: _lastFavcat, favnote: '');
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
      logger.v('取消网络收藏');
      await GalleryFavParser.galleryAddfavorite(gid, token);
    } else {
      logger.v('取消本地收藏');
      _localFavController.removeFavByGid(gid);
    }
    _favoriteSelectorController.decrease(favcat);
  }
}
