import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/setting/webview/mytags_in.dart';
import 'package:fehviewer/pages/setting/webview/web_mysetting_in.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'setting_base.dart';

class EhSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          middle: Text(L10n.of(context).eh),
        ),
        child: SafeArea(
          child: ListViewEhSetting(),
          bottom: false,
        ));

    return cps;
  }
}

class ListViewEhSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();
    final UserController userController = Get.find();
    final TagTransController transController = Get.find();
    final LocaleService localeService = Get.find();

    final bool _siteEx = _ehConfigService.isSiteEx.value;
    final bool _jpnTitle = _ehConfigService.isJpnTitle.value;
    final bool _tagTranslat = _ehConfigService.isTagTranslat;
    final bool _galleryImgBlur = _ehConfigService.isGalleryImgBlur.value;
    final bool _favLongTap = _ehConfigService.isFavLongTap.value;
    final bool _isLogin = userController.isLogin;
    final bool _isClipboar = _ehConfigService.isClipboardLink.value;

    Future<void> _handleSiteChanged(bool newValue) async {
      _ehConfigService.isSiteEx(newValue);
      Api.selEhProfile();
    }

    void _handleJpnTitleChanged(bool newValue) {
      _ehConfigService.isJpnTitle(newValue);
    }

    Future<void> _handleTagTranslatChanged(bool newValue) async {
      _ehConfigService.isTagTranslat = newValue;
      if (newValue) {
        try {
          if (await transController.checkUpdate()) {
            showToast('更新开始');
            await transController.updateDB();
            showToast('更新完成');
          } else {
            logger.v('do not need update');
          }
        } catch (e) {
          logger.e('更新翻译异常 $e');
          rethrow;
        }
      }
    }

    void _handleGalleryListImgBlurChanged(bool newValue) {
      _ehConfigService.isGalleryImgBlur.value = newValue;
    }

    void _handleFavLongTapChanged(bool newValue) {
      _ehConfigService.isFavLongTap.value = newValue;
    }

    void _handleClipboarLinkTapChange(bool val) {
      _ehConfigService.isClipboardLink.value = val;
    }

    Future<void> _forceUpdateTranslate() async {
      if (await transController.checkUpdate(force: true)) {
        showToast('手动更新开始');
        await transController.updateDB();
        showToast('更新完成');
      }
    }

    final List<Widget> _list = <Widget>[
      if (_isLogin)
        TextSwitchItem(
          L10n.of(context).galery_site,
          intValue: _siteEx,
          onChanged: _handleSiteChanged,
          desc: L10n.of(context).current_site('E-Hentai'),
          descOn: L10n.of(context).current_site('ExHentai'),
        ),
      if (_isLogin)
        const SelectorSettingItem(
          title: 'Cookie',
          selector: '',
          onTap: showUserCookie,
        ),
      if (_isLogin)
        SelectorSettingItem(
          title: L10n.of(context).ehentai_settings,
          selector: L10n.of(context).setting_on_website,
          onTap: () {
            if (GetPlatform.isAndroid || GetPlatform.isIOS) {
              if (_ehConfigService.debugMode) {
                Get.toNamed(
                  EHRoutes.mySettings,
                  id: isLayoutLarge ? 2 : null,
                );
              } else {
                Get.to(() => InWebMySetting());
              }
            } else {
              showToast('Not support');
            }
          },
          onLongPress: () async {
            await Api.selEhProfile();
            showToast('set EhProfile succs');
          },
        ),
      if (_isLogin)
        SelectorSettingItem(
          hideLine: true,
          title: L10n.of(context).ehentai_my_tags,
          selector: L10n.of(context).mytags_on_website,
          onTap: () {
            if (GetPlatform.isAndroid) {
              Get.to(() => InWebMyTags());
            } else if (GetPlatform.isIOS) {
              Get.to(() => InWebMyTags());
            } else {
              showToast('Not support');
            }
          },
        ),
      if (_isLogin) Container(height: 38),
      SelectorSettingItem(
        title: 'WebDAV',
        onTap: () {
          Get.toNamed(
            EHRoutes.webDavSetting,
            id: isLayoutLarge ? 2 : null,
          );
        },
        hideLine: true,
      ),
      Container(height: 38),
      if (localeService.isLanguageCodeZh)
        Obx(() => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: () async {
                vibrateUtil.light();
                _forceUpdateTranslate();
              },
              child: TextSwitchItem(
                '显示标签中文翻译',
                intValue: _tagTranslat,
                onChanged: _handleTagTranslatChanged,
                desc: '当前版本:${_ehConfigService.tagTranslatVer.value}',
                suffix: CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(CupertinoIcons.refresh),
                  onPressed: _forceUpdateTranslate,
                ),
              ),
            )),
      Obx(() {
        // if (_ehConfigService.isTagTranslat) {
        //   return _buildTagIntroImgLvItem(context);
        // } else {
        //   return const SizedBox();
        // }

        return AnimatedCrossFade(
          alignment: Alignment.center,
          crossFadeState: _ehConfigService.isTagTranslat
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstCurve: Curves.easeIn,
          secondCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox(),
          secondChild: _buildTagIntroImgLvItem(context),
        );
      }),
      TextSwitchItem(
        L10n.of(context).show_jpn_title,
        intValue: _jpnTitle,
        onChanged: _handleJpnTitleChanged,
        // desc: '如果该画廊有日文标题则优先显示',
      ),
      if (localeService.isLanguageCodeZh)
        TextSwitchItem(
          '画廊封面模糊',
          intValue: _galleryImgBlur,
          onChanged: _handleGalleryListImgBlurChanged,
          hideLine: true,
          // desc: '画廊列表封面模糊效果',
        ),
      Container(height: 38),
      TextSwitchItem(
        L10n.of(context).default_favorites,
        intValue: _favLongTap,
        onChanged: _handleFavLongTapChanged,
        desc: L10n.of(context).manually_sel_favorites,
        descOn: L10n.of(context).last_favorites,
      ),
      TextSwitchItem(
        L10n.of(context).clipboard_detection,
        intValue: _isClipboar,
        onChanged: _handleClipboarLinkTapChange,
        desc: L10n.of(context).clipboard_detection_desc,
      ),
      if (localeService.isLanguageCodeZh)
        TextSwitchItem(
          '评论机翻按钮',
          intValue: _ehConfigService.commentTrans.value,
          onChanged: (bool newValue) =>
              _ehConfigService.commentTrans.value = newValue,
          desc: '关闭',
          descOn: '用机器翻译将评论翻译为简体中文',
        ),
      _buildListModeItem(context, hideLine: true),
    ];

    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }
}

