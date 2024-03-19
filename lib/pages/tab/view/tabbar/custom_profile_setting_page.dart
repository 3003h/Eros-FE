import 'dart:convert';

import 'package:eros_fe/common/controller/tag_trans_controller.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/common/service/locale_service.dart';
import 'package:eros_fe/component/setting_base.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/filter/filter.dart';
import 'package:eros_fe/pages/setting/setting_items/selector_Item.dart';
import 'package:eros_fe/pages/tab/controller/group/custom_tabbar_controller.dart';
import 'package:eros_fe/pages/tab/controller/group/profile_edit_controller.dart';
import 'package:eros_fe/pages/tab/fetch_list.dart';
import 'package:eros_fe/pages/tab/view/tabbar/search_text_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  final _listModeIsPopular = false.obs;

  late CustomProfile _customProfile;

  @override
  void initState() {
    super.initState();

    Get.put(ProfileEditController());

    logger.d('Get.arguments runtimeType ${Get.arguments.runtimeType}');

    // _customProfile = Get.arguments is CustomProfile
    //     ? Get.arguments as CustomProfile
    //     : CustomProfile(name: '', uuid: generateUuidv4());

    // arguments 方式不能跨栈传递，改回依赖注入
    _customProfile = Get.find<CustomProfile>();

    _searchWithMinRating.value =
        _customProfile.advSearch?.searchWithMinRating ?? false;
    _searchBetweenPage.value =
        _customProfile.advSearch?.searchBetweenPage ?? false;
    _enableAdvance.value = _customProfile.enableAdvance ?? false;

    _listModeIsPopular.value =
        _customProfile.listType == GalleryListType.popular;
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
                lastEditTime: DateTime.now().millisecondsSinceEpoch.oN,
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
    List<Widget> _mainTiles = [
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
            _customProfile =
                _customProfile.copyWith(listModeValue: val.name.oN);
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
                  _customProfile.copyWith(listTypeValue: value.name.oN);
              _listModeIsPopular.value = value == GalleryListType.popular;
            },
          ),
        ],
      ),
    ];

    List<Widget> _slivers = [
      //
      SliverCupertinoListSection.listInsetGrouped(children: [
        GalleryCatFilter(
          catNum: _customProfile.cats ?? 0,
          maxCrossAxisExtent: 150,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          onCatNumChanged: (int value) {
            logger.d('onCatNumChanged $value');
            _customProfile = _customProfile.copyWith(cats: value.oN);
          },
        ),
      ]),

      _SearchTextTile(
        searchTextList:
            _customProfile.searchText?.map((e) => '$e').toList() ?? [],
        onChanged: (List<String> val) {
          _customProfile = _customProfile.copyWith(searchText: val.oN);
        },
      ),

      // 高级选项开关
      SliverCupertinoListSection.listInsetGrouped(children: [
        // switch s_Advanced_Options
        Obx(() {
          // 使用 _enableAdvance obs 变量，避免和下发开关展开情况不同步
          return EhCupertinoSwitchListTile(
            title: Text(L10n.of(context).s_Advanced_Options),
            value: _enableAdvance.value,
            onChanged: (val) {
              _customProfile = _customProfile.copyWith(enableAdvance: val.oN);
              _enableAdvance.value = val;
            },
          );
        }),
      ]),
    ];

    return SliverAnimatedPaintExtent(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Obx(() {
        return MultiSliver(
          children: [
            MultiSliver(children: _mainTiles),
            if (!_listModeIsPopular.value)
              MultiSliver(
                children: [
                  MultiSliver(
                    children: _slivers,
                  ),
                  if (_enableAdvance.value)
                    _AdvanceView(
                      advanceSearch:
                          _customProfile.advSearch ?? const AdvanceSearch(),
                      onChanged: (AdvanceSearch val) {
                        _customProfile =
                            _customProfile.copyWith(advSearch: val.oN);
                      },
                    )
                ],
              ),
          ],
        );
      }),
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
    if (!kReleaseMode || Get.find<EhSettingService>().debugMode)
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
      padding: kSegmentedPadding,
      child: Text(title),
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
      padding: kSegmentedPadding,
      child: Text(
        title,
        style: kSegmentedTextStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
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

class _SearchTextTile extends StatefulWidget {
  const _SearchTextTile({
    super.key,
    required this.searchTextList,
    this.onChanged,
  });

  final List<String> searchTextList;
  final ValueChanged<List<String>>? onChanged;

  @override
  State<_SearchTextTile> createState() => _SearchTextTileState();
}

class _SearchTextTileState extends State<_SearchTextTile> {
  Future<String?> _getTextTranslate(String text) async {
    final String? tranText =
        await Get.find<TagTransController>().getTranTagWithNameSpaseAuto(text);
    if (tranText?.trim() != text) {
      return tranText;
    }
    return null;
  }

  late ProfileEditController controller;

  late List<String> _searchTextList;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileEditController());
    _searchTextList = widget.searchTextList;
  }

  @override
  Widget build(BuildContext context) {
    return SliverCupertinoListSection.listInsetGrouped(
      header: Text(L10n.of(context).searchTexts),
      children: [
        ..._searchTextList.map((element) => Slidable(
            endActionPane: ActionPane(
              extentRatio: 0.25,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    setState(() {
                      _searchTextList.remove(element);
                      widget.onChanged?.call(_searchTextList);
                    });
                  },
                  backgroundColor: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemRed, context),
                  icon: CupertinoIcons.delete,
                ),
              ],
            ),
            child: controller.isTagTranslate
                ? FutureBuilder<String?>(
                    future: _getTextTranslate(element),
                    initialData: element,
                    builder: (context, snapshot) {
                      return EhCupertinoListTile(
                        title: Text(element),
                        subtitle:
                            snapshot.data != null ? Text(snapshot.data!) : null,
                        key: ValueKey(element),
                      );
                    })
                : EhCupertinoListTile(
                    title: Text(element),
                    key: ValueKey(element),
                  ))),
        EhCupertinoListTile(
          title: Text(
            '${L10n.of(context).newText} ...',
            style: const TextStyle(
              color: CupertinoColors.activeBlue,
            ),
          ),
          onTap: () async {
            final result = await showSearchTextDialog(context);
            if (result != null && result.isNotEmpty) {
              setState(() {
                _searchTextList.add(result);
                widget.onChanged?.call(_searchTextList);
              });
            }
          },
        ),
      ],
    );
  }
}

