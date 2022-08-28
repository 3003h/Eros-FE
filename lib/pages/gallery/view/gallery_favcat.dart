import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_fav_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 收藏操作处理类
class GalleryFavButton extends StatelessWidget {
  const GalleryFavButton({
    Key? key,
  }) : super(key: key);

  GalleryFavController get _favController => Get.find(tag: pageCtrlTag);

  @override
  Widget build(BuildContext context) {
    const double iconSize = 28.0;
    // 收藏按钮图标
    final Widget favIcon = Obx(() {
      return MouseRegionClick(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 14,
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                _favController.isFav ? _favController.favTitle : '',
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
            if (_favController.isFav)
              Icon(
                FontAwesomeIcons.solidHeart,
                color: ThemeColors.favColor[_favController.favcat],
                size: iconSize,
              )
            else
              const Icon(
                FontAwesomeIcons.heart,
                color: CupertinoColors.systemGrey,
                size: iconSize,
              ),
          ],
        ),
      );
    });

    final Widget _loadIcon = Row(
      children: <Widget>[
        Container(
          height: 16,
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            // L10n.of(context).processing,
            '',
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ),
        const CupertinoActivityIndicator(
          radius: 10.0,
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
    Key? key,
    required VoidCallback onTap,
    required this.text,
    this.favcat,
    this.totNum,
  })  : _onTap = onTap,
        super(key: key);

  final VoidCallback _onTap;
  final String text;
  final String? favcat;
  final int? totNum;

  @override
  _FavcatAddListItemState createState() => _FavcatAddListItemState();
}

class _FavcatAddListItemState extends State<FavcatAddListItem> {
  Color? _color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: _color,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.solidHeart,
                color: CupertinoDynamicColor.resolve(
                    ThemeColors.favColor[widget.favcat]!, context),
                size: 18,
              ).paddingOnly(left: 8, right: 8, bottom: 4),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.totNum ?? 0}',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ).paddingOnly(right: 4),
            ],
          ),
        ),
        onTap: widget._onTap,
        onTapDown: (_) {
          setState(() {
            _color = CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey3, context);
          });
        },
        onTapCancel: () {
          setState(() {
            _color = null;
          });
        },
      ),
    );
  }
}