/// 列表模式切换
Widget _buildListModeItem(BuildContext context, {bool hideLine = false}) {
  final String _title = L10n.of(context).list_mode;
  final EhConfigService ehConfigService = Get.find();

  final Map<ListModeEnum, String> modeMap = <ListModeEnum, String>{
    ListModeEnum.list: L10n.of(context).listmode_medium,
    ListModeEnum.simpleList: L10n.of(context).listmode_small,
    ListModeEnum.waterfall: L10n.of(context).listmode_waterfall,
    ListModeEnum.waterfallLarge: L10n.of(context).listmode_waterfall_large,
  };
  return Obx(() {
    return SelectorItem<ListModeEnum>(
      title: _title,
      hideLine: hideLine,
      actionMap: modeMap,
      initVal: ehConfigService.listMode.value,
      onValueChanged: (val) => ehConfigService.listMode.value = val,
    );
  });
}

/// 列表模式切换
Widget _buildListModeItem_Old(BuildContext context, {bool hideLine = false}) {
  final String _title = L10n.of(context).list_mode;
  final EhConfigService ehConfigService = Get.find();

  final Map<ListModeEnum, String> modeMap = <ListModeEnum, String>{
    ListModeEnum.list: L10n.of(context).listmode_medium,
    ListModeEnum.simpleList: L10n.of(context).listmode_small,
    ListModeEnum.waterfall: L10n.of(context).listmode_waterfall,
    ListModeEnum.waterfallLarge: L10n.of(context).listmode_waterfall_large,
  };

  List<Widget> _getModeList(BuildContext context) {
    return List<Widget>.from(modeMap.keys.map((ListModeEnum element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(modeMap[element] ?? ''));
    }).toList());
  }

  Future<ListModeEnum?> _showDialog(BuildContext context) {
    return showCupertinoModalPopup<ListModeEnum>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            title: Text(_title),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              ..._getModeList(context),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => SelectorSettingItem(
        title: _title,
        hideLine: hideLine,
        selector: modeMap[ehConfigService.listMode.value] ?? '',
        onTap: () async {
          logger.v('tap ModeItem');
          final ListModeEnum? _result = await _showDialog(context);
          if (_result != null) {
            // ignore: unnecessary_string_interpolations
            logger.v('${EnumToString.convertToString(_result)}');
            ehConfigService.listMode.value = _result;
          }
        },
      ));
}

/// 标签介绍图片切换
Widget _buildTagIntroImgLvItem(BuildContext context) {
  final String _title = '标签介绍图片';
  final EhConfigService ehConfigService = Get.find();

  final Map<TagIntroImgLv, String> descMap = <TagIntroImgLv, String>{
    TagIntroImgLv.disable: '禁用',
    TagIntroImgLv.nonh: '隐藏H图片',
    TagIntroImgLv.r18: '隐藏引起不适的图片',
    TagIntroImgLv.r18g: '全部显示',
  };

  List<Widget> _getModeList(BuildContext context) {
    return List<Widget>.from(descMap.keys.map((TagIntroImgLv element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(descMap[element] ?? ''));
    }).toList());
  }

  Future<TagIntroImgLv?> _showDialog(BuildContext context) {
    return showCupertinoModalPopup<TagIntroImgLv>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            title: Text(_title),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              ..._getModeList(context),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => SelectorSettingItem(
        title: _title,
        selector: descMap[ehConfigService.tagIntroImgLv.value] ?? '',
        onTap: () async {
          logger.v('tap TagIntroImgLvItem');
          final TagIntroImgLv? _result = await _showDialog(context);
          if (_result != null) {
            // ignore: unnecessary_string_interpolations
            logger.v('${EnumToString.convertToString(_result)}');
            ehConfigService.tagIntroImgLv.value = _result;
          }
        },
      ));
}
