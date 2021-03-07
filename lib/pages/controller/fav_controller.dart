import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_fav_parser.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery/view/gallery_favcat.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

class FavController extends GetxController {
  final EhConfigService _ehConfigService = Get.find();
  final UserController _userController = Get.find();
  final LocalFavController _localFavController = Get.find();
  // 收藏输入框控制器
  final TextEditingController _favnoteController = TextEditingController();

  Future<Map<String, String>?> showFav(
      BuildContext context, List favList) async {
    return _ehConfigService.isFavPicker.value ?? false
        ? await _showAddFavPicker(context, favList)
        : await _showAddFavList(context, favList);
  }

  /// 添加收藏 Picker 形式
  Future<Map<String, String>?> _showAddFavPicker(
      BuildContext context, List favList) async {
    int _favindex = 0;

    final List<Widget> favPicker = List<Widget>.from(favList.map((e) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 4),
              child: Icon(
                FontAwesomeIcons.solidHeart,
                color: ThemeColors.favColor[e['favId']],
                size: 18,
              ),
            ),
            Text(e['favTitle']),
          ],
        ))).toList();

    return showCupertinoDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: GestureDetector(
            onLongPress: () {
              _ehConfigService.isFavPicker.value = false;
              showToast('切换样式');
            },
            child: Text(S.of(context)!.add_to_favorites),
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
                    children: <Widget>[...favPicker],
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
                    // 点击键盘完成
                    // 添加收藏
                    final Map<String, String> favMap = <String, String>{
                      'favcat': '$_favindex',
                      'favTitle': favList[_favindex]['favTitle'],
                      'favnode': _favnoteController.text
                    };
                    // 返回数据
                    Get.back(result: favMap);
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(context)!.cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(S.of(context)!.ok),
              onPressed: () {
                // 添加收藏
                final Map<String, String> favMap = <String, String>{
                  'favcat': '$_favindex',
                  'favTitle': favList[_favindex]['favTitle'],
                  'favnode': _favnoteController.text
                };
                // 返回数据
                Get.back(result: favMap);
              },
            ),
          ],
        );
      },
    );
  }

  /// 添加收藏 List形式
  Future<Map<String, String>?> _showAddFavList(
      BuildContext context, List favList) async {
    return showCupertinoDialog<Map<String, String>>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        final List<Widget> favcatList =
            List<Widget>.from(favList.map((fav) => FavcatAddListItem(
                  text: fav['favTitle'],
                  favcat: fav['favId'],
                  onTap: () {
                    final Map<String, String> favMap = <String, String>{
                      'favcat': fav['favId'],
                      'favTitle': fav['favTitle'],
                      'favnode': _favnoteController.text
                    };
                    logger.v(' ${favMap}');
                    // 返回数据
                    Get.back(result: favMap);
                  },
                ))).toList();

        return CupertinoAlertDialog(
          title: GestureDetector(
            onLongPress: () {
              _ehConfigService.isFavPicker.value = true;
              showToast('切换样式');
            },
            child: const Text('添加收藏'),
          ),
          content: Container(
            child: Column(
              children: <Widget>[
                ...favcatList,
                CupertinoTextField(
                  controller: _favnoteController,
//                  autofocus: true,
                  decoration: BoxDecoration(
                    color: ehTheme.favnoteTextFieldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  placeholder: 'Favorites note',
                  onEditingComplete: () {
                    // 点击键盘完成
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(context)!.cancel),
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
  Future<Tuple2<String, String>?> addFav(String gid, String token) async {
    logger.d(' add fav');
    final String? _lastFavcat = _ehConfigService.lastFavcat.value;

    // 添加到上次收藏夹
    if ((_ehConfigService.isFavLongTap.value ?? false) &&
        _lastFavcat != null &&
        _lastFavcat.isNotEmpty) {
      logger.v('添加到上次收藏夹');
      return _addToLastFavcat(gid, token, _lastFavcat);
    } else {
      // 手选收藏夹
      logger.v('手选收藏夹');
      return await _showAddFavDialog(gid, token);
    }
  }

  // 选择并收藏
  Future<Tuple2<String, String>?> _showAddFavDialog(
      String gid, String token) async {
    final BuildContext context = Get.context!;
    final bool _isLogin = _userController.isLogin;

    /// [{'favId': favId, 'favTitle': favTitle}]
    final List<Map<String, String>> favList = _isLogin
        ? await GalleryFavParser.getFavcat(
            gid: gid,
            token: token,
          )
        : <Map<String, String>>[];

    favList.add({'favId': 'l', 'favTitle': S.of(context)!.local_favorite});

    // diaolog 获取选择结果
    final Map<String, String>? result = await showFav(context, favList);

    // logger.v('$result  ${result.runtimeType}');

    if (result != null && result is Map) {
      logger.v('add fav $result');

      final String _favcat = result['favcat'] ?? '';
      final String _favnote = result['favnode'] ?? '';
      final String _favTitle = result['favTitle'] ?? '';
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
          logger.d('add loc');
        }
      } catch (e) {
        rethrow;
      }
      return Tuple2(_favcat, _favTitle);
    } else {
      return null;
    }
  }

  Future<Tuple2<String, String>> _addToLastFavcat(
      String gid, String token, String _lastFavcat) async {
    final String _favTitle = Global.profile.user.favcat?[int.parse(_lastFavcat)]
        ['favTitle'] as String;

    try {
      await GalleryFavParser.galleryAddfavorite(gid, token,
          favcat: _lastFavcat, favnote: '');
    } catch (e) {
      rethrow;
    }
    return Tuple2(_lastFavcat, _favTitle);
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
  }
}
