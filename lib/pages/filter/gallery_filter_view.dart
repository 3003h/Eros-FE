import 'dart:math';

import 'package:eros_fe/common/controller/advance_search_controller.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/models/index.dart';
import 'package:eros_fe/pages/filter/filter.dart';
import 'package:eros_fe/pages/tab/controller/gallery_filter_controller.dart';
import 'package:eros_fe/pages/tab/controller/search_page_controller.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

const double _kHeight = 280.0;
const double _kAdvanceHeight = 480.0;

/// 高级搜索
class GalleryFilterView extends StatelessWidget {
  GalleryFilterView({
    Key? key,
    required this.catNum,
    required this.catNumChanged,
    this.catCrossAxisCount = 2,
  })  : filterController = Get.put(GalleryFilterController())!,
        super(key: key);

  final int catNum;
  final ValueChanged<int> catNumChanged;
  final GalleryFilterController filterController;
  final AdvanceSearchController advanceSearchController = Get.find();

  final int catCrossAxisCount;

  SearchPageController? get _searchPageController {
    if (int.parse(searchPageCtrlTag) > 0) {
      logger.t('searchPageCtrlDepth $searchPageCtrlTag');
      return Get.find<SearchPageController>(tag: searchPageCtrlTag);
    }
    return null;
  }

