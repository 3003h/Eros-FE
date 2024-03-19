// import 'package:cached_network_image/cached_network_image.dart';
import 'package:eros_fe/common/controller/user_controller.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/component/setting_base.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/route/routes.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/widget/image/eh_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UserItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserItem();
}

class _UserItem extends State<UserItem> {
  Color? _color;
  Color? _pBackgroundColor;

  final UserController _userController = Get.find();

  @override
  void initState() {
    super.initState();
    _color = CupertinoDynamicColor.resolve(
        ehTheme.itemBackgroundColor!, Get.context!);
    _pBackgroundColor = _color;
  }

  @override
  Widget build(BuildContext context) {
    final Color color =
        CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor!, context);
    if (_pBackgroundColor?.value != color.value) {
      _color = color;
      _pBackgroundColor = color;
    }

    void _tapItem() {
      if (_userController.isLogin) {
        _userController.showLogOutDialog(context);
      } else {
        // NavigatorUtil.jump(context, EHRoutes.login, rootNavigator: true);
        Get.toNamed(EHRoutes.login);
      }
    }

    Widget _buildText() {
      return Obx(() {
        if (_userController.isLogin) {
          final String _userName = _userController.user().username ?? '';
          return Text(_userName);
        } else {
          return Text(L10n.of(context).login);
        }
      });
    }

    Widget _buildAvastat() {
      const Widget _defAvatar = Icon(
        FontAwesomeIcons.solidUserCircle,
        size: 55.0,
        color: CupertinoColors.systemGrey,
      );

      logger.d('${_userController.user().avatarUrl} ');
      final String _avatarUrl = _userController.user().avatarUrl ?? '';
      if (_userController.isLogin && _avatarUrl.isNotEmpty) {
        return ClipOval(
          child: EhNetworkImage(
            imageUrl: _avatarUrl,
            width: 55,
            height: 55,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _defAvatar,
            placeholder: (_, __) => _defAvatar,
          ),
          // child: ExtendedImage.network(
          //   _avatarUrl.dfUrl,
          //   width: 55,
          //   height: 55,
          //   fit: BoxFit.cover,
          //   loadStateChanged: (ExtendedImageState state) {
          //     switch (state.extendedImageLoadState) {
          //       case LoadState.loading:
          //         return _defAvatar;
          //       case LoadState.failed:
          //         return _defAvatar;
          //       default:
          //         return null;
          //     }
          //   },
          // ),
        );
      } else {
        return _defAvatar;
      }
    }

    final Widget row = Container(
      color: _color,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(children: <Widget>[
        _buildAvastat(),
        // 头像右侧信息
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: _buildText(),
        )
      ]),
    );

    return GestureDetector(
      child: row,
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _tapItem();
      },
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
  }

  void _updateNormalColor() {
    setState(() {
      _color = CupertinoDynamicColor.resolve(
          ehTheme.itemBackgroundColor!, Get.context!);
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color = getPressedColor(context);
    });
  }
}

const double kAvatarSize = 40.0;
const double kNameTextSize = 13.0;

class UserWidget extends GetView<UserController> {
  Widget _buildAvastat() {
    const Widget _defAvatar = Icon(
      FontAwesomeIcons.solidCircleUser,
      size: kAvatarSize,
      color: CupertinoColors.systemGrey,
    );

    // logger.d('${controller.user().toJson()} ');
    final String _avatarUrl = controller.user().avatarUrl ?? '';
    return Obx(() {
      if (controller.isLogin && _avatarUrl.isNotEmpty) {
        return ClipOval(
          child: EhNetworkImage(
            imageUrl: _avatarUrl,
            width: kAvatarSize,
            height: kAvatarSize,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _defAvatar,
            placeholder: (_, __) => _defAvatar,
          ),
        );
      } else {
        return _defAvatar;
      }
    });
  }

  Widget _buildText() {
    return Obx(() {
      if (controller.isLogin) {
        final String? _userName = controller.user().username;
        final String? _nickName = controller.user().nickName;
        return Text(
          _nickName ?? _userName ?? '',
          style: TextStyle(
              fontSize: kNameTextSize,
              fontWeight: FontWeight.normal,
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.label,
                Get.context!,
              )),
        ).paddingOnly(right: 6);
      } else {
        return const SizedBox();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.isLogin) {
          controller.showLogOutDialog(context);
        } else {
          Get.toNamed(EHRoutes.login);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildText(),
          _buildAvastat(),
        ],
      ),
    );
  }
}
