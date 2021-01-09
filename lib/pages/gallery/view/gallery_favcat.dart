import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_fav_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 收藏操作处理类
class GalleryFavButton extends StatelessWidget {
  const GalleryFavButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GalleryFavController _favController =
        Get.put(GalleryFavController(), tag: pageCtrlDepth);
    // 收藏按钮图标
    final Widget favIcon = Obx(() {
      return Container(
        child: Column(
          children: <Widget>[
            if (_favController.isFav)
              Icon(
                FontAwesomeIcons.solidHeart,
                color: ThemeColors.favColor[_favController.favcat],
              )
            else
              const Icon(
                FontAwesomeIcons.heart,
                color: CupertinoColors.systemGrey,
              ),
            Container(
              height: 14,
              child: Text(
                _favController.isFav
                    ? _favController.favTitle
                    : S.of(context).notFav,
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    });

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
      child: Obx(() => Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: _favController.isLoading ? _loadIcon : favIcon,
          )),
      onTap: () => _favController.tapFav(),
      onLongPress: () => _favController.longTapFav(),
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
