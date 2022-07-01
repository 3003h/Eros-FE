import 'dart:convert';

import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:fehviewer/pages/tab/controller/tabbar/custom_sublist_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabbar/custom_tabbar_controller.dart';
import 'package:fehviewer/pages/tab/controller/tabbar/profile_edit_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../common/service/layout_service.dart';
import '../../fetch_list.dart';

const String kAttachTagSearch = 'TagSearch';

class CustomProfileSettingPage extends StatefulWidget {
  const CustomProfileSettingPage({Key? key}) : super(key: key);

  @override
  State<CustomProfileSettingPage> createState() =>
      _CustomProfileSettingPageState();
}

class _CustomProfileSettingPageState extends State<CustomProfileSettingPage> {
  final CustomTabbarController controller = Get.find();
  final LocaleService localeService = Get.find();
  GalleryListType _listType = GalleryListType.gallery;
  late CustomProfile customProfile;
  late int oriIndex;

  late final CustomSubListController subController;

  late ListModeEnum listMode;

  bool enableAdvance = false;

  bool hideTab = false;

  bool searchGalleryName = true;
  bool searchGalleryTags = true;
  bool searchGalleryDesc = false;
  bool searchToreenFilenames = false;
  bool onlyShowWhithTorrents = false;
  bool searchLowPowerTags = false;
  bool searchDownvotedTags = false;
  bool searchExpunged = false;
  bool searchWithminRating = false;
  int minRating = 2;
  bool searchBetweenpage = false;
  String? startPage;
  String? endPage;
  bool disableDFLanguage = false;
  bool disableDFUploader = false;
  bool disableDFTags = false;

  List<String> searchTextList = <String>[];
  // List<String> aggGroupList = <String>[];

  final textController = TextEditingController();
  String lastText = '';
  final ProfileEditController profileEditController =
      Get.put(ProfileEditController());

  // 保存配置
  void _saveProfile() {
    if (customProfile.name.trim().isEmpty) {
      showToast('Name is empty');
      return;
    }

    logger.d('searchWithminRating $searchWithminRating $minRating');

    customProfile = customProfile.copyWith(
      enableAdvance: enableAdvance,
      searchText: searchTextList,
      listModeValue: listMode.name,
      hideTab: hideTab,
      // aggregateGroups: aggGroupList,
      lastEditTime: DateTime.now().millisecondsSinceEpoch,
      advSearch: customProfile.advSearch?.copyWith(
            searchGalleryName: searchGalleryName,
            searchGalleryTags: searchGalleryTags,
            searchGalleryDesc: searchGalleryDesc,
            searchToreenFilenames: searchToreenFilenames,
            onlyShowWhithTorrents: onlyShowWhithTorrents,
            searchLowPowerTags: searchLowPowerTags,
            searchDownvotedTags: searchDownvotedTags,
            searchExpunged: searchExpunged,
            searchWithminRating: searchWithminRating,
            minRating: minRating,
            searchBetweenpage: searchBetweenpage,
            startPage: startPage,
            endPage: endPage,
            disableDFLanguage: disableDFLanguage,
            disableDFUploader: disableDFUploader,
            disableDFTags: disableDFTags,
          ) ??
          AdvanceSearch(
            searchGalleryName: searchGalleryName,
            searchGalleryTags: searchGalleryTags,
            searchGalleryDesc: searchGalleryDesc,
            searchToreenFilenames: searchToreenFilenames,
            onlyShowWhithTorrents: onlyShowWhithTorrents,
            searchLowPowerTags: searchLowPowerTags,
            searchDownvotedTags: searchDownvotedTags,
            searchExpunged: searchExpunged,
            searchWithminRating: searchWithminRating,
            minRating: minRating,
            searchBetweenpage: searchBetweenpage,
            startPage: startPage ?? '',
            endPage: endPage ?? '',
            disableDFLanguage: disableDFLanguage,
            disableDFUploader: disableDFUploader,
            disableDFTags: disableDFTags,
            favSearchName: true,
            favSearchTags: true,
            favSearchNote: true,
          ),
    );

    logger.d(' ${jsonEncode(customProfile)}');

    if (oriIndex >= 0) {
      // 修改profile
      controller.profiles[oriIndex] = customProfile;
    } else {
      // 新增profile
      logger.d('new profile ${customProfile.name}');
      controller.profiles.add(customProfile);
    }

    Get.lazyPut(
      () => CustomSubListController(profileUuid: customProfile.uuid)
        ..heroTag = customProfile.uuid,
      tag: customProfile.uuid,
      fenix: true,
    );

    subController = Get.find(tag: customProfile.uuid);
    subController.listMode = listMode;
  }

