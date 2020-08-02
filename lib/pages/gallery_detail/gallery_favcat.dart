import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/common/parser/gallery_fav_parser.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/galleryItem.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

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

  GalleryModel _galleryModel;

  // 收藏输入框控制器
  TextEditingController _favnoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final galleryModel = Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != this._galleryModel) {
      this._galleryModel = galleryModel;
      _favnote = '';
    }
  }

  /*@override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _longTapFav(context),
      child: Selector<GalleryModel, GalleryItem>(
          selector: (context, galleryModel) => galleryModel.galleryItem,
//          shouldRebuild: (pre, next) =>
//              pre.favTitle != next.favTitle || pre.favcat != next.favcat,
          shouldRebuild: (_, __) => true,
          builder: (context, galleryItem, child) {
            return LikeButton(
              isLiked: galleryItem.favcat.isNotEmpty,
              likeBuilder: (bool isLiked) {
                return Icon(
                  FontAwesomeIcons.solidHeart,
                  color: isLiked
                      ? ThemeColors.favColor[galleryItem.favcat]
                      : CupertinoColors.systemGrey,
                );
              },
              likeCount: 233,
              onTap: onLikeButtonTapped,
            );
          }),
    );
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    /// send your request here
    // final bool success= await sendRequest();

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;
    final bool val = await _tapFav(context);

    Global.logger.v(val);

    return val ?? isLiked;
  }*/

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);

    Widget favIcon = Container(
      child: Selector<GalleryModel, GalleryItem>(
          selector: (context, galleryModel) => galleryModel.galleryItem,
          shouldRebuild: (pre, next) =>
              pre.favTitle != next.favTitle || pre.favcat != next.favcat,
          builder: (context, galleryItem, child) {
//            Global.logger.v('${galleryItem.favcat}  ${galleryItem.favTitle}');
            bool _isFav =
                galleryItem.favcat != null && galleryItem.favcat.isNotEmpty;
            return Container(
              child: Column(
                children: [
                  _isFav
                      ? Icon(
                          FontAwesomeIcons.solidHeart,
                          color: ThemeColors.favColor[galleryItem.favcat],
                        )
                      : Icon(
                          FontAwesomeIcons.heart,
                          color: CupertinoColors.systemGrey,
                        ),
                  Container(
                    height: 14,
                    child: Text(
                      _isFav ? galleryItem.favTitle : ln.notFav,
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );

    Widget _loadIcon = Column(
      children: [
        CupertinoActivityIndicator(
          radius: 12.0,
        ),
        Container(
          height: 14,
          child: Text(
            ln.processing,
            style: TextStyle(
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

  _delFav() async {
    setState(() {
      _isLoading = true;
    });
    try {
//      Global.logger.v("取消收藏");
      await GalleryFavParser.galleryAddfavorite(
        _galleryModel.galleryItem.gid,
        _galleryModel.galleryItem.token,
      );
    } catch (e) {
      return true;
    } finally {
      setState(() {
        _isLoading = false;
      });
      _galleryModel.setFavTitle('', favcat: '');
    }
    return false;
  }

  _addToLastFavcat(_lastFavcat) async {
    setState(() {
      _isLoading = true;
    });

    var _favTitle =
        Global.profile.user.favcat[int.parse(_lastFavcat)]['favTitle'];

    try {
      await GalleryFavParser.galleryAddfavorite(
        _galleryModel.galleryItem.gid,
        _galleryModel.galleryItem.token,
        favcat: _lastFavcat,
        favnote: _favnote,
      );
    } catch (e) {
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
      _galleryModel.setFavTitle(_favTitle, favcat: _lastFavcat);
    }
    return true;
  }

  _tapFav(context) async {
    if (_galleryModel.galleryItem.favcat.isNotEmpty) {
      return _delFav();
    } else {
      var _lastFavcat = Global.profile.ehConfig.lastFavcat;

      // 添加到上次收藏夹
      if ((Global.profile.ehConfig.favLongTap ?? false) &&
          _lastFavcat != null &&
          _lastFavcat.isNotEmpty) {
        return _addToLastFavcat(_lastFavcat);
      } else {
        // 手选收藏夹
        return await _showAddFavDialog(context);
      }
    }
  }

  // 长按事件
  void _longTapFav(context) async {
    // 手选收藏夹
    await _showAddFavDialog(context);
  }

  // 选择并收藏
  _showAddFavDialog(context) async {
    var favList = await GalleryFavParser.getFavcat(
      _galleryModel.galleryItem.gid,
      _galleryModel.galleryItem.token,
    );

    // diaolog 获取选择结果
    var result = Global.profile.ehConfig.favPicker
        ? await _showAddFavPicker(context, favList)
        : await _showAddFavList(context, favList);

    Global.logger.v('$result');

    if (result != null && result is Map) {
      setState(() {
        _isLoading = true;
      });
      var _favcat = result['favcat'];
      var _favnote = result['favnode'];
      var _favTitle = result['favTitle'];
      try {
        await GalleryFavParser.galleryAddfavorite(
          _galleryModel.galleryItem.gid,
          _galleryModel.galleryItem.token,
          favcat: _favcat,
          favnote: _favnote,
        );
      } catch (e) {
        return false;
      } finally {
        setState(() {
          _isLoading = false;
        });
        _galleryModel.setFavTitle(_favTitle, favcat: _favcat);
      }
      return true;
    } else {
      return null;
    }
  }

  /// 添加收藏 Picker 形式
  Future<Map> _showAddFavPicker(BuildContext context, List favList) async {
    var _favindex = 0;

    List<Widget> favPicker =
        List<Widget>.from(favList.map((e) => Text(e['favTitle']))).toList();

    return showCupertinoDialog<Map>(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: GestureDetector(
            onLongPress: () {
              Global.profile.ehConfig.favPicker = false;
              Global.saveProfile();
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
                    onSelectedItemChanged: (index) {
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
                    var favMap = {
                      'favcat': '$_favindex',
                      'favTitle': favList[_favindex]['favTitle'],
                      'favnode': _favnoteController.text
                    };
                    // 返回数据
                    Navigator.of(context).pop(favMap);
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('确定'),
              onPressed: () {
                // 添加收藏
                var favMap = {
                  'favcat': '$_favindex',
                  'favTitle': favList[_favindex]['favTitle'],
                  'favnode': _favnoteController.text
                };
                // 返回数据
                Navigator.of(context).pop(favMap);
              },
            ),
          ],
        );
      },
    );
  }

  /// 添加收藏 List形式
  Future<Map> _showAddFavList(BuildContext context, List favList) async {
    return showCupertinoDialog<Map>(
      context: context,
      builder: (BuildContext context) {
        List<Widget> favcatList =
            List<Widget>.from(favList.map((fav) => FavcatAddItem(
                  text: fav['favTitle'],
                  onTap: () {
                    var favMap = {
                      'favcat': fav['favId'],
                      'favTitle': fav['favTitle'],
                      'favnode': _favnoteController.text
                    };
                    // 返回数据
                    Navigator.of(context).pop(favMap);
                  },
                ))).toList();

        return CupertinoAlertDialog(
          title: GestureDetector(
            onLongPress: () {
              Global.profile.ehConfig.favPicker = true;
              Global.saveProfile();
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class FavcatAddItem extends StatefulWidget {
  const FavcatAddItem({
    Key key,
    @required VoidCallback onTap,
    @required this.text,
  })  : _onTap = onTap,
        super(key: key);

  final VoidCallback _onTap;
  final String text;

  @override
  _FavcatAddItemState createState() => _FavcatAddItemState();
}

class _FavcatAddItemState extends State<FavcatAddItem> {
  var _color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            color: CupertinoColors.systemGrey3,
            height: 0.5,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: _color,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: 18,
                ),
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