class _AdvanceView extends StatefulWidget {
  const _AdvanceView({super.key, required this.advanceSearch, this.onChanged});

  final AdvanceSearch advanceSearch;
  final ValueChanged<AdvanceSearch>? onChanged;

  @override
  State<_AdvanceView> createState() => _AdvanceViewState();
}

class _AdvanceViewState extends State<_AdvanceView> {
  late AdvanceSearch _advanceSearch;

  @override
  void initState() {
    super.initState();
    _advanceSearch = widget.advanceSearch;
  }

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        SliverCupertinoListSection.listInsetGrouped(
          children: [
            // s_Only_Show_Galleries_With_Torrents switch
            EhCupertinoSwitchListTile(
              title: Text(L10n.of(context).s_Only_Show_Galleries_With_Torrents),
              value: _advanceSearch.requireGalleryTorrent ?? false,
              onChanged: (val) {
                _advanceSearch =
                    _advanceSearch.copyWith(requireGalleryTorrent: val.oN);
                widget.onChanged?.call(_advanceSearch);
              },
            ),

            // s_Show_Expunged_Galleries switch
            EhCupertinoSwitchListTile(
              title: Text(L10n.of(context).s_Show_Expunged_Galleries),
              value: _advanceSearch.browseExpungedGalleries ?? false,
              onChanged: (val) {
                _advanceSearch =
                    _advanceSearch.copyWith(browseExpungedGalleries: val.oN);
                widget.onChanged?.call(_advanceSearch);
              },
            ),
          ],
        ),

