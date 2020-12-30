import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_fav_parser.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/gallery_main/view/gallery_favcat.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class GalleryFavController extends GetxController {
  final RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set isLoading(bool value) => _isLoading.value = value;
  String favnote = '';

  // 收藏输入框控制器
  final TextEditingController _favnoteController = TextEditingController();
  final LocalFavController _localFavController = Get.find();
  final UserController _userController = Get.find();
  final EhConfigService _ehConfigService = Get.find();
  GalleryPageController _pageController;
  GalleryItemController _itemController;

  @override
  void onInit() {
    super.onInit();
    _pageController = Get.find(tag: pageCtrlDepth);
    if (!_pageController.fromUrl) {
      _itemController = Get.find(tag: _pageController.gid);
    }

    _localFav.value = _pageController.localFav ?? false;

    // _favTitle 初始化
    if (_pageController.galleryItem.favTitle != null &&
        _pageController.galleryItem.favTitle.isNotEmpty) {
      _favTitle.value = _pageController.galleryItem.favTitle;
    } else {
      _favTitle.value = localFav ? S.of(Get.context).local_favorite : '';
    }

    // _favcat初始化
    if (_pageController.galleryItem.favcat != null &&
        _pageController.galleryItem.favcat.isNotEmpty) {
      _favcat.value = _pageController.galleryItem.favcat;
    } else {
      _favcat.value = localFav ? 'l' : '';
    }
  }

  final RxBool _localFav = false.obs;

  bool get localFav => _pageController.localFav ?? false;

  final RxString _favTitle = S.of(Get.context).notFav.obs;
  String get favTitle => _favTitle.value;
  // set favTitle(String val) => _favTitle.value = val;

  final RxString _favcat = ''.obs;
  String get favcat => _favcat.value;
  // set favcat(String val) => _favcat.value = val;

  void setFav(String favcat, String favtitle) {
    _favTitle.value = favtitle;
    _favcat.value = favcat;
    try {
      _itemController.setFavTitle(favTitle, favcat: favcat);
    } catch (e) {}
    // if (!_pageController.fromUrl) {
    //   _itemController.setFavTitle(favTitle, favcat: favcat);
    // }
  }

  bool get isFav => favcat.isNotEmpty || localFav;

  Future<bool> addToLastFavcat(String _lastFavcat) async {
    isLoading = true;

    final String _favTitle = Global.profile.user.favcat[int.parse(_lastFavcat)]
        ['favTitle'] as String;

    try {
      await GalleryFavParser.galleryAddfavorite(
        _pageController.galleryItem.gid,
        _pageController.galleryItem.token,
        favcat: _lastFavcat,
        favnote: favnote,
      );
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      this._favTitle.value = _favTitle;
      _favcat.value = _lastFavcat;
    }
    return true;
  }

  /// 点击收藏按钮处理
  Future<void> tapFav() async {
    logger.v('tapFav');

    /// 网络收藏或者本地收藏
    if (favcat.isNotEmpty || _pageController.localFav) {
      logger.d(' del fav');
      return delFav();
    } else {
      logger.d(' add fav');
      final String _lastFavcat = _ehConfigService.lastFavcat.value;

      // 添加到上次收藏夹
      if ((_ehConfigService.isFavLongTap.value ?? false) &&
          _lastFavcat != null &&
          _lastFavcat.isNotEmpty) {
        logger.v('添加到上次收藏夹');
        return addToLastFavcat(_lastFavcat);
      } else {
        // 手选收藏夹
        logger.v('手选收藏夹');
        return await _showAddFavDialog();
      }
    }
  }

  // 选择并收藏
  Future<bool> _showAddFavDialog() async {
    final BuildContext context = Get.context;
    final bool _isLogin = _userController.isLogin;

    ///
    /// [{'favId': favId, 'favTitle': favTitle}]
    final List<Map<String, String>> favList = _isLogin
        ? await GalleryFavParser.getFavcat(
            gid: _pageController.galleryItem.gid,
            token: _pageController.galleryItem.token,
          )
        : <Map<String, String>>[];

    favList.add({'favId': 'l', 'favTitle': S.of(context).local_favorite});

    // diaolog 获取选择结果
    final Map<String, String> result = _ehConfigService.isFavPicker.value
        ? await _showAddFavPicker(context, favList)
        : await _showAddFavList(context, favList);

    // logger.v('$result  ${result.runtimeType}');

    if (result != null && result is Map) {
      logger.v('add fav $result');

      isLoading = true;
      final String _favcat = result['favcat'];
      final String _favnote = result['favnode'];
      final String _favTitle = result['favTitle'];
      try {
        if (_favcat != 'l') {
          await GalleryFavParser.galleryAddfavorite(
            _pageController.galleryItem.gid,
            _pageController.galleryItem.token,
            favcat: _favcat,
            favnote: _favnote,
          );
        } else {
          _pageController.localFav = true;
          _localFavController.addLocalFav(_pageController.galleryItem);
        }
      } catch (e) {
        return false;
      } finally {
        isLoading = false;
        this._favTitle.value = _favTitle;
        this._favcat.value = _favcat;
        if (!_pageController.fromUrl) {
          _itemController.setFavTitle(favTitle, favcat: favcat);
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
      logger.v('[${_pageController.galleryItem.favcat}]');
      if (favcat.isNotEmpty && favcat != 'l') {
        logger.v('取消网络收藏');
        await GalleryFavParser.galleryAddfavorite(
          _pageController.galleryItem.gid,
          _pageController.galleryItem.token,
        );
      } else {
        logger.v('取消本地收藏');
        _pageController.localFav = false;
        _localFavController.removeFav(_pageController.galleryItem);
      }
    } catch (e) {
      return true;
    } finally {
      isLoading = false;
      _favTitle.value = '';
      _favcat.value = '';
      if (!_pageController.fromUrl) {
        logger.d('del fav ${_itemController.galleryItem.gid}');
        _itemController.setFavTitle('', favcat: '');
      }
    }
    return false;
  }

  // 长按事件
  Future<void> longTapFav() async {
    VibrateUtil.heavy();
    // 手选收藏夹
    await _showAddFavDialog();
  }

  /// 添加收藏 Picker 形式
  Future<Map<String, String>> _showAddFavPicker(
      BuildContext context, List favList) async {
    int _favindex = 0;
    final EhConfigService _ehConfigService = Get.find();

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
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: GestureDetector(
            onLongPress: () {
              _ehConfigService.isFavPicker.value = false;
              showToast('切换样式');
            },
            child: Text('添加收藏'),
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
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(S.of(context).ok),
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
  Future<Map<String, String>> _showAddFavList(
      BuildContext context, List favList) async {
    return showCupertinoDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        final EhConfigService ehConfigService = Get.find();

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
              ehConfigService.isFavPicker.value = true;
              showToast('切换样式');
            },
            child: Text('添加收藏'),
          ),
          content: Container(
            child: Column(
              children: <Widget>[
                ...favcatList,
                CupertinoTextField(
                  controller: _favnoteController,
//                  autofocus: true,
                  onEditingComplete: () {
                    // 点击键盘完成
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
