import 'package:english_words/english_words.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';
import 'package:get/get.dart';

class AvatarSettingPage extends StatelessWidget {
  const AvatarSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget cps = Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            middle: Text(L10n.of(context).avatar),
          ),
          child: SafeArea(
            child: _ListView(),
            bottom: false,
          ));
    });

    return cps;
  }
}

class _ListView extends StatelessWidget {
  _ListView({Key? key}) : super(key: key);
  final EhConfigService _ehConfigService = Get.find();
  final UserController _userController = Get.find();
  final avatarSize = 30.0;

  Widget boringAvatar(
    BoringAvatarsType type, {
    String? name,
    AvatarBorderRadiusType? borderRadiusType = AvatarBorderRadiusType.circle,
  }) {
    String _word = generateWordPairs().take(1).first.asString;

    final _username = name ?? _word;
    final _borderRadiusType =
        borderRadiusType ?? _ehConfigService.avatarBorderRadiusType;
    final borderRadius = BorderRadius.circular(
        _borderRadiusType == AvatarBorderRadiusType.roundedRect
            ? 8
            : avatarSize / 2);

    return Container(
      width: avatarSize,
      height: avatarSize,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedClipRRect(
        borderRadius: borderRadius,
        duration: const Duration(milliseconds: 300),
        child: AnimatedBoringAvatars(
          duration: const Duration(milliseconds: 300),
          name: _username,
          colors: ThemeColors.catColorList,
          type: type,
          square: true,
        ),
      ),
      // child: SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _username = _userController.user.value.nickName ??
        _userController.user.value.memberId ??
        'seed';

    final List<Widget> _list = <Widget>[
      TextSwitchItem(
        L10n.of(context).show_comment_avatar,
        intValue: _ehConfigService.showCommentAvatar,
        onChanged: (val) => _ehConfigService.showCommentAvatar = val,
        hideDivider: true,
      ),
      const ItemSpace(),
      Container(
        color: ehTheme.itemBackgroundColor,
        constraints: const BoxConstraints(
          minHeight: kItemHeight,
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    L10n.of(context).default_avatar_style,
                    style: const TextStyle(
                      height: 1.15,
                    ),
                  ),
                ),
                Obx(() {
                  return CupertinoSlidingSegmentedControl<
                      AvatarBorderRadiusType>(
                    children: <AvatarBorderRadiusType, Widget>{
                      AvatarBorderRadiusType.circle: boringAvatar(
                        _ehConfigService.boringAvatarsType,
                        borderRadiusType: AvatarBorderRadiusType.circle,
                        name: _username,
                      ),
                      AvatarBorderRadiusType.roundedRect: boringAvatar(
                        _ehConfigService.boringAvatarsType,
                        borderRadiusType: AvatarBorderRadiusType.roundedRect,
                        name: _username,
                      ),
                    },
                    groupValue: _ehConfigService.avatarBorderRadiusType,
                    onValueChanged: (AvatarBorderRadiusType? value) {
                      _ehConfigService.avatarBorderRadiusType =
                          value ?? AvatarBorderRadiusType.circle;
                    },
                  );
                }),
              ],
            ).paddingSymmetric(vertical: 8),
            Divider(
              // indent: 20.0,
              height: kDividerHeight,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            ),
          ],
        ),
      ),
      Obx(() {
        return Container(
          color: CupertinoDynamicColor.resolve(
              ehTheme.itemBackgroundColor!, context),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: CupertinoSlidingSegmentedControl<BoringAvatarsType>(
              children: <BoringAvatarsType, Widget>{
                BoringAvatarsType.beam: boringAvatar(
                  BoringAvatarsType.beam,
                  borderRadiusType: _ehConfigService.avatarBorderRadiusType,
                ),
                BoringAvatarsType.bauhaus: boringAvatar(
                  BoringAvatarsType.bauhaus,
                  borderRadiusType: _ehConfigService.avatarBorderRadiusType,
                ),
                BoringAvatarsType.sunset: boringAvatar(
                  BoringAvatarsType.sunset,
                  borderRadiusType: _ehConfigService.avatarBorderRadiusType,
                ),
                BoringAvatarsType.marble: boringAvatar(
                  BoringAvatarsType.marble,
                  borderRadiusType: _ehConfigService.avatarBorderRadiusType,
                ),
                BoringAvatarsType.pixel: boringAvatar(
                  BoringAvatarsType.pixel,
                  borderRadiusType: _ehConfigService.avatarBorderRadiusType,
                ),
                BoringAvatarsType.ring: boringAvatar(
                  BoringAvatarsType.ring,
                  borderRadiusType: _ehConfigService.avatarBorderRadiusType,
                ),
              },
              groupValue: _ehConfigService.boringAvatarsType,
              onValueChanged: (BoringAvatarsType? value) {
                _ehConfigService.boringAvatarsType =
                    value ?? BoringAvatarsType.beam;
              },
            ),
          ),
        );
      }),
    ];

    // return ListView.builder(
    //   itemCount: _list.length,
    //   // shrinkWrap: true,
    //   itemBuilder: (BuildContext context, int index) {
    //     return _list[index];
    //   },
    // );

    return Column(
      children: _list,
    );
  }
}