        StatefulBuilder(builder: (context, setState) {
          return SliverCupertinoListSection.listInsetGrouped(
            children: [
              // s_Minimum_Rating switch
              Column(
                children: [
                  EhCupertinoSwitchListTile(
                    title: Text(L10n.of(context).s_Minimum_Rating),
                    value: _advanceSearch.searchWithMinRating ?? false,
                    onChanged: (val) {
                      _advanceSearch =
                          _advanceSearch.copyWith(searchWithMinRating: val.oN);

                      setState(() {});
                      widget.onChanged?.call(_advanceSearch);
                    },
                  ),
                  AnimatedCrossFade(
                    firstCurve: Curves.easeIn,
                    secondCurve: Curves.easeOut,
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: _MinRatingSelector(
                      initValue: _advanceSearch.minRating ?? 2,
                      onChanged: (int value) {
                        _advanceSearch = _advanceSearch.copyWith(
                            minRating: value == 2 ? null : value.oN);
                        widget.onChanged?.call(_advanceSearch);
                      },
                    ),
                    crossFadeState: _advanceSearch.searchWithMinRating ?? false
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ],
          );
        }),

        //
        StatefulBuilder(builder: (context, setState) {
          return SliverCupertinoListSection.listInsetGrouped(
            children: [
              Column(
                children: [
                  // searchBetweenPage switch
                  EhCupertinoSwitchListTile(
                    title: Text(L10n.of(context).s_pages),
                    value: _advanceSearch.searchBetweenPage ?? false,
                    onChanged: (val) {
                      _advanceSearch =
                          _advanceSearch.copyWith(searchBetweenPage: val.oN);

                      widget.onChanged?.call(_advanceSearch);
                      setState(() {});
                    },
                  ),

                  AnimatedCrossFade(
                    crossFadeState: _advanceSearch.searchBetweenPage ?? false
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                    firstCurve: Curves.easeIn,
                    secondCurve: Curves.easeOut,
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: _BetweenPageTile(
                      enable: _advanceSearch.searchBetweenPage ?? false,
                      startPage: _advanceSearch.startPage,
                      endPage: _advanceSearch.endPage,
                      onStartPageChanged: (val) {
                        _advanceSearch = _advanceSearch.copyWith(
                            startPage: val.isEmpty ? null : val.oN);
                        widget.onChanged?.call(_advanceSearch);
                      },
                      onEndPageChanged: (val) {
                        _advanceSearch = _advanceSearch.copyWith(
                            endPage: val.isEmpty ? null : val.oN);
                        widget.onChanged?.call(_advanceSearch);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        }),

        //
        SliverCupertinoListSection.listInsetGrouped(
          header: Text(L10n.of(context).s_Disable_default_filters),
          children: [
            // disableCustomFilterLanguage switch
            EhCupertinoSwitchListTile(
              title: Text(L10n.of(context).language),
              value: _advanceSearch.disableCustomFilterLanguage ?? false,
              onChanged: (val) {
                _advanceSearch = _advanceSearch.copyWith(
                    disableCustomFilterLanguage: val.oN);
                widget.onChanged?.call(_advanceSearch);
              },
            ),

            // disableCustomFilterUploader switch
            EhCupertinoSwitchListTile(
              title: Text(L10n.of(context).uploader),
              value: _advanceSearch.disableCustomFilterUploader ?? false,
              onChanged: (val) {
                _advanceSearch = _advanceSearch.copyWith(
                    disableCustomFilterUploader: val.oN);
                widget.onChanged?.call(_advanceSearch);
              },
            ),

            // disableCustomFilterTags switch
            EhCupertinoSwitchListTile(
              title: Text(L10n.of(context).tags),
              value: _advanceSearch.disableCustomFilterTags ?? false,
              onChanged: (val) {
                _advanceSearch =
                    _advanceSearch.copyWith(disableCustomFilterTags: val.oN);
                widget.onChanged?.call(_advanceSearch);
              },
            ),
          ],
        ),
      ],
    );
  }
}