  @override
  void initState() {
    super.initState();

    customProfile = Get.find();

    // profile 下标
    oriIndex = controller.profiles
        .indexWhere((element) => element.uuid == customProfile.uuid);

    searchTextList.addAll(customProfile.searchText?.map((e) => '$e') ?? []);

    // aggGroupList.addAll(customProfile.aggregateGroups ?? []);

    _listType = customProfile.listType;
    enableAdvance = customProfile.enableAdvance ?? enableAdvance;

    hideTab = customProfile.hideTab ?? hideTab;

    listMode = customProfile.listMode;

    searchGalleryTags =
        customProfile.advSearch?.searchGalleryTags ?? searchGalleryTags;
    searchGalleryDesc =
        customProfile.advSearch?.searchGalleryDesc ?? searchGalleryDesc;
    searchToreenFilenames =
        customProfile.advSearch?.searchToreenFilenames ?? searchToreenFilenames;
    onlyShowWhithTorrents =
        customProfile.advSearch?.onlyShowWhithTorrents ?? onlyShowWhithTorrents;
    searchLowPowerTags =
        customProfile.advSearch?.searchLowPowerTags ?? searchLowPowerTags;
    searchDownvotedTags =
        customProfile.advSearch?.searchDownvotedTags ?? searchDownvotedTags;
    searchExpunged = customProfile.advSearch?.searchExpunged ?? searchExpunged;
    searchWithminRating =
        customProfile.advSearch?.searchWithminRating ?? searchWithminRating;
    minRating = customProfile.advSearch?.minRating ?? minRating;
    searchBetweenpage =
        customProfile.advSearch?.searchBetweenpage ?? searchBetweenpage;
    startPage = customProfile.advSearch?.startPage ?? startPage;
    endPage = customProfile.advSearch?.endPage ?? endPage;
    disableDFLanguage =
        customProfile.advSearch?.disableDFLanguage ?? disableDFLanguage;
    disableDFUploader =
        customProfile.advSearch?.disableDFUploader ?? disableDFUploader;
    disableDFTags = customProfile.advSearch?.disableDFTags ?? disableDFTags;
  }

  Future<void> showSearchAttach(
      String input, BuildContext targetContext) async {
    const _marginLR = 30.0;

    final robj = targetContext.findRenderObject() as RenderBox?;
    final size = robj?.size;

    final textStyle = TextStyle(
      fontSize: 16,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );

    final translateStyle = TextStyle(
      fontSize: 14,
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondaryLabel, context),
    );

