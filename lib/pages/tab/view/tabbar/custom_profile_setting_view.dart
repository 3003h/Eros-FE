import 'dart:convert';

import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/filter/gallery_filter_view.dart';
import 'package:fehviewer/pages/tab/controller/custom_sublist_controller.dart';
import 'package:fehviewer/pages/tab/controller/custom_tabbar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../fetch_list.dart';

class CustomProfileSettingView extends StatefulWidget {
  const CustomProfileSettingView({Key? key}) : super(key: key);

  @override
  State<CustomProfileSettingView> createState() =>
      _CustomProfileSettingViewState();
}

class _CustomProfileSettingViewState extends State<CustomProfileSettingView> {
  final CustomTabbarController controller = Get.find();
  GalleryListType _listType = GalleryListType.gallery;
  late CustomProfile customProfile;
  late int oriIndex;

  bool enableAdvance = false;

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

  List<String> searchText = <String>[];

  void _saveProfile() {
    if (customProfile.name.trim().isEmpty) {
      showToast('Name is empty');
      return;
    }

    logger.d('searchWithminRating $searchWithminRating $minRating');

    customProfile = customProfile.copyWith(
      enableAdvance: enableAdvance,
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

    // logger.d('${jsonEncode(customProfile)}');

    if (oriIndex >= 0) {
      controller.profiles[oriIndex] = customProfile;
    } else {
      logger.d('new profile ${customProfile.name}');
      controller.profiles.add(customProfile);
    }
    Get.lazyPut(
        () => CustomSubListController()
          ..profileUuid = customProfile.uuid
          ..heroTag = customProfile.uuid,
        tag: customProfile.uuid,
        fenix: true);
  }

  @override
  void initState() {
    super.initState();
    String? profileUuid = Get.arguments as String?;
    if (profileUuid != null) {
      customProfile = controller.profileMap[profileUuid] ??
          CustomProfile(name: '', uuid: generateUuidv4());
    } else {
      customProfile = CustomProfile(name: '', uuid: generateUuidv4());
    }
    oriIndex = controller.profiles
        .indexWhere((element) => element.uuid == profileUuid);

    searchText.addAll(customProfile.searchText?.map((e) => '$e') ?? []);

    _listType = customProfile.listType;
    enableAdvance = customProfile.enableAdvance ?? enableAdvance;

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

  @override
  Widget build(BuildContext context) {
    final _style = TextStyle(
      // height: 1,
      color: CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
    );

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
                TextInputItem(
                  title: '分组名称',
                  textFieldPadding: const EdgeInsets.fromLTRB(20, 6, 6, 6),
                  initValue: customProfile.name,
                  maxLines: null,
                  textAlign: TextAlign.left,
                  hideLine: true,
                  onChanged: (value) {
                    logger.d('onChanged name value $value');
                    customProfile = customProfile.copyWith(
                        name: value.replaceAll('\n', '').trim());
                  },
                ),
                GroupItem(
                  child: TextInputItem(
                    title: '关键词',
                    textFieldPadding: const EdgeInsets.fromLTRB(20, 6, 6, 6),
                    initValue: searchText.join('\n'),
                    maxLines: null,
                    textAlign: TextAlign.left,
                    hideLine: true,
                    onChanged: (value) {
                      customProfile = customProfile.copyWith(
                          searchText: value
                              .split('\n')
                              .where((element) => element.trim().isNotEmpty)
                              .toList());
                    },
                  ),
                ),

                GroupItem(
                  child: Column(
                    children: [
                      Container(
                        color: CupertinoDynamicColor.resolve(
                            ehTheme.itemBackgroundColor!, Get.context!),
                        child: Column(
                          children: [
                            GalleryCatFilter(
                              catNum: customProfile.cats ?? 0,
                              maxCrossAxisExtent: 150,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 20),
                              onCatNumChanged: (int value) {
                                logger.d('onCatNumChanged $value');
                                customProfile =
                                    customProfile.copyWith(cats: value);
                              },
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
                      Container(
                        color: CupertinoDynamicColor.resolve(
                            ehTheme.itemBackgroundColor!, Get.context!),
                        child: Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              constraints: const BoxConstraints(
                                minHeight: kItemHeight,
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text('列表类型'),
                                  ),
                                  CupertinoSlidingSegmentedControl<
                                      GalleryListType>(
                                    children: <GalleryListType, Widget>{
                                      GalleryListType.gallery:
                                          Text(L10n.of(context).tab_gallery)
                                              .marginSymmetric(horizontal: 8),
                                      GalleryListType.watched:
                                          Text(L10n.of(context).tab_watched)
                                              .marginSymmetric(horizontal: 8),
                                    },
                                    groupValue: _listType,
                                    onValueChanged: (GalleryListType? value) {
                                      customProfile = customProfile.copyWith(
                                          listTypeValue: value?.name ??
                                              GalleryListType.gallery.name);
                                      setState(() {
                                        _listType =
                                            value ?? GalleryListType.gallery;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Divider(
                            //   indent: 20,
                            //   height: 0.6,
                            //   color: CupertinoDynamicColor.resolve(
                            //       CupertinoColors.systemGrey4, context),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).autoCompressKeyboard(context),

                // 高级搜索
                GroupItem(
                  child: TextSwitchItem(
                    L10n.of(context).s_Advanced_Options,
                    intValue: enableAdvance,
                    onChanged: (val) {
                      setState(() {
                        enableAdvance = val;
                      });
                    },
                    hideLine: true,
                  ),
                ),

                // if (enableAdvance) buildAdvancedOptions(context),
                // Offstage(
                //   offstage: !enableAdvance,
                //   child: buildAdvancedOptions(context),
                // ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: buildAdvancedOptions(context),
                  crossFadeState: enableAdvance
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
        AnimatedCrossFade(
          alignment: Alignment.center,
          crossFadeState: searchWithminRating
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstCurve: Curves.easeIn,
          secondCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox(),
          secondChild: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: kItemHeight,
            ),
            // padding: const EdgeInsets.symmetric(horizontal: 20),
            color: CupertinoDynamicColor.resolve(
                ehTheme.itemBackgroundColor!, Get.context!),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: kItemHeight,
                  child: CupertinoSlidingSegmentedControl<int>(
                    children: <int, Widget>{
                      2: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(L10n.of(context).s_stars('2')),
                      ),
                      3: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(L10n.of(context).s_stars('3')),
                      ),
                      4: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(L10n.of(context).s_stars('4')),
                      ),
                      5: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
      ],
    );
  }

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
            ),
          ),
          Text(L10n.of(context).s_and),
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

          Get.back();
        },
        child: Text(
          '保存',
          style: _style,
        ),
      ),
    );
  }
}
