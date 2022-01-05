import 'dart:convert';

import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/filter/gallery_filter_view.dart';
import 'package:fehviewer/pages/tab/controller/custom_sublist_controller.dart';
import 'package:fehviewer/pages/tab/controller/custom_tabbar_controller.dart';
import 'package:fehviewer/pages/tab/controller/profile_edit_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

import '../../fetch_list.dart';

const String kAttachTagSearch = 'TagSearch';

class CustomProfileSettingView extends StatefulWidget {
  const CustomProfileSettingView({Key? key}) : super(key: key);

  @override
  State<CustomProfileSettingView> createState() =>
      _CustomProfileSettingViewState();
}

class _CustomProfileSettingViewState extends State<CustomProfileSettingView> {
  final CustomTabbarController controller = Get.find();
  final LocaleService localeService = Get.find();
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

  final textController = TextEditingController();
  String lastText = '';
  final ProfileEditController profileEditController =
      Get.put(ProfileEditController());

  void _saveProfile() {
    if (customProfile.name.trim().isEmpty) {
      showToast('Name is empty');
      return;
    }

    logger.d('searchWithminRating $searchWithminRating $minRating');

    customProfile = customProfile.copyWith(
      enableAdvance: enableAdvance,
      searchText: searchText,
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

    logger.d('${jsonEncode(customProfile)}');

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

  Future<void> showSearchAttach(
      String value, BuildContext targetContext) async {
    const _marginLR = 30.0;

    await SmartDialog.showAttach(
      tag: kAttachTagSearch,
      keepSingle: true,
      targetContext: targetContext,
      isPenetrateTemp: false,
      maskColorTemp: Colors.transparent,
      // isLoadingTemp: true,
      alignmentTemp: Alignment.bottomCenter,
      clickBgDismissTemp: true,
      onDismiss: () {
        lastText = '';
      },
      widget: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          width: targetContext.width - _marginLR * 2,
          margin: const EdgeInsets.only(
              left: _marginLR, right: _marginLR, top: 10, bottom: 40),
          constraints: const BoxConstraints(maxHeight: 300, minHeight: 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: CupertinoDynamicColor.resolve(
                        CupertinoColors.darkBackgroundGray, Get.context!)
                    .withOpacity(0.16),
                offset: const Offset(0, 10),
                blurRadius: 20, //阴影模糊程度
                spreadRadius: 4, //阴影扩散程度
              ),
            ],
          ),
          // color: CupertinoColors.systemGrey5,
          child: CupertinoPopupSurface(
            child: CupertinoScrollbar(
              // isAlwaysShown: true,
              child: Container(
                child: Obx(() {
                  final _rultlist = profileEditController.rultlist;
                  return ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (context, index) {
                      final _trans = _rultlist[index];
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
                            Text(_trans.fullTagText ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                )),
                            if (_trans.fullTagTranslate != null &&
                                profileEditController.isTagTranslat)
                              Text(
                                _trans.fullTagTranslate ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoDynamicColor.resolve(
                                      CupertinoColors.secondaryLabel,
                                      Get.context!),
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
      ),
    );
  }

  Future<String?> _getTextTranslate(String text) async {
    final String? tranText =
        await Get.find<TagTransController>().getTranTagWithNameSpaseSmart(text);
    if (tranText?.trim() != text) {
      return tranText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _style = TextStyle(
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
                GroupItem(
                  title: L10n.of(context).groupName,
                  child: TextInputItem(
                    // title: '分组名称',
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
                GroupItem(
                  title: L10n.of(context).groupType,
                  child: Container(
                    width: double.infinity,
                    color: CupertinoDynamicColor.resolve(
                        ehTheme.itemBackgroundColor!, Get.context!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      constraints: const BoxConstraints(
                        minHeight: kItemHeight,
                      ),
                      child: CupertinoSlidingSegmentedControl<GalleryListType>(
                        children: <GalleryListType, Widget>{
                          GalleryListType.popular:
                              Text(L10n.of(context).tab_popular)
                                  .marginSymmetric(horizontal: 8),
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
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: buildSearchOption(context),
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

  Widget buildSearchOption(BuildContext context) {
    return Column(
      children: [
        GroupItem(
          title: L10n.of(context).searchTexts,
          child: Column(
            children: [
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: searchText.length,
                  itemBuilder: (context, index) {
                    final element = searchText[index];
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
                                  searchText.removeAt(index);
                                });
                              },
                              backgroundColor: CupertinoDynamicColor.resolve(
                                  CupertinoColors.systemRed, context),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                            ),
                          ],
                        ));
                  }),
              Builder(builder: (context) {
                return Container(
                  color: CupertinoDynamicColor.resolve(
                      ehTheme.itemBackgroundColor!, Get.context!),
                  constraints: const BoxConstraints(minHeight: kItemHeight),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
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
                            profileEditController.searchText = value;
                            if (lastText.isEmpty && value.isNotEmpty) {
                              showSearchAttach(value, context);
                            }

                            if (value.isEmpty) {
                              SmartDialog.dismiss(tag: kAttachTagSearch);
                            }

                            lastText = value;
                          },
                        ),
                      ),
                      CupertinoTheme(
                        data: const CupertinoThemeData(
                          primaryColor: CupertinoColors.activeGreen,
                        ),
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          minSize: 0,
                          child: const Icon(
                            FontAwesomeIcons.solidCheckCircle,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              searchText.add(textController.text.trim());
                              textController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

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
                // Divider(
                //   indent: 20,
                //   height: 0.6,
                //   color: CupertinoDynamicColor.resolve(
                //       CupertinoColors.systemGrey4, context),
                // ),
              ],
            ),
          ),
        ),

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
