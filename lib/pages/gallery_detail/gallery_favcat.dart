import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/common/parser/gallery_fav_parser.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 收藏操作处理类
class GalleryFavButton extends StatefulWidget {
  final String favTitle;
  final String favcat;
  final String gid;
  final String token;

  const GalleryFavButton({
    Key key,
    this.favTitle,
    @required this.gid,
    @required this.token,
    @required this.favcat,
  }) : super(key: key);

  @override
  _GalleryFavButtonState createState() => _GalleryFavButtonState();
}

class _GalleryFavButtonState extends State<GalleryFavButton> {
  String _favTitle;
  bool _isLoading = false;
  String _favcat;
  String _favnote;

  // 收藏输入框控制器
  TextEditingController _favnoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _favTitle = widget.favTitle;
    _favcat = widget.favcat;
    _favnote = '';
  }

  void _tapFav(context) async {
    if (_favTitle.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        Global.logger.v("取消收藏");
        await GalleryFavParser.galleryAddfavorite(
          widget.gid,
          widget.token,
        );
      } catch (e) {} finally {
        setState(() {
          _favTitle = '';
          _isLoading = false;
        });
      }
    } else {
      var _lastFavcat = Global.profile.ehConfig.lastFavcat;
      // 添加到上次收藏夹
      if ((Global.profile.ehConfig.favLongTap ?? false) &&
          _lastFavcat != null &&
          _lastFavcat.isNotEmpty) {
        setState(() {
          _isLoading = true;
          _favcat = _lastFavcat;
          _favTitle =
              Global.profile.user.favcat[int.parse(_favcat)]['favTitle'];
        });
      } else {
        // 手选收藏夹
        var favList =
            await GalleryFavParser.getFavcat(widget.gid, widget.token);
        Global.profile.ehConfig.favPicker ?? false
            ? await _showAddFavPicker(context, favList)
            : await _showAddFavList(context, favList);
      }

      if (_favcat != null && _favcat.trim().isNotEmpty) {
        Global.logger.v('_addFavcat  $_favcat');
        Global.profile.ehConfig.lastFavcat = _favcat;
        try {
          await GalleryFavParser.galleryAddfavorite(
            widget.gid,
            widget.token,
            favcat: _favcat,
            favnote: _favnote,
          );
        } catch (e) {} finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _longTapFav(context) async {
    // 手选收藏夹
    if (_favTitle.isEmpty) {
      var favList = await GalleryFavParser.getFavcat(
        widget.gid,
        widget.token,
      );
      Global.profile.ehConfig.favPicker
          ? await _showAddFavPicker(context, favList)
          : await _showAddFavList(context, favList);

      if (_favcat != null && _favcat.trim().isNotEmpty) {
        Global.logger.v('_addFavcat  $_favcat');
        Global.profile.ehConfig.lastFavcat = _favcat;
        try {
          await GalleryFavParser.galleryAddfavorite(
            widget.gid,
            widget.token,
            favcat: _favcat,
            favnote: _favnote,
          );
        } catch (e) {} finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// 添加收藏 Picker 形式
  Future<void> _showAddFavPicker(BuildContext context, List favList) async {
    var _favindex = 0;

    List<Widget> favPicker =
        List<Widget>.from(favList.map((e) => Text(e['favTitle']))).toList();
    return showCupertinoDialog<void>(
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
                    setState(() {
                      _isLoading = true;
                    });
                    _favcat = '$_favindex';
                    _favTitle = favList[_favindex]['favTitle'];
                    _favnote = _favnoteController.text;
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('取消'),
              onPressed: () {
                setState(() {
                  _favcat = '';
                  _favTitle = '';
                });
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('确定'),
              onPressed: () {
                // 添加收藏
                setState(() {
                  _isLoading = true;
                });
                _favcat = '$_favindex';
                _favTitle = favList[_favindex]['favTitle'];
                _favnote = _favnoteController.text;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 添加收藏 List形式
  Future<void> _showAddFavList(BuildContext context, List favList) async {
    List<Widget> favcatList =
        List<Widget>.from(favList.map((fav) => FavcatAddItem(
              text: fav['favTitle'],
              onTap: () {
                setState(() {
                  _isLoading = true;
                });
                _favcat = fav['favId'];
                _favTitle = fav['favTitle'];
                _favnote = _favnoteController.text;
                Navigator.of(context).pop();
              },
            ))).toList();

    return showCupertinoDialog<void>(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
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
                setState(() {
                  _favcat = '';
                  _favTitle = '';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);

    Widget favIcon = Container(
      child: _favTitle?.isEmpty ?? true
          ? Column(
              children: [
                Icon(
                  FontAwesomeIcons.heart,
                  color: CupertinoColors.systemGrey,
                ),
                Container(
                  height: 14,
                  child: Text(
                    ln.notFav,
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Icon(
                  FontAwesomeIcons.solidHeart,
                  color: ThemeColors.favColor[_favcat],
                ),
                Container(
                  height: 14,
                  child: Text(
                    _favTitle,
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
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
