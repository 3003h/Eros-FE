import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_fav_parser.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:fehviewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 收藏操作处理类
class GalleryFavButton extends StatefulWidget {
  const GalleryFavButton({
    Key key,
  }) : super(key: key);

  @override
  _GalleryFavButtonState createState() => _GalleryFavButtonState();
}

class _GalleryFavButtonState extends State<GalleryFavButton> {
  bool _isLoading = false;
  String _favnote;

  // 收藏输入框控制器
  final TextEditingController _favnoteController = TextEditingController();
  final LocalFavController _localFavController = Get.find();
  final UserController _userController = Get.find();
  final GalleryItemController _galleryItemController = Get.find();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    /*final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;

    }*/
    _favnote = '';
  }

  @override
  Widget build(BuildContext context) {
    // 收藏按钮图标
    final Widget favIcon = Container(
      child: Builder(builder: (_) {
        final bool _localFav = _galleryItemController.localFav ?? false;
        String _favTitle() {
          if (_galleryItemController.galleryItem.favTitle != null &&
              _galleryItemController.galleryItem.favTitle.isNotEmpty) {
            return _galleryItemController.galleryItem.favTitle;
          } else {
            return _localFav ? S.of(context).local_favorite : '';
          }
        }

        String _favcat() {
          if (_galleryItemController.galleryItem.favcat != null &&
              _galleryItemController.galleryItem.favcat.isNotEmpty) {
            return _galleryItemController.galleryItem.favcat;
          } else {
            return _localFav ? 'l' : '';
          }
        }

        final bool _isFav = _favcat().isNotEmpty || _localFav;

        // logger.v('$tuple');

        return Container(
          child: Column(
            children: <Widget>[
              if (_isFav)
                Icon(
                  FontAwesomeIcons.solidHeart,
                  color: ThemeColors.favColor[_favcat()],
                )
              else
                const Icon(
                  FontAwesomeIcons.heart,
                  color: CupertinoColors.systemGrey,
                ),
              Container(
                height: 14,
                child: Text(
                  _isFav ? _favTitle() : S.of(context).notFav,
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );

    final Widget _loadIcon = Column(
      children: <Widget>[
        const CupertinoActivityIndicator(
          radius: 12.0,
        ),
        Container(
          height: 14,
          child: Text(
            S.of(context).processing,
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(right: 10, left: 10),
        child: _isLoading ? _loadIcon : favIcon,
      ),
      onTap: () => _tapFav(context),
      onLongPress: () => _longTapFav(context),
    );
  }

  /// 删除收藏
  Future<bool> _delFav() async {
    setState(() {
      _isLoading = true;
    });
    try {
      logger.v('[${_galleryItemController.galleryItem.favcat}]');
      if (_galleryItemController.galleryItem.favcat.isNotEmpty &&
          _galleryItemController.galleryItem.favcat != 'l') {
        logger.v('取消网络收藏');
        await GalleryFavParser.galleryAddfavorite(
          _galleryItemController.galleryItem.gid,
          _galleryItemController.galleryItem.token,
        );
      } else {
        logger.v('取消本地收藏');
        _galleryItemController.localFav = false;
        _localFavController.removeFav(_galleryItemController.galleryItem);
      }
    } catch (e) {
      return true;
    } finally {
      setState(() {
        _isLoading = false;
      });
      _galleryItemController.setFavTitle('', favcat: '');
    }
    return false;
  }

  Future<bool> _addToLastFavcat(_lastFavcat) async {
    setState(() {
      _isLoading = true;
    });

    final _favTitle =
        Global.profile.user.favcat[int.parse(_lastFavcat)]['favTitle'];

    try {
      await GalleryFavParser.galleryAddfavorite(
        _galleryItemController.galleryItem.gid,
        _galleryItemController.galleryItem.token,
        favcat: _lastFavcat,
        favnote: _favnote,
      );
    } catch (e) {
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
      _galleryItemController.setFavTitle(_favTitle, favcat: _lastFavcat);
    }
    return true;
  }

  /// 点击收藏按钮处理
  Future<void> _tapFav(context) async {
    logger.v('_tapFav');
    final EhConfigService ehConfigController = Get.find();

    /// 网络收藏或者本地收藏
    if (_galleryItemController.galleryItem.favcat.isNotEmpty ||
        _galleryItemController.galleryItem.localFav) {
      return _delFav();
    } else {
      final String _lastFavcat = ehConfigController.lastFavcat.value;

      // 添加到上次收藏夹
      if ((ehConfigController.isFavLongTap.value ?? false) &&
          _lastFavcat != null &&
          _lastFavcat.isNotEmpty) {
        logger.v('添加到上次收藏夹');
        return _addToLastFavcat(_lastFavcat);
      } else {
        // 手选收藏夹
        logger.v('手选收藏夹');
        return await _showAddFavDialog(context);
      }
    }
  }

  // 长按事件
  Future<void> _longTapFav(context) async {
    VibrateUtil.heavy();
    // 手选收藏夹
    await _showAddFavDialog(context);
  }

  // 选择并收藏
  Future<bool> _showAddFavDialog(context) async {
    final EhConfigService ehConfigController = Get.find();

    final bool _isLogin = _userController.isLogin;

    ///
    /// [{'favId': favId, 'favTitle': favTitle}]
    final List<Map<String, String>> favList = _isLogin
        ? await GalleryFavParser.getFavcat(
            gid: _galleryItemController.galleryItem.gid,
            token: _galleryItemController.galleryItem.token,
          )
        : <Map<String, String>>[];

    favList.add({'favId': 'l', 'favTitle': S.of(context).local_favorite});

    // diaolog 获取选择结果
    final Map<String, String> result = ehConfigController.isFavPicker.value
        ? await _showAddFavPicker(context, favList)
        : await _showAddFavList(context, favList);

    // logger.v('$result  ${result.runtimeType}');

    if (result != null && result is Map) {
      logger.v('result ${result}');
      setState(() {
        _isLoading = true;
      });
      final String _favcat = result['favcat'];
      final String _favnote = result['favnode'];
      final String _favTitle = result['favTitle'];
      try {
        if (_favcat != 'l') {
          await GalleryFavParser.galleryAddfavorite(
            _galleryItemController.galleryItem.gid,
            _galleryItemController.galleryItem.token,
            favcat: _favcat,
            favnote: _favnote,
          );
        } else {
          _galleryItemController.localFav = true;
          _localFavController.addLocalFav(_galleryItemController.galleryItem);
        }
      } catch (e) {
        return false;
      } finally {
        setState(() {
          _isLoading = false;
        });
        _galleryItemController.setFavTitle(_favTitle, favcat: _favcat);
      }
      return true;
    } else {
      return null;
    }
  }

  /// 添加收藏 Picker 形式
  Future<Map<String, String>> _showAddFavPicker(
      BuildContext context, List favList) async {
    int _favindex = 0;
    final EhConfigService _ehConfigController = Get.find();

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
              _ehConfigController.isFavPicker.value = false;
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
              child: const Text('取消'),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
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
        final EhConfigService ehConfigController = Get.find();

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
                    logger.v('${favMap}');
                    // 返回数据
                    Get.back(result: favMap);
                  },
                ))).toList();

        return CupertinoAlertDialog(
          title: GestureDetector(
            onLongPress: () {
              ehConfigController.isFavPicker.value = true;
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
              child: Text('取消'),
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

class FavcatAddListItem extends StatefulWidget {
  const FavcatAddListItem({
    Key key,
    @required VoidCallback onTap,
    @required this.text,
    this.favcat,
  })  : _onTap = onTap,
        super(key: key);

  final VoidCallback _onTap;
  final String text;
  final String favcat;

  @override
  _FavcatAddListItemState createState() => _FavcatAddListItemState();
}

class _FavcatAddListItemState extends State<FavcatAddListItem> {
  Color _color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4, context),
            height: 0.5,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: _color,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4, bottom: 3),
                    child: Icon(
                      FontAwesomeIcons.solidHeart,
                      color: CupertinoDynamicColor.resolve(
                          ThemeColors.favColor[widget.favcat], context),
                      size: 18,
                    ),
                  ),
                  Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            onTap: widget._onTap,
            onTapDown: (_) {
              setState(() {
                _color = CupertinoColors.systemGrey3;
              });
            },
            onTapCancel: () {
              setState(() {
                _color = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