    final highLightTextStyle = TextStyle(
      fontSize: 16,
      color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context),
    );

    final highLightTranslateStyle = TextStyle(
      fontSize: 14,
      color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context),
    );

    await SmartDialog.showAttach(
      tag: kAttachTagSearch,
      targetContext: targetContext,
      onDismiss: () {
        lastText = '';
      },
      builder: (BuildContext context) {
        return SafeArea(
          top: false,
          bottom: false,
          child: Container(
            width: size?.width,
            margin: const EdgeInsets.only(
                left: _marginLR - 10, right: _marginLR, top: 10, bottom: 40),
            constraints: const BoxConstraints(maxHeight: 300, minHeight: 50),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: CupertinoDynamicColor.resolve(
                          CupertinoColors.darkBackgroundGray, Get.context!)
                      .withOpacity(0.16),
                  offset: const Offset(0, 16),
                  blurRadius: 20, //阴影模糊程度
                  spreadRadius: 2, //阴影扩散程度
                ),
              ],
            ),
            // color: CupertinoColors.systemGrey5,
            child: CupertinoPopupSurface(
              child: CupertinoScrollbar(
                // isAlwaysShown: true,
                child: Container(
                  // child: SizedBox(),
                  child: Obx(() {
                    final _rultlist = profileEditController.rultlist;
                    return ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        final _trans = _rultlist[index];

                        final input = profileEditController.searchText;
                        final text = _trans.fullTagText;
                        final translate = _trans.fullTagTranslate;

                        final textSpans = text
                            ?.split(input)
                            .map((e) => TextSpan(
                                  text: e,
                                  style: textStyle,
                                ))
                            .separat(
                                separator: TextSpan(
                              text: input,
                              style: highLightTextStyle,
                            ));

                        final translateTextSpans = translate
                            ?.split(input)
                            .map((e) => TextSpan(
                                  text: e,
                                  style: translateStyle,
                                ))
                            .separat(
                                separator: TextSpan(
                              text: input,
                              style: highLightTranslateStyle,
                            ));

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => profileEditController.selectItem(
                            index,
                            searchTextController: textController,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: textSpans,
                                ),
                              ),
                              if (translate != null) const SizedBox(height: 6),
                              if (translate != null &&
                                  profileEditController.isTagTranslat)
                                RichText(
                                  text: TextSpan(
                                    children: translateTextSpans,
                                  ),
                                ),
                            ],
                          ).paddingSymmetric(vertical: 8),
                        );
                      },
                      itemCount: _rultlist.length,
                    );
                  }),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _getTextTranslate(String text) async {
    final String? tranText =
        await Get.find<TagTransController>().getTranTagWithNameSpaseAuto(text);
    if (tranText?.trim() != text) {
      return tranText;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final _style = TextStyle(
      color: CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
    );

    const segmentedPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 4);
    const segmentedTextStyle = TextStyle(height: 1.1);

    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      navigationBar: buildCupertinoNavigationBar(_style),
      child: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              children: [
                // 分组名称编辑
                GroupItem(
                  title: L10n.of(context).groupName,
                  child: TextInputItem(
                    textFieldPadding: const EdgeInsets.fromLTRB(0, 6, 6, 6),
                    initValue: customProfile.name,
                    maxLines: null,
                    textAlign: TextAlign.left,
                    hideLine: true,
                    onChanged: (value) {
                      logger.d('onChanged name value $value');
                      customProfile = customProfile.copyWith(
                          name: value.replaceAll('\n', '').trim());
                    },
                    placeholder: L10n.of(context).groupName,
                  ),
                ),
                // 隐藏分组
                //GroupItem(
                //  child: TextSwitchItem(
                //    L10n.of(context).hide,
                //    intValue: hideTab,
                //    onChanged: (val) {
                //      setState(() {
                //        hideTab = val;
                //      });
                //    },
                //    hideLine: true,
                //  ),
                //),
                // 列表样式设置
                GroupItem(
                  child: _buildListModeItem(context, hideLine: true),
                ),
                // 列表类型设置：热门，画廊，关注，聚合
                GroupItem(
                  title: L10n.of(context).groupType,
                  child: Container(
                    width: double.infinity,
                    color: CupertinoDynamicColor.resolve(
                        ehTheme.itemBackgroundColor!, Get.context!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      constraints: const BoxConstraints(
                        minHeight: kItemHeight,
                      ),
                      child: CupertinoSlidingSegmentedControl<GalleryListType>(
                        children: <GalleryListType, Widget>{
                          GalleryListType.popular: Container(
                            child: Text(
                              L10n.of(context).tab_popular,
                              style: segmentedTextStyle,
                            ),
                            padding: segmentedPadding,
                            // constraints: BoxConstraints(minWidth: 10),
                          ),
                          GalleryListType.gallery: Container(
                            child: Text(
                              L10n.of(context).tab_gallery,
                              style: segmentedTextStyle,
                            ),
                            padding: segmentedPadding,
                            // constraints: BoxConstraints(minWidth: 10),
                          ),
                          GalleryListType.watched: Container(
                            child: Text(
                              L10n.of(context).tab_watched,
                              style: segmentedTextStyle,
                            ),
                            padding: segmentedPadding,
                            // constraints: BoxConstraints(minWidth: 10),
                          ),
                          // if (!kReleaseMode)
                          //   GalleryListType.aggregate: Container(
                          //     child: Text(L10n.of(context).aggregate),
                          //     // constraints: BoxConstraints(minWidth: 10),
                          //   ),
                        },
                        groupValue: _listType,
                        onValueChanged: (GalleryListType? value) {
                          customProfile = customProfile.copyWith(
                              listTypeValue:
                                  value?.name ?? GalleryListType.gallery.name);
                          setState(() {
                            _listType = value ?? GalleryListType.gallery;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                // 搜索选项：关键词 类型 高级搜索，popular时隐藏, 聚合时显示聚合选项
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  // secondChild: buildSearchOption(context),
                  secondChild: AnimatedCrossFade(
                    firstChild: buildAggregateOption(context),
                    secondChild: buildSearchOption(context),
                    crossFadeState: _listType != GalleryListType.aggregate
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: 300.milliseconds,
                  ),
                  crossFadeState: _listType != GalleryListType.popular
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: 300.milliseconds,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 聚合搜索设置
  Widget buildAggregateOption(BuildContext context) {
    // return SizedBox(width: double.infinity);
    List<CustomProfile> profiles = controller.profiles
        .where((p) =>
            p.listType != GalleryListType.aggregate &&
            p.uuid != customProfile.uuid)
        .toList();
    return GroupItem(
      title: L10n.of(context).aggregate_groups,
      child: Container(
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return TextSwitchItem(
              profile.name,
              intValue: customProfile.aggregateGroups
                  ?.any((element) => element.trim() == profile.uuid),
              onChanged: (val) {
                logger.d('${profile.uuid} $val');
                if (val) {
                  customProfile.aggregateGroups?.add(profile.uuid);
                } else {
                  customProfile.aggregateGroups?.removeWhere(
                      (element) => element.trim() == profile.uuid);
                }
              },
            );
          },
          itemCount: profiles.length,
        ),
      ),
    );
  }

  /// 列表模式切换
  Widget _buildListModeItem(BuildContext context, {bool hideLine = false}) {
    final String _title = L10n.of(context).list_mode;

    final Map<ListModeEnum, String> modeMap = <ListModeEnum, String>{
      ListModeEnum.global: L10n.of(context).global_setting,
      ListModeEnum.list: L10n.of(context).listmode_medium,
      ListModeEnum.simpleList: L10n.of(context).listmode_small,
      ListModeEnum.waterfall: L10n.of(context).listmode_waterfall,
      ListModeEnum.waterfallLarge: L10n.of(context).listmode_waterfall_large,
      ListModeEnum.grid: L10n.of(context).listmode_grid,
      if (kDebugMode || Get.find<EhConfigService>().debugMode)
        ListModeEnum.debugSimple: 'debugSimple',
    };
    return SelectorItem<ListModeEnum>(
      title: _title,
      hideDivider: hideLine,
      actionMap: modeMap,
      initVal: listMode,
      onValueChanged: (val) {
        setState(() {
          listMode = val;
        });
      },
    );
  }

  Widget buildSearchOption(BuildContext context) {
    return Column(
      children: [
        // 设置搜索关键词
        GroupItem(
          title: L10n.of(context).searchTexts,
          child: Column(
            children: [
              // 关键词列表
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: searchTextList.length,
                itemBuilder: (context, index) {
                  final element = searchTextList[index];
                  return Slidable(
                      child: profileEditController.isTagTranslat
                          ? FutureBuilder<String?>(
                              future: _getTextTranslate(element),
                              initialData: element,
                              builder: (context, snapshot) {
                                return BarsItem(
                                  title: element,
                                  maxLines: 3,
                                  titleSize: 16,
                                  desc: snapshot.data,
                                  key: ValueKey(index),
                                );
                              })
                          : BarsItem(
                              title: element,
                              key: ValueKey(index),
                            ),
                      endActionPane: ActionPane(
                        extentRatio: 0.25,
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              setState(() {
                                searchTextList.removeAt(index);
                              });
                            },
                            backgroundColor: CupertinoDynamicColor.resolve(
                                CupertinoColors.systemRed, context),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          ),
                        ],
                      ));
                },
              ),
              // 新关键词编辑栏
              Container(
                color: CupertinoDynamicColor.resolve(
                    ehTheme.itemBackgroundColor!, Get.context!),
                constraints: const BoxConstraints(minHeight: kItemHeight),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Builder(builder: (context) {
                  return Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          decoration: null,
                          controller: textController,
                          placeholder: L10n.of(context).newText,
                          placeholderStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: CupertinoColors.placeholderText,
                            height: 1.25,
                          ),
                          style: const TextStyle(height: 1.2),
                          onChanged: (value) {
                            profileEditController.searchText = value.trim();
                            if (lastText.isEmpty && value.isNotEmpty) {
                              showSearchAttach(value, context);
                            }
                            if (value.trim().isEmpty) {
                              SmartDialog.dismiss();
                            }

                            lastText = value.trim();
                          },
                        ),
                      ),
                      // 添加为新的条件组
                      // CupertinoTheme(
                      //   data: const CupertinoThemeData(
                      //     primaryColor: CupertinoColors.activeGreen,
                      //   ),
                      //   child: CupertinoButton(
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 4, vertical: 8),
                      //     minSize: 0,
                      //     child: const Icon(
                      //       CupertinoIcons.rectangle_stack_fill_badge_plus,
                      //       size: 30,
                      //     ),
                      //     onPressed: () {
                      //       // setState(() {
                      //       //   searchText.add(textController.text.trim());
                      //       //   textController.clear();
                      //       // });
                      //     },
                      //   ),
                      // ),
                      // 添加到当前条件组
                      CupertinoTheme(
                        data: const CupertinoThemeData(
                          primaryColor: CupertinoColors.activeGreen,
                        ),
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          minSize: 0,
                          child: const Icon(
                            FontAwesomeIcons.circlePlus,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              searchTextList.add(textController.text.trim());
                              textController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),

        // 类型筛选器
        GroupItem(
          child: Container(
            color: CupertinoDynamicColor.resolve(
                ehTheme.itemBackgroundColor!, Get.context!),
            child: Column(
              children: [
                GalleryCatFilter(
                  catNum: customProfile.cats ?? 0,
                  maxCrossAxisExtent: 150,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  onCatNumChanged: (int value) {
                    logger.d('onCatNumChanged $value');
                    customProfile = customProfile.copyWith(cats: value);
                  },
                ),
              ],
            ),
          ),
        ),

        // 高级搜索选项开关
        GroupItem(
          child: TextSwitchItem(
            L10n.of(context).s_Advanced_Options,
            intValue: enableAdvance,
            onChanged: (val) {
              setState(() {
                enableAdvance = val;
              });
            },
            hideDivider: true,
          ),
        ),

        // 高级搜索选项
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: buildAdvancedOptions(context),
          crossFadeState: enableAdvance
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: 300.milliseconds,
        ),
      ],
    );
  }

  Widget buildAdvancedOptions(BuildContext context) {
    return Column(
      children: [
        GroupItem(
          child: Column(
            children: [
              Column(
                children: [
                  TextSwitchItem(
                    L10n.of(context).s_Search_Gallery_Name,
                    intValue: searchGalleryName,
                    onChanged: (val) => searchGalleryName = val,
                  ),
                  TextSwitchItem(
                    L10n.of(context).s_Search_Gallery_Tags,
                    intValue: searchGalleryTags,
                    onChanged: (val) => searchGalleryTags = val,
                  ),
                  TextSwitchItem(
                    L10n.of(context).s_Search_Gallery_Description,
                    intValue: searchGalleryDesc,
                    onChanged: (val) => searchGalleryDesc = val,
                  ),
                  TextSwitchItem(
                    L10n.of(context).s_Search_Torrent_Filenames,
                    intValue: searchToreenFilenames,
                    onChanged: (val) => searchToreenFilenames = val,
                  ),
                  TextSwitchItem(
                    L10n.of(context).s_Only_Show_Galleries_With_Torrents,
                    intValue: onlyShowWhithTorrents,
                    onChanged: (val) => onlyShowWhithTorrents = val,
                  ),
                  TextSwitchItem(
                    L10n.of(context).s_Search_Low_Power_Tags,
                    intValue: searchLowPowerTags,
                    onChanged: (val) => searchLowPowerTags = val,
                  ),
                  TextSwitchItem(
                    L10n.of(context).s_Search_Downvoted_Tags,
                    intValue: searchDownvotedTags,
                    onChanged: (val) => searchDownvotedTags = val,
                  ),
                  TextSwitchItem(
                    L10n.of(context).s_Show_Expunged_Galleries,
                    intValue: searchExpunged,
                    onChanged: (val) => searchExpunged = val,
                  ),
                  buildSearchWithminRating(context),
                ],
              ).autoCompressKeyboard(context),
              buildSearchBetweenpage(context),
            ],
          ),
        ),
        GroupItem(
          title: L10n.of(context).s_Disable_default_filters,
          child: Column(
            children: [
              TextSwitchItem(
                L10n.of(context).language,
                intValue: disableDFLanguage,
                onChanged: (val) => disableDFLanguage = val,
              ),
              TextSwitchItem(
                L10n.of(context).uploader,
                intValue: disableDFUploader,
                onChanged: (val) => disableDFUploader = val,
              ),
              TextSwitchItem(
                L10n.of(context).tags,
                intValue: disableDFTags,
                onChanged: (val) => disableDFTags = val,
              ),
            ],
          ).autoCompressKeyboard(context),
        ),
      ],
    );
  }

  /// 设置最低评分
  Widget buildSearchWithminRating(BuildContext context) {
    return Column(
      children: [
        TextSwitchItem(
          L10n.of(context).s_Minimum_Rating,
          intValue: searchWithminRating,
          onChanged: (val) {
            setState(() {
              searchWithminRating = val;
            });
          },
        ),
        AnimatedContainer(
          curve: Curves.ease,
          duration: 300.milliseconds,
          width: double.infinity,
          height: searchWithminRating ? kItemHeight : 0,
          // height: kItemHeight,
          color: CupertinoDynamicColor.resolve(
              ehTheme.itemBackgroundColor!, Get.context!),
          child: SingleChildScrollView(
            child: AnimatedCrossFade(
              sizeCurve: Curves.ease,
              firstCurve: Curves.ease,
              secondCurve: Curves.ease,
              duration: 300.milliseconds,
              crossFadeState: searchWithminRating
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              secondChild: const SizedBox.shrink(),
              firstChild: Container(
                height: kItemHeight,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        width: double.infinity,
                        child: CupertinoSlidingSegmentedControl<int>(
                          children: <int, Widget>{
                            2: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(L10n.of(context).s_stars('2')),
                            ),
                            3: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(L10n.of(context).s_stars('3')),
                            ),
                            4: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(L10n.of(context).s_stars('4')),
                            ),
                            5: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(L10n.of(context).s_stars('5')),
                            ),
                          },
                          groupValue: minRating,
                          onValueChanged: (int? value) {
                            setState(() {
                              minRating = value ?? 2;
                            });
                          },
                        ),
                      ),
                    ),
                    Divider(
                      indent: 20,
                      height: 0.6,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey4, context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 页码范围
  Widget buildSearchBetweenpage(BuildContext context) {
    return Container(
      color: CupertinoDynamicColor.resolve(
          ehTheme.itemBackgroundColor!, Get.context!),
      child: Row(
        children: [
          Expanded(
            child: TextSwitchItem(
              L10n.of(context).s_pages,
              intValue: searchBetweenpage,
              onChanged: (val) {
                setState(() {
                  searchBetweenpage = val;
                });
              },
            ),
          ),
          // 最小页码
          Container(
            margin: const EdgeInsets.only(right: 4),
            width: 70,
            height: kItemHeight - 18,
            child: CupertinoTextField(
                decoration: BoxDecoration(
                  color: ehTheme.textFieldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                keyboardType: TextInputType.number,
                // cursorHeight: 14,
                enabled: searchBetweenpage,
                style: const TextStyle(
                  height: 1.2,
                  textBaseline: TextBaseline.alphabetic,
                ),
                onChanged: (val) => startPage = val,
                // controller: TextEditingController(text: startPage),
                controller: TextEditingController()
                  ..value = TextEditingValue(
                    text: startPage ?? '',
                    selection: TextSelection.fromPosition(
                      TextPosition(
                        affinity: TextAffinity.downstream,
                        offset: (startPage ?? '').length,
                      ),
                    ),
                  )),
          ),
          Text(L10n.of(context).s_and),
          // 最大页码
          Container(
            margin: const EdgeInsets.only(left: 4, right: 20),
            width: 70,
            height: kItemHeight - 18,
            child: CupertinoTextField(
              decoration: BoxDecoration(
                color: ehTheme.textFieldBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              keyboardType: TextInputType.number,
              // cursorHeight: 14,
              enabled: searchBetweenpage,
              style: const TextStyle(
                height: 1.2,
                textBaseline: TextBaseline.alphabetic,
              ),
              onChanged: (val) => endPage = val,
              controller: TextEditingController()
                ..value = TextEditingValue(
                  text: endPage ?? '',
                  selection: TextSelection.fromPosition(
                    TextPosition(
                      affinity: TextAffinity.downstream,
                      offset: (endPage ?? '').length,
                    ),
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }

  CupertinoNavigationBar buildCupertinoNavigationBar(TextStyle _style) {
    return CupertinoNavigationBar(
      trailing: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());

          _saveProfile();

          Get.back(
            id: isLayoutLarge ? 2 : null,
          );
        },
        child: Text(
          L10n.of(context).done,
          style: _style,
        ),
      ),
    );
  }
}