  Widget _getColumnNormal(BuildContext context) {
    return Obx(() {
      final Rx<AdvanceSearch> _advanceSearch =
          advanceSearchController.advanceSearch;
      return Column(
        children: <Widget>[
          if (int.parse(searchPageCtrlTag) > 0)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoSlidingSegmentedControl<SearchType>(
                  children: <SearchType, Widget>{
                    SearchType.normal: Text(L10n.of(context).tab_gallery)
                        .marginSymmetric(horizontal: 8),
                    SearchType.watched: Text(L10n.of(context).tab_watched)
                        .marginSymmetric(horizontal: 8),
                    SearchType.favorite: Text(L10n.of(context).tab_favorite)
                        .marginSymmetric(horizontal: 8),
                  },
                  groupValue:
                      _searchPageController?.searchType ?? SearchType.normal,
                  onValueChanged: (SearchType? value) {
                    _searchPageController?.searchType =
                        value ?? SearchType.normal;
                  },
                ),
              ],
            ),
          if (_searchPageController?.searchType != SearchType.favorite)
            GalleryCatFilter(
              // padding: const EdgeInsets.symmetric(vertical: 4.0),
              catNum: catNum,
              onCatNumChanged: catNumChanged,
              crossAxisCount: catCrossAxisCount,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          if (_searchPageController?.searchType != SearchType.favorite)
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(L10n.of(context).s_Advanced_Options)),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: advanceSearchController.enableAdvance,
                      onChanged: (bool value) {
                        logger.d(' onChanged to $value');
                        advanceSearchController.enableAdvance = value;
                      },
                    ),
                  ),
                  const Spacer(),
                  Offstage(
                    offstage: !advanceSearchController.enableAdvance,
                    child: CupertinoButton(
                        // padding: const EdgeInsets.only(right: 8),
                        // minSize: 20,
                        child: Text(
                          L10n.of(context).clear_filter,
                          style: const TextStyle(height: 1, fontSize: 14),
                        ),
                        onPressed: () {
                          advanceSearchController.reset();
                        }),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // SearchPageController? _searchPageController;
    // if (int.parse(searchPageCtrlDepth) > 0) {
    //   logger.d('searchPageCtrlDepth $searchPageCtrlDepth');
    //   _searchPageController =
    //       Get.find<SearchPageController>(tag: searchPageCtrlDepth);
    // }

    return Obx(() {
      final Rx<AdvanceSearch> _advanceSearch =
          advanceSearchController.advanceSearch;

      final List<Widget> _listDft = <Widget>[
        if (int.parse(searchPageCtrlTag) > 0)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoSlidingSegmentedControl<SearchType>(
                children: <SearchType, Widget>{
                  SearchType.normal: Text(L10n.of(context).tab_gallery)
                      .marginSymmetric(horizontal: 8),
                  SearchType.watched: Text(L10n.of(context).tab_watched)
                      .marginSymmetric(horizontal: 8),
                  SearchType.favorite: Text(L10n.of(context).tab_favorite)
                      .marginSymmetric(horizontal: 8),
                },
                groupValue:
                    _searchPageController?.searchType ?? SearchType.normal,
                onValueChanged: (SearchType? value) {
                  _searchPageController?.searchType =
                      value ?? SearchType.normal;
                },
              ),
            ],
          ),
        if (_searchPageController?.searchType != SearchType.favorite)
          GalleryCatFilter(
            catNum: catNum,
            onCatNumChanged: catNumChanged,
            crossAxisCount: catCrossAxisCount,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        if (_searchPageController?.searchType != SearchType.favorite)
          Container(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: Text(
                  L10n.of(context).s_Advanced_Options,
                  textAlign: TextAlign.start,
                )),
                // Text(L10n.of(context).s_Advanced_Options),
                Offstage(
                  offstage: !advanceSearchController.enableAdvance,
                  child: CupertinoButton(
                      padding: const EdgeInsets.only(right: 4),
                      minSize: 40,
                      // child: Text(
                      //   L10n.of(context).clear_filter,
                      //   style: const TextStyle(height: 1, fontSize: 14),
                      // ),
                      child: const Icon(
                        FontAwesomeIcons.rotateLeft,
                        size: 20,
                      ),
                      onPressed: () {
                        advanceSearchController.reset();
                      }),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: advanceSearchController.enableAdvance,
                    onChanged: (bool value) {
                      // logger.d(' onChanged to $value');
                      advanceSearchController.enableAdvance = value;
                    },
                  ),
                ),
                // const Spacer(),
              ],
            ),
          ),
      ];

      final List<Widget> _listFav = <Widget>[
        // AdvanceSearchSwitchItem(
        //   title: L10n.of(context).s_Search_Fav_Name,
        //   value: _advanceSearch.value.favSearchName,
        //   onChanged: (bool value) {
        //     _advanceSearch(_advanceSearch.value.copyWith(favSearchName: value));
        //   },
        // ),
        // AdvanceSearchSwitchItem(
        //   title: L10n.of(context).s_Search_Fav_Tags,
        //   value: _advanceSearch.value.favSearchTags,
        //   onChanged: (bool value) {
        //     _advanceSearch(_advanceSearch.value.copyWith(favSearchTags: value));
        //   },
        // ),
        // AdvanceSearchSwitchItem(
        //   title: L10n.of(context).s_Search_Fav_Note,
        //   value: _advanceSearch.value.favSearchNote,
        //   onChanged: (bool value) {
        //     _advanceSearch(_advanceSearch.value.copyWith(favSearchNote: value));
        //   },
        // ),
      ];

      final List<Widget> _listAdv = <Widget>[
        Divider(
          height: 0.5,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, context),
        ),
        // AdvanceSearchSwitchItem(
        //   title: L10n.of(context).s_Search_Gallery_Name,
        //   value: _advanceSearch.value.searchGalleryName,
        //   onChanged: (bool value) {
        //     _advanceSearch(
        //         _advanceSearch.value.copyWith(searchGalleryName: value));
        //   },
        // ),
        // AdvanceSearchSwitchItem(
        //   title: L10n.of(context).s_Search_Gallery_Tags,
        //   value: _advanceSearch.value.searchGalleryTags,
        //   onChanged: (bool value) {
        //     _advanceSearch(
        //         _advanceSearch.value.copyWith(searchGalleryTags: value));
        //   },
        // ),
        // AdvanceSearchSwitchItem(
        //   title: L10n.of(context).s_Search_Gallery_Description,
        //   value: _advanceSearch.value.searchGalleryDesc,
        //   onChanged: (bool value) {
        //     _advanceSearch(
        //         _advanceSearch.value.copyWith(searchGalleryDesc: value));
        //   },
        // ),
        // AdvanceSearchSwitchItem(
        //   title: L10n.of(context).s_Search_Torrent_Filenames,
        //   value: _advanceSearch.value.searchToreenFilenames,
        //   onChanged: (bool value) {
        //     _advanceSearch(
        //         _advanceSearch.value.copyWith(searchToreenFilenames: value));
        //   },
        // ),
        AdvanceSearchSwitchItem(
          title: L10n.of(context).s_Only_Show_Galleries_With_Torrents,
          value: _advanceSearch.value.requireGalleryTorrent,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(requireGalleryTorrent: value.oN));
          },
        ),
        // AdvanceSearchSwitchItem(
        //   title: L10n.of(context).s_Search_Low_Power_Tags,
        //   value: _advanceSearch.value.searchLowPowerTags,
        //   onChanged: (bool value) {
        //     _advanceSearch(
        //         _advanceSearch.value.copyWith(searchLowPowerTags: value));
        //   },
        // ),
        // AdvanceSearchSwitchItem(
        //   title: L10n.of(context).s_Search_Downvoted_Tags,
        //   value: _advanceSearch.value.searchDownvotedTags,
        //   onChanged: (bool value) {
        //     _advanceSearch(
        //         _advanceSearch.value.copyWith(searchDownvotedTags: value));
        //   },
        // ),
        AdvanceSearchSwitchItem(
          title: L10n.of(context).s_Show_Expunged_Galleries,
          value: _advanceSearch.value.browseExpungedGalleries,
          onChanged: (bool value) {
            _advanceSearch(_advanceSearch.value
                .copyWith(browseExpungedGalleries: value.oN));
          },
        ),
        AdvanceSearchSwitchItem(
          title: L10n.of(context).s_Minimum_Rating,
          value: _advanceSearch.value.searchWithMinRating,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(searchWithMinRating: value.oN));
          },
        ),
        AnimatedCrossFade(
          alignment: Alignment.center,
          crossFadeState: _advanceSearch.value.searchWithMinRating ?? false
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstCurve: Curves.easeIn,
          secondCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox(),
          secondChild: CupertinoSlidingSegmentedControl<int>(
            // ignore: prefer_const_literals_to_create_immutables
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
            groupValue: _advanceSearch.value.minRating,
            onValueChanged: (int? value) {
              _advanceSearch(
                  _advanceSearch.value.copyWith(minRating: value.oN));
            },
          ),
        ),
        AdvanceSearchSwitchItem(
          title: L10n.of(context).s_pages,
          expand: false,
          value: advanceSearchController.advanceSearch.value.searchBetweenPage,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(searchBetweenPage: value.oN));
          },
        ),
        AnimatedCrossFade(
          alignment: Alignment.center,
          crossFadeState: _advanceSearch.value.searchBetweenPage ?? false
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstCurve: Curves.easeIn,
          secondCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox(),
          secondChild: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 4),
                width: 50,
                height: 28,
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                    color: ehTheme.textFieldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  controller: filterController.statrPageCtrl,
                  keyboardType: TextInputType.number,
                  cursorHeight: 14,
                  enabled: advanceSearchController
                          .advanceSearch.value.searchBetweenPage ??
                      false,
                  style: const TextStyle(
                    height: 1,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ),
              Text(L10n.of(context).s_and),
              Container(
                margin: const EdgeInsets.only(left: 4),
                width: 50,
                height: 28,
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                    color: ehTheme.textFieldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  controller: filterController.endPageCtrl,
                  keyboardType: TextInputType.number,
                  cursorHeight: 14,
                  enabled: advanceSearchController
                          .advanceSearch.value.searchBetweenPage ??
                      false,
                  style: const TextStyle(
                    height: 1,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
            margin: const EdgeInsets.only(top: 18),
            child: Text(L10n.of(context).s_Disable_default_filters)),
        AdvanceSearchSwitchItem(
          title: L10n.of(context).language,
          value: _advanceSearch.value.disableCustomFilterLanguage,
          onChanged: (bool value) {
            _advanceSearch(_advanceSearch.value
                .copyWith(disableCustomFilterLanguage: value.oN));
          },
        ),
        AdvanceSearchSwitchItem(
          title: L10n.of(context).uploader,
          value: _advanceSearch.value.disableCustomFilterUploader,
          onChanged: (bool value) {
            _advanceSearch(_advanceSearch.value
                .copyWith(disableCustomFilterUploader: value.oN));
          },
        ),
        AdvanceSearchSwitchItem(
          title: L10n.of(context).tags,
          value: _advanceSearch.value.disableCustomFilterTags,
          onChanged: (bool value) {
            _advanceSearch(_advanceSearch.value
                .copyWith(disableCustomFilterTags: value.oN));
          },
        ),
        // const SizedBox(height: 50)
      ];

      if (advanceSearchController.enableAdvance &&
          _searchPageController?.searchType != SearchType.favorite) {
        _listDft.addAll(_listAdv);
      } else if (_searchPageController?.searchType == SearchType.favorite) {
        _listDft.addAll(_listFav);
      }

      final expand = advanceSearchController.enableAdvance &&
          _searchPageController?.searchType != SearchType.favorite;

      return AnimatedContainer(
        height: min(context.height / 2, expand ? _kAdvanceHeight : _kHeight),
        // height: context.height / 2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        // child: SingleChildScrollView(
        //   child: Column(
        //     children: _listDft,
        //   ),
        // ),
        child: ListView.builder(
          physics: expand ? null : const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          itemBuilder: (_, index) {
            return _listDft[index];
          },
          itemCount: _listDft.length,
        ),
      );
    });
  }
}
