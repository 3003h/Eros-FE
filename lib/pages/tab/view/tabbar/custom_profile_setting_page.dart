import 'dart:convert';

import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:fehviewer/pages/tab/controller/group/custom_tabbar_controller.dart';
import 'package:fehviewer/pages/tab/fetch_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

const kSegmentedPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 4);
const kSegmentedTextStyle = TextStyle(height: 1.1, fontSize: 14);

class CustomProfileSettingPage extends StatefulWidget {
  const CustomProfileSettingPage({super.key});

  @override
  State<CustomProfileSettingPage> createState() =>
      _CustomProfileSettingPageState();
}

class _CustomProfileSettingPageState extends State<CustomProfileSettingPage> {
  CustomTabbarController get controller => Get.find();

  LocaleService get localeService => Get.find();

  final _searchWithMinRating = false.obs;
  final _searchBetweenPage = false.obs;
  final _enableAdvance = false.obs;

  late CustomProfile _customProfile;

  @override
  void initState() {
    super.initState();

    _customProfile = Get.arguments is CustomProfile
        ? Get.arguments as CustomProfile
        : CustomProfile(name: '', uuid: generateUuidv4());

    _searchWithMinRating.value =
        _customProfile.advSearch?.searchWithMinRating ?? false;
    _searchBetweenPage.value =
        _customProfile.advSearch?.searchBetweenPage ?? false;
    _enableAdvance.value = _customProfile.enableAdvance ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          minSize: 40,
          child: const Icon(
            CupertinoIcons.check_mark_circled,
            size: 28,
          ),
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            logger.d('_customProfile ${jsonEncode(_customProfile)}');

            if (_customProfile.name.trim().isEmpty) {
              showToast('Name is empty');
              return;
            }

            Get.back(
              id: isLayoutLarge ? 2 : null,
              result: _customProfile.copyWith(
                lastEditTime: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          },
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: buildCustomProfileEditView(),
          ),
        ],
      ),
    );
  }

  Widget buildCustomProfileEditView() {
    List<Widget> _slivers = [
      SliverCupertinoListSection.listInsetGrouped(children: [
        CupertinoTextInputListTile(
          title: L10n.of(context).groupName,
          initValue: _customProfile.name,
          onChanged: (String val) {
            _customProfile = _customProfile.copyWith(name: val);
          },
        )
      ]),

      //
      SliverCupertinoListSection.listInsetGrouped(children: [
        _buildListModeItem(
          context,
          listMode: _customProfile.listMode,
          onValueChanged: (ListModeEnum val) {
            _customProfile = _customProfile.copyWith(listModeValue: val.name);
          },
        ),
      ]),

      //
      SliverCupertinoListSection.listInsetGrouped(
          header: Text(L10n.of(context).groupType),
          children: [
            _ListTypeSelector(
              initValue: _customProfile.listType,
              onChanged: (GalleryListType value) {
                _customProfile =
                    _customProfile.copyWith(listTypeValue: value.name);
              },
            ),
          ]),

      //
      SliverCupertinoListSection.listInsetGrouped(children: [
        GalleryCatFilter(
          catNum: _customProfile.cats ?? 0,
          maxCrossAxisExtent: 150,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          onCatNumChanged: (int value) {
            logger.d('onCatNumChanged $value');
            _customProfile = _customProfile.copyWith(cats: value);
          },
        ),
      ]),

      // 高级选项开关
      SliverCupertinoListSection.listInsetGrouped(children: [
        // switch s_Advanced_Options
        EhCupertinoListTile(
          title: Text(L10n.of(context).s_Advanced_Options),
          trailing: StatefulBuilder(builder: (context, setState) {
            return CupertinoSwitch(
              value: _customProfile.enableAdvance ?? false,
              onChanged: (val) {
                _enableAdvance.value = val;
                _customProfile = _customProfile.copyWith(enableAdvance: val);
                setState(() {});
              },
            );
          }),
        ),
      ]),
    ];

    return SliverAnimatedPaintExtent(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: MultiSliver(
        children: [
          MultiSliver(children: _slivers),
          Obx(
            () {
              if (_enableAdvance.value) {
                return _buildAdvanceView();
              } else {
                return const SizedBox(width: double.infinity);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanceView() {
    return MultiSliver(
      children: [
        SliverCupertinoListSection.listInsetGrouped(
          children: [
            // s_Only_Show_Galleries_With_Torrents switch
            EhCupertinoListTile(
              title: Text(L10n.of(context).s_Only_Show_Galleries_With_Torrents),
              trailing: StatefulBuilder(builder: (context, setState) {
                return CupertinoSwitch(
                  value:
                      _customProfile.advSearch?.requireGalleryTorrent ?? false,
                  onChanged: (val) {
                    _customProfile = _customProfile.copyWith(
                        advSearch: _customProfile.advSearch
                            ?.copyWith(requireGalleryTorrent: val));
                    setState(() {});
                  },
                );
              }),
            ),

            // s_Show_Expunged_Galleries switch
            CupertinoListTile(
              title: Text(L10n.of(context).s_Show_Expunged_Galleries),
              trailing: StatefulBuilder(builder: (context, setState) {
                return CupertinoSwitch(
                  value: _customProfile.advSearch?.browseExpungedGalleries ??
                      false,
                  onChanged: (val) {
                    _customProfile = _customProfile.copyWith(
                        advSearch: _customProfile.advSearch
                            ?.copyWith(browseExpungedGalleries: val));
                    setState(() {});
                  },
                );
              }),
            ),
          ],
        ),

        SliverCupertinoListSection.listInsetGrouped(
          children: [
            // s_Minimum_Rating switch
            Column(
              children: [
                CupertinoListTile(
                  title: Text(L10n.of(context).s_Minimum_Rating),
                  trailing: StatefulBuilder(builder: (context, setState) {
                    return CupertinoSwitch(
                      value: _customProfile.advSearch?.searchWithMinRating ??
                          false,
                      onChanged: (val) {
                        _customProfile = _customProfile.copyWith(
                            advSearch: _customProfile.advSearch
                                ?.copyWith(searchWithMinRating: val));

                        // update obs
                        _searchWithMinRating.value = val;

                        setState(() {});
                      },
                    );
                  }),
                ),
                Obx(() {
                  return AnimatedCrossFade(
                    firstCurve: Curves.easeIn,
                    secondCurve: Curves.easeOut,
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: _MinRatingSelector(
                      initValue: _customProfile.advSearch?.minRating ?? 2,
                      onChanged: (int value) {
                        _customProfile = _customProfile.copyWith(
                            advSearch: _customProfile.advSearch?.copyWith(
                                minRating: value == 2 ? null : value));
                      },
                    ),
                    crossFadeState: _searchWithMinRating.value
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  );
                }),
              ],
            ),
          ],
        ),

        //
        SliverCupertinoListSection.listInsetGrouped(
          children: [
            Column(
              children: [
                // searchBetweenPage switch
                CupertinoListTile(
                  title: Text(L10n.of(context).s_pages),
                  trailing: StatefulBuilder(builder: (context, setState) {
                    return CupertinoSwitch(
                      value:
                          _customProfile.advSearch?.searchBetweenPage ?? false,
                      onChanged: (val) {
                        _customProfile = _customProfile.copyWith(
                            advSearch: _customProfile.advSearch
                                ?.copyWith(searchBetweenPage: val));
                        //
                        _searchBetweenPage.value = val;

                        setState(() {});
                      },
                    );
                  }),
                ),

                Obx(() {
                  return AnimatedCrossFade(
                    crossFadeState: _searchBetweenPage.value
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                    firstCurve: Curves.easeIn,
                    secondCurve: Curves.easeOut,
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: _BetweenPageTile(
                      enable:
                          _customProfile.advSearch?.searchBetweenPage ?? false,
                      startPage: _customProfile.advSearch?.startPage,
                      endPage: _customProfile.advSearch?.endPage,
                      onStartPageChanged: (val) {
                        _customProfile = _customProfile.copyWith(
                            advSearch: _customProfile.advSearch?.copyWith(
                                startPage: val.isEmpty ? null : val));
                      },
                      onEndPageChanged: (val) {
                        _customProfile = _customProfile.copyWith(
                            advSearch: _customProfile.advSearch
                                ?.copyWith(endPage: val.isEmpty ? null : val));
                      },
                    ),
                  );
                }),
              ],
            ),
          ],
        ),

        //
        SliverCupertinoListSection.listInsetGrouped(
          header: Text(L10n.of(context).s_Disable_default_filters),
          children: [
            // disableCustomFilterLanguage switch
            CupertinoListTile(
              title: Text(L10n.of(context).language),
              trailing: StatefulBuilder(builder: (context, setState) {
                return CupertinoSwitch(
                  value:
                      _customProfile.advSearch?.disableCustomFilterLanguage ??
                          false,
                  onChanged: (val) {
                    _customProfile = _customProfile.copyWith(
                        advSearch: _customProfile.advSearch
                            ?.copyWith(disableCustomFilterLanguage: val));
                    setState(() {});
                  },
                );
              }),
            ),

            // disableCustomFilterUploader switch
            CupertinoListTile(
              title: Text(L10n.of(context).uploader),
              trailing: StatefulBuilder(builder: (context, setState) {
                return CupertinoSwitch(
                  value:
                      _customProfile.advSearch?.disableCustomFilterUploader ??
                          false,
                  onChanged: (val) {
                    _customProfile = _customProfile.copyWith(
                        advSearch: _customProfile.advSearch
                            ?.copyWith(disableCustomFilterUploader: val));
                    setState(() {});
                  },
                );
              }),
            ),

            // disableCustomFilterTags switch
            CupertinoListTile(
              title: Text(L10n.of(context).tags),
              trailing: StatefulBuilder(builder: (context, setState) {
                return CupertinoSwitch(
                  value: _customProfile.advSearch?.disableCustomFilterTags ??
                      false,
                  onChanged: (val) {
                    _customProfile = _customProfile.copyWith(
                        advSearch: _customProfile.advSearch
                            ?.copyWith(disableCustomFilterTags: val));
                    setState(() {});
                  },
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}

/// 列表模式切换
Widget _buildListModeItem(
  BuildContext context, {
  required ListModeEnum listMode,
  required ValueChanged<ListModeEnum> onValueChanged,
}) {
  final String _title = L10n.of(context).list_mode;

  final Map<ListModeEnum, String> modeMap = <ListModeEnum, String>{
    ListModeEnum.global: L10n.of(context).global_setting,
    ListModeEnum.list: L10n.of(context).listmode_medium,
    ListModeEnum.simpleList: L10n.of(context).listmode_small,
    ListModeEnum.waterfall: L10n.of(context).listmode_waterfall,
    ListModeEnum.waterfallLarge: L10n.of(context).listmode_waterfall_large,
    ListModeEnum.grid: L10n.of(context).listmode_grid,
    if (kDebugMode || Get.find<EhSettingService>().debugMode)
      ListModeEnum.debugSimple: 'debugSimple',
  };
  return SelectorCupertinoListTile<ListModeEnum>(
    title: _title,
    actionMap: modeMap,
    initVal: listMode,
    onValueChanged: onValueChanged,
  );
}

class _MinRatingSelector extends StatefulWidget {
  const _MinRatingSelector({super.key, this.onChanged, this.initValue});

  final ValueChanged<int>? onChanged;
  final int? initValue;

  @override
  State<_MinRatingSelector> createState() => _MinRatingSelectorState();
}

class _MinRatingSelectorState extends State<_MinRatingSelector> {
  int? _initValue;

  Widget _buildSlidingSegmentedAction(String title) {
    return Padding(
      child: Text(title),
      padding: kSegmentedPadding,
      // constraints: BoxConstraints(minWidth: 10),
    );
  }

  @override
  void initState() {
    super.initState();
    _initValue = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        constraints: const BoxConstraints(minHeight: kItemHeight),
        child: SafeArea(
          child: CupertinoSlidingSegmentedControl<int>(
            children: <int, Widget>{
              2: _buildSlidingSegmentedAction(L10n.of(context).s_stars('2')),
              3: _buildSlidingSegmentedAction(L10n.of(context).s_stars('3')),
              4: _buildSlidingSegmentedAction(L10n.of(context).s_stars('4')),
              5: _buildSlidingSegmentedAction(L10n.of(context).s_stars('5')),
            },
            groupValue: _initValue,
            onValueChanged: (int? value) {
              setState(() {
                _initValue = value;
              });
              widget.onChanged?.call(value!);
            },
          ),
        ),
      ),
    );
  }
}

class _ListTypeSelector extends StatefulWidget {
  const _ListTypeSelector({super.key, this.onChanged, this.initValue});

  final ValueChanged<GalleryListType>? onChanged;
  final GalleryListType? initValue;

  @override
  State<_ListTypeSelector> createState() => _ListTypeSelectorState();
}

class _ListTypeSelectorState extends State<_ListTypeSelector> {
  GalleryListType? _initValue;

  Widget _buildSlidingSegmentedAction(String title) {
    return Container(
      child: Text(
        title,
        style: kSegmentedTextStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
      padding: kSegmentedPadding,
      // constraints: BoxConstraints(minWidth: 10),
    );
  }

  @override
  void initState() {
    super.initState();
    _initValue = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        constraints: const BoxConstraints(minHeight: kItemHeight),
        child: SafeArea(
          child: CupertinoSlidingSegmentedControl<GalleryListType>(
            children: <GalleryListType, Widget>{
              GalleryListType.popular:
                  _buildSlidingSegmentedAction(L10n.of(context).tab_popular),
              GalleryListType.gallery:
                  _buildSlidingSegmentedAction(L10n.of(context).tab_gallery),
              GalleryListType.watched:
                  _buildSlidingSegmentedAction(L10n.of(context).tab_watched),
            },
            groupValue: _initValue,
            onValueChanged: (GalleryListType? value) {
              setState(() {
                _initValue = value;
              });
              widget.onChanged?.call(value!);
            },
          ),
        ),
      ),
    );
  }
}

class _BetweenPageTile extends StatelessWidget {
  const _BetweenPageTile({
    super.key,
    this.enable = false,
    this.startPage,
    this.endPage,
    this.onStartPageChanged,
    this.onEndPageChanged,
  });

  final bool enable;
  final String? startPage;
  final String? endPage;
  final ValueChanged<String>? onStartPageChanged;
  final ValueChanged<String>? onEndPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kItemHeight,
      padding: const EdgeInsetsDirectional.only(start: 20.0, end: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // start page
          Expanded(
            child: CupertinoTextField(
                keyboardType: TextInputType.number,
                // cursorHeight: 14,
                textAlign: TextAlign.center,
                enabled: enable,
                style: const TextStyle(
                  height: 1.2,
                  textBaseline: TextBaseline.alphabetic,
                ),
                onChanged: onStartPageChanged,
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(L10n.of(context).s_and),
          ),

          // end page
          Expanded(
            child: CupertinoTextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              // cursorHeight: 14,
              enabled: enable,
              style: const TextStyle(
                height: 1.2,
                textBaseline: TextBaseline.alphabetic,
              ),
              onChanged: onEndPageChanged,
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
}
