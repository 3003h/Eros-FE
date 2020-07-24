import 'package:FEhViewer/client/parser/gallery_detail_parser.dart';
import 'package:FEhViewer/client/parser/gallery_fav_parser.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/pages/gallery_detail/gallery_detail_widget.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:FEhViewer/widget/rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GalleryDetailPage extends StatefulWidget {
  final String title;
  final GalleryItem galleryItem;
  final fromTabIndex;

  GalleryDetailPage({
    Key key,
    this.galleryItem,
    this.title,
    this.fromTabIndex,
  }) : super(key: key);

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  List<Widget> _lisTagGroupW = [];
  GalleryItem _galleryItem;

  bool _loading = false;
  bool _hideNavigationBtn = true;

  final _titleHeight = 200.0;

  ScrollController _controller = ScrollController();

  /// 初始化 请求数据
  _loadData() async {
    setState(() {
      _loading = true;
    });
    _galleryItem =
        await GalleryDetailParser.getGalleryDetail(widget.galleryItem);

    _galleryItem.tagGroup.forEach((tagGroupData) {
      _lisTagGroupW.add(TagGroupItem(tagGroupData: tagGroupData));
    });
    setState(() {
      _loading = false;
    });
  }

  // 滚动监听
  // 后续考虑用状态管理处理
  void _controllerLister() {
    if (_controller.offset < _titleHeight && !_hideNavigationBtn) {
      setState(() {
        _hideNavigationBtn = true;
      });
    } else if (_controller.offset >= _titleHeight && _hideNavigationBtn) {
      setState(() {
        _hideNavigationBtn = false;
      });
    }
  }

  /// NotificationListener监听
  _scrollUpdateNotification(notification) {
    if (notification is ScrollUpdateNotification && notification.depth == 0) {
      double _offset = notification.metrics.pixels;

      /// 导航栏封面和阅读按钮显示切换控制
      /// 滑动超过 _titleHeight 时显示
      if (_offset < _titleHeight && !_hideNavigationBtn) {
        setState(() {
          _hideNavigationBtn = true;
        });
      } else if (_offset >= _titleHeight && _hideNavigationBtn) {
        setState(() {
          _hideNavigationBtn = false;
        });
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _controller.addListener(_controllerLister);
  }

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    double _statusBarHeight = MediaQuery.of(context).padding.top;

    var _tinyImg = _hideNavigationBtn
        ? Container()
        : CoveTinyImage(
            imgUrl: widget.galleryItem.imgUrl,
            statusBarHeight: _statusBarHeight,
          );

    var _navReadButton =
        _hideNavigationBtn ? Container() : _readButton(ln.READ);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: _tinyImg,
        trailing: _navReadButton,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          margin: const EdgeInsets.only(left: 12),
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            controller: _controller,
            dragStartBehavior: DragStartBehavior.down,
            children: <Widget>[
              _buildGalletyHead(context),
              Container(
                height: 0.5,
                color: CupertinoColors.systemGrey4,
              ),
              _loading
                  ? Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: CupertinoActivityIndicator(
                        radius: 15.0,
                      ),
                    )
                  : GalleryDetailContex(
                      lisTagGroupW: _lisTagGroupW, galleryItem: _galleryItem),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalletyHead(BuildContext context) {
    Color _colorCategory = ThemeColors
            .nameColor[widget?.galleryItem?.category ?? "defaule"]["color"] ??
        CupertinoColors.white;
//    Global.logger.v('${widget.galleryItem.url}_cover_${widget.fromTabIndex}');
    var ln = S.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 12, 12),
      child: Column(
        children: [
          Container(
            height: _titleHeight,
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
//                      minWidth: double.infinity, //宽度尽可能大
//                      minWidth: 130.0,
                      maxWidth: 150.0
//                maxWidth: 140,
                      ),
                  child: Container(
//                    color: CupertinoColors.systemGrey6,
                    margin: const EdgeInsets.only(right: 10),
//                    width: 130,
                    child: Hero(
                      tag: widget.galleryItem.url +
                          '_cover_${widget.fromTabIndex}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: widget.galleryItem.imgUrl,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 标题
                      Text(
                        widget.title,
                        maxLines: 5,
                        textAlign: TextAlign.left, // 对齐方式
                        overflow: TextOverflow.ellipsis, // 超出部分省略号
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
//                          fontFamilyFallback: EHConst.FONT_FAMILY_FB,
                        ),
                      ),
                      // 上传用户
                      Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          widget?.galleryItem?.uploader ?? '',
                          maxLines: 1,
                          textAlign: TextAlign.left, // 对齐方式
                          overflow: TextOverflow.ellipsis, // 超出部分省略号
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.brown,
                            fontWeight: FontWeight.w500,
//                            fontFamilyFallback: EHConst.FONT_FAMILY_FB,
                          ),
                        ),
                      ),
                      Spacer(),
                      // 阅读按钮
                      Row(
                        children: <Widget>[
                          _readButton(ln.READ),
                          Spacer(),
                          // 收藏按钮
                          _loading
                              ? Container(
                                  height: 38,
                                )
                              : GalleryFavButton(
                                  favTitle: _galleryItem.favTitle,
                                  gid: widget.galleryItem.gid,
                                  token: widget.galleryItem.token,
                                )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: <Widget>[
                // 评分
                Container(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text("${widget?.galleryItem?.rating ?? ''}")),
                // 星星
                StaticRatingBar(
                  size: 18.0,
                  rate: widget?.galleryItem?.rating ?? 0,
                  radiusRatio: 1.5,
                ),
                Spacer(),
                // 类型
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                    color: _colorCategory,
                    child: Text(
                      widget?.galleryItem?.category ?? '',
                      style: TextStyle(
                        fontSize: 14.5,
                        // height: 1.1,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  CupertinoButton _readButton(String text) {
    return CupertinoButton(
        child: Text(
          text,
          style: TextStyle(fontSize: 15),
        ),
        minSize: 20,
        padding: const EdgeInsets.fromLTRB(15, 2.5, 15, 2.5),
        borderRadius: BorderRadius.circular(50),
        color: CupertinoColors.activeBlue,
        onPressed: () {});
  }
}

class GalleryFavButton extends StatefulWidget {
  final String favTitle;
  final String gid;
  final String token;

  const GalleryFavButton({
    Key key,
    this.favTitle,
    @required this.gid,
    @required this.token,
  }) : super(key: key);

  @override
  _GalleryFavButtonState createState() => _GalleryFavButtonState();
}

class _GalleryFavButtonState extends State<GalleryFavButton> {
  String _favTitle;
  bool _isLoading = false;
  String _addFavcat;
  String _addFavnote;

  // 收藏输入框控制器
  TextEditingController _favnoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _favTitle = widget.favTitle;
    _addFavcat = '';
    _addFavnote = '';
  }

  void _tapFav(context) async {
    if (_favTitle.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        Global.logger.v("取消收藏");
        await GalleryFavParser.galleryAddfavorite(widget.gid, widget.token);
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
          _addFavcat = _lastFavcat;
          _favTitle =
              Global.profile.user.favcat[int.parse(_addFavcat)]['favTitle'];
        });
      } else {
        // 手选收藏夹
        var favList =
            await GalleryFavParser.getFavcat(widget.gid, widget.token);
        Global.profile.ehConfig.favPicker ?? false
            ? await _showAddFavPicker(context, favList)
            : await _showAddFavList(context, favList);
      }

      if (_addFavcat != null && _addFavcat.trim().isNotEmpty) {
        Global.logger.v('_addFavcat  $_addFavcat');
        Global.profile.ehConfig.lastFavcat = _addFavcat;
        try {
          await GalleryFavParser.galleryAddfavorite(widget.gid, widget.token,
              favcat: _addFavcat);
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
      var favList = await GalleryFavParser.getFavcat(widget.gid, widget.token);
      Global.profile.ehConfig.favPicker
          ? await _showAddFavPicker(context, favList)
          : await _showAddFavList(context, favList);

      if (_addFavcat != null && _addFavcat.trim().isNotEmpty) {
        Global.logger.v('_addFavcat  $_addFavcat');
        Global.profile.ehConfig.lastFavcat = _addFavcat;
        try {
          await GalleryFavParser.galleryAddfavorite(widget.gid, widget.token,
              favcat: _addFavcat);
        } catch (e) {} finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// 添加收藏
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
                  keyboardType: TextInputType.number,
                  onEditingComplete: () {
                    // 点击键盘完成
                    // 添加收藏
                    setState(() {
                      _isLoading = true;
                    });
                    _addFavcat = '$_favindex';
                    _favTitle = favList[_favindex]['favTitle'];
                    _addFavnote = _favnoteController.text;
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
                  _addFavcat = '';
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
                _addFavcat = '$_favindex';
                _favTitle = favList[_favindex]['favTitle'];
                _addFavnote = _favnoteController.text;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 添加收藏2
  Future<void> _showAddFavList(BuildContext context, List favList) async {
    List<Widget> favcatList = List<Widget>.from(favList.map((e) => Container(
          child: Column(
            children: [
              Container(
                color: CupertinoColors.systemGrey2,
                height: 0.5,
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Text(
                    e['favTitle'],
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _addFavcat = e['favId'];
                  _favTitle = e['favTitle'];
                  _addFavnote = _favnoteController.text;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
                  keyboardType: TextInputType.number,
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
                  _addFavcat = '';
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
                Icon(FontAwesomeIcons.solidHeart),
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
      child: Container(
//        width: 70,
        child: _isLoading ? _loadIcon : favIcon,
      ),
      onTap: () => _tapFav(context),
      onLongPress: () => _longTapFav(context),
    );
  }
}
