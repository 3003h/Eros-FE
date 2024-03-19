import 'package:english_words/english_words.dart';
import 'package:eros_fe/common/controller/user_controller.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/const/theme_colors.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/widget/text_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

const kAvatarSize = 32.0;
const kPaddingHorizontal = 20.0;

class AvatarSettingPage extends StatelessWidget {
  const AvatarSettingPage({super.key});

  EhSettingService get _ehSettingService => Get.find();

  UserController get _userController => Get.find();

  @override
  Widget build(BuildContext context) {
    final _username = _userController.user.value.nickName ??
        _userController.user.value.memberId ??
        'seed';

    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: Text(L10n.of(context).avatar),
        ),
        child: CustomScrollView(
          slivers: [
            SliverSafeArea(
              sliver: MultiSliver(
                children: [
                  SliverCupertinoListSection.listInsetGrouped(children: [
                    // show_comment_avatar switch
                    CupertinoListTile(
                      title: Text(L10n.of(context).show_comment_avatar),
                      trailing: Obx(() {
                        return CupertinoSwitch(
                          value: _ehSettingService.showCommentAvatar,
                          onChanged: (bool value) {
                            _ehSettingService.showCommentAvatar = value;
                          },
                        );
                      }),
                    ),
                  ]),
                  SliverCupertinoListSection.listInsetGrouped(children: [
                    // show_comment_avatar switch
                    EhCupertinoListTile(
                      title: Text(L10n.of(context).default_avatar_style),
                      trailing: Obx(() {
                        return CupertinoSlidingSegmentedControl<
                            AvatarBorderRadiusType>(
                          children: <AvatarBorderRadiusType, Widget>{
                            AvatarBorderRadiusType.circle:
                                _ehSettingService.avatarType ==
                                        AvatarType.boringAvatar
                                    ? _BoringAvatar(
                                        _ehSettingService.boringAvatarsType,
                                        borderRadiusType:
                                            AvatarBorderRadiusType.circle,
                                        name: _username,
                                      )
                                    : _TextAvatar(
                                        _ehSettingService.textAvatarsType,
                                        borderRadiusType:
                                            AvatarBorderRadiusType.circle,
                                        name: _username,
                                      ),
                            AvatarBorderRadiusType.roundedRect:
                                _ehSettingService.avatarType ==
                                        AvatarType.boringAvatar
                                    ? _BoringAvatar(
                                        _ehSettingService.boringAvatarsType,
                                        borderRadiusType:
                                            AvatarBorderRadiusType.roundedRect,
                                        name: _username,
                                      )
                                    : _TextAvatar(
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
                    ),
                  ]),

                  // 头像类型
                  Obx(() {
                    return SliverCupertinoListSection
                        .listInsetGrouped(children: [
                      EhCupertinoListTile(
                        title:
                            CupertinoSlidingSegmentedControl<BoringAvatarsType>(
                          children: <BoringAvatarsType, Widget>{
                            BoringAvatarsType.beam: _BoringAvatar(
                              BoringAvatarsType.beam,
                              borderRadiusType:
                                  _ehSettingService.avatarBorderRadiusType,
                            ),
                            BoringAvatarsType.bauhaus: _BoringAvatar(
                              BoringAvatarsType.bauhaus,
                              borderRadiusType:
                                  _ehSettingService.avatarBorderRadiusType,
                            ),
                            BoringAvatarsType.sunset: _BoringAvatar(
                              BoringAvatarsType.sunset,
                              borderRadiusType:
                                  _ehSettingService.avatarBorderRadiusType,
                            ),
                            BoringAvatarsType.marble: _BoringAvatar(
                              BoringAvatarsType.marble,
                              borderRadiusType:
                                  _ehSettingService.avatarBorderRadiusType,
                            ),
                            BoringAvatarsType.pixel: _BoringAvatar(
                              BoringAvatarsType.pixel,
                              borderRadiusType:
                                  _ehSettingService.avatarBorderRadiusType,
                            ),
                            BoringAvatarsType.ring: _BoringAvatar(
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
                      ),
                      EhCupertinoListTile(
                        title: Center(
                          child: AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            firstChild: const Icon(CupertinoIcons.circle,
                                color: CupertinoColors.systemGrey),
                            secondChild: const Icon(
                                CupertinoIcons.check_mark_circled_solid),
                            crossFadeState: _ehSettingService.avatarType ==
                                    AvatarType.boringAvatar
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                          ),
                        ),
                        onTap: () {
                          _ehSettingService.avatarType =
                              AvatarType.boringAvatar;
                        },
                      ),
                    ]);
                  }),

                  Obx(() {
                    return SliverCupertinoListSection
                        .listInsetGrouped(children: [
                      EhCupertinoListTile(
                        title:
                            CupertinoSlidingSegmentedControl<TextAvatarsType>(
                          children: <TextAvatarsType, Widget>{
                            TextAvatarsType.firstText: _TextAvatar(
                              TextAvatarsType.firstText,
                              borderRadiusType:
                                  _ehSettingService.avatarBorderRadiusType,
                            ),
                            TextAvatarsType.firstTowText: _TextAvatar(
                              TextAvatarsType.firstTowText,
                              borderRadiusType:
                                  _ehSettingService.avatarBorderRadiusType,
                            ),
                            TextAvatarsType.noText: _TextAvatar(
                              TextAvatarsType.noText,
                              borderRadiusType:
                                  _ehSettingService.avatarBorderRadiusType,
                            ),
                            TextAvatarsType.borderFirstText: _TextAvatar(
                              TextAvatarsType.borderFirstText,
                              borderRadiusType:
                                  _ehSettingService.avatarBorderRadiusType,
                            ),
                            TextAvatarsType.borderFirstTowText: _TextAvatar(
                              TextAvatarsType.borderFirstTowText,
                              borderRadiusType:
                                  _ehSettingService.avatarBorderRadiusType,
                            ),
                            TextAvatarsType.onlyBorder: _TextAvatar(
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
                      ),
                      EhCupertinoListTile(
                        title: Center(
                          child: AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            firstChild: const Icon(CupertinoIcons.circle,
                                color: CupertinoColors.systemGrey),
                            secondChild: const Icon(
                                CupertinoIcons.check_mark_circled_solid),
                            crossFadeState: _ehSettingService.avatarType ==
                                    AvatarType.textAvatar
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                          ),
                        ),
                        onTap: () {
                          _ehSettingService.avatarType = AvatarType.textAvatar;
                        },
                      ),
                    ]);
                  }),
                ],
              ),
            ),
          ],
        ));
  }
}

class _BoringAvatar extends StatelessWidget {
  const _BoringAvatar(
    this.type, {
    this.name,
    this.borderRadiusType = AvatarBorderRadiusType.circle,
    super.key,
  });

  final BoringAvatarsType type;
  final String? name;
  final AvatarBorderRadiusType? borderRadiusType;

  EhSettingService get _ehSettingService => Get.find();

  @override
  Widget build(BuildContext context) {
    String _word = generateWordPairs().take(1).first.asString;

    final _username = name ?? _word;
    final _borderRadiusType =
        borderRadiusType ?? _ehSettingService.avatarBorderRadiusType;
    final borderRadius = BorderRadius.circular(
        _borderRadiusType == AvatarBorderRadiusType.roundedRect
            ? 8
            : kAvatarSize / 2);

    return Container(
      width: kAvatarSize,
      height: kAvatarSize,
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
}

class _TextAvatar extends StatelessWidget {
  const _TextAvatar(
    this.type, {
    this.name,
    this.borderRadiusType = AvatarBorderRadiusType.circle,
    super.key,
  });

  final TextAvatarsType type;
  final String? name;
  final AvatarBorderRadiusType? borderRadiusType;

  EhSettingService get _ehSettingService => Get.find();

  @override
  Widget build(BuildContext context) {
    String _word = generateWordPairs().take(1).first.asString;

    final _username = name ?? _word;
    final _borderRadiusType =
        borderRadiusType ?? _ehSettingService.avatarBorderRadiusType;
    final radius = _borderRadiusType == AvatarBorderRadiusType.roundedRect
        ? 8.0
        : kAvatarSize / 2;
    final borderRadius = BorderRadius.circular(radius);

    return Container(
      width: kAvatarSize,
      height: kAvatarSize,
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
}
