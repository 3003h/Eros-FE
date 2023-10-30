import 'package:english_words/english_words.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../widget/text_avatar.dart';

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
  final EhSettingService _ehSettingService = Get.find();
  final UserController _userController = Get.find();
  final avatarSize = 32.0;

  Widget boringAvatar(
    BoringAvatarsType type, {
    String? name,
    AvatarBorderRadiusType? borderRadiusType = AvatarBorderRadiusType.circle,
  }) {
    String _word = generateWordPairs().take(1).first.asString;

    final _username = name ?? _word;
    final _borderRadiusType =
        borderRadiusType ?? _ehSettingService.avatarBorderRadiusType;
    final borderRadius = BorderRadius.circular(
        _borderRadiusType == AvatarBorderRadiusType.roundedRect
            ? 8
            : avatarSize / 2);

    return Container(
      width: avatarSize,
      height: avatarSize,
      margin: const EdgeInsets.symmetric(vertical: 4),
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

  Widget textAvatar(
    TextAvatarsType type, {
    String? name,
    AvatarBorderRadiusType? borderRadiusType = AvatarBorderRadiusType.circle,
  }) {
    String _word = generateWordPairs().take(1).first.asString;

    final _username = name ?? _word;
    final _borderRadiusType =
        borderRadiusType ?? _ehSettingService.avatarBorderRadiusType;
    final radius = _borderRadiusType == AvatarBorderRadiusType.roundedRect
        ? 8.0
        : avatarSize / 2;
    final borderRadius = BorderRadius.circular(radius);

    return Container(
      width: avatarSize,
      height: avatarSize,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedClipRRect(
        borderRadius: borderRadius,
        duration: const Duration(milliseconds: 300),
        child: TextAvatar(
          name: _username,
          colors: ThemeColors.catColorList,
          type: type,
          radius: radius,
        ),
      ),
      // child: SizedBox.shrink(),
    );
  }

  static const double paddingHorizontal = 20.0;

  @override
  Widget build(BuildContext context) {
    final _username = _userController.user.value.nickName ??
        _userController.user.value.memberId ??
        'seed';

    final List<Widget> _list = <Widget>[
      TextSwitchItem(
        L10n.of(context).show_comment_avatar,
        value: _ehSettingService.showCommentAvatar,
        onChanged: (val) => _ehSettingService.showCommentAvatar = val,
        hideDivider: true,
      ),
      const ItemSpace(),
      Container(
        color: ehTheme.itemBackgroundColor,
        constraints: const BoxConstraints(
          minHeight: kItemHeight,
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: paddingHorizontal),
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
                      AvatarBorderRadiusType.circle: _ehSettingService
                                  .avatarType ==
                              AvatarType.boringAvatar
                          ? boringAvatar(
                              _ehSettingService.boringAvatarsType,
                              borderRadiusType: AvatarBorderRadiusType.circle,
                              name: _username,
                            )
                          : textAvatar(
                              _ehSettingService.textAvatarsType,
                              borderRadiusType: AvatarBorderRadiusType.circle,
                              name: _username,
                            ),
                      AvatarBorderRadiusType.roundedRect:
                          _ehSettingService.avatarType ==
                                  AvatarType.boringAvatar
                              ? boringAvatar(
                                  _ehSettingService.boringAvatarsType,
                                  borderRadiusType:
                                      AvatarBorderRadiusType.roundedRect,
                                  name: _username,
                                )
                              : textAvatar(
                                  _ehSettingService.textAvatarsType,
                                  borderRadiusType:
                                      AvatarBorderRadiusType.roundedRect,
                                  name: _username,
                                ),
                    },
                    groupValue: _ehSettingService.avatarBorderRadiusType,
                    onValueChanged: (AvatarBorderRadiusType? value) {
                      _ehSettingService.avatarBorderRadiusType =
                          value ?? AvatarBorderRadiusType.circle;
                    },
                  );
                }),
              ],
            ).paddingSymmetric(vertical: 4),
          ],
        ),
      ),
      const ItemSpace(),
      Obx(() {
        return Container(
          color: CupertinoDynamicColor.resolve(
              ehTheme.itemBackgroundColor!, context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 50),
                padding: EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: paddingHorizontal + context.mediaQueryPadding.left,
                    right: paddingHorizontal + context.mediaQueryPadding.right),
                child: Row(
                  children: [
                    CupertinoSlidingSegmentedControl<BoringAvatarsType>(
                      children: <BoringAvatarsType, Widget>{
                        BoringAvatarsType.beam: boringAvatar(
                          BoringAvatarsType.beam,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                        BoringAvatarsType.bauhaus: boringAvatar(
                          BoringAvatarsType.bauhaus,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                        BoringAvatarsType.sunset: boringAvatar(
                          BoringAvatarsType.sunset,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                        BoringAvatarsType.marble: boringAvatar(
                          BoringAvatarsType.marble,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                        BoringAvatarsType.pixel: boringAvatar(
                          BoringAvatarsType.pixel,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                        BoringAvatarsType.ring: boringAvatar(
                          BoringAvatarsType.ring,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                      },
                      groupValue: _ehSettingService.boringAvatarsType,
                      onValueChanged: (BoringAvatarsType? value) {
                        _ehSettingService.boringAvatarsType =
                            value ?? BoringAvatarsType.beam;
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          logger.d('boringAvatars');
                          _ehSettingService.avatarType =
                              AvatarType.boringAvatar;
                        },
                        child: _ehSettingService.avatarType ==
                                AvatarType.boringAvatar
                            ? Container(
                                    alignment: Alignment.centerRight,
                                    child: const Icon(FontAwesomeIcons.check))
                                .paddingOnly(right: 8)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                indent: paddingHorizontal,
                height: kDividerHeight,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey4, context),
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 50),
                padding: EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: paddingHorizontal + context.mediaQueryPadding.left,
                    right: paddingHorizontal + context.mediaQueryPadding.right),
                child: Row(
                  children: [
                    CupertinoSlidingSegmentedControl<TextAvatarsType>(
                      children: <TextAvatarsType, Widget>{
                        TextAvatarsType.firstText: textAvatar(
                          TextAvatarsType.firstText,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                        TextAvatarsType.firstTowText: textAvatar(
                          TextAvatarsType.firstTowText,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                        TextAvatarsType.noText: textAvatar(
                          TextAvatarsType.noText,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                        TextAvatarsType.borderFirstText: textAvatar(
                          TextAvatarsType.borderFirstText,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                        TextAvatarsType.borderFirstTowText: textAvatar(
                          TextAvatarsType.borderFirstTowText,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                        TextAvatarsType.onlyBorder: textAvatar(
                          TextAvatarsType.onlyBorder,
                          borderRadiusType:
                              _ehSettingService.avatarBorderRadiusType,
                        ),
                      },
                      groupValue: _ehSettingService.textAvatarsType,
                      onValueChanged: (TextAvatarsType? value) {
                        _ehSettingService.textAvatarsType =
                            value ?? TextAvatarsType.firstText;
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          logger.d('textAvatars');
                          _ehSettingService.avatarType = AvatarType.textAvatar;
                        },
                        child: _ehSettingService.avatarType ==
                                AvatarType.textAvatar
                            ? Container(
                                    alignment: Alignment.centerRight,
                                    child: const Icon(FontAwesomeIcons.check))
                                .paddingOnly(right: 8)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    ];

    return ListView.builder(
      itemCount: _list.length,
      // shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );

    // return Column(
    //   children: _list,
    // );
  }
}
