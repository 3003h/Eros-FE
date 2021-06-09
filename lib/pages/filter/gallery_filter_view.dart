import 'package:fehviewer/common/controller/advance_search_controller.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/tab/controller/gallery_filter_controller.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

const double kHeight = 260.0;
const double kAdvanceHeight = 480.0;

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

  @override
  Widget build(BuildContext context) {
    SearchPageController? _searchPageController;
    if (int.parse(searchPageCtrlDepth) > 0) {
      logger.d('searchPageCtrlDepth $searchPageCtrlDepth');
      _searchPageController =
          Get.find<SearchPageController>(tag: searchPageCtrlDepth);
    }

    return Obx(() {
      final Rx<AdvanceSearch> _advanceSearch =
          advanceSearchController.advanceSearch;

      final List<Widget> _listDft = <Widget>[
        if (int.parse(searchPageCtrlDepth) > 0)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoSlidingSegmentedControl<SearchType>(
                children: <SearchType, Widget>{
                  SearchType.normal: Text(S.of(context).tab_gallery)
                      .marginSymmetric(horizontal: 8),
                  SearchType.watched: Text(S.of(context).tab_watched)
                      .marginSymmetric(horizontal: 8),
                  SearchType.favorite: Text(S.of(context).tab_favorite)
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
                Text(S.of(context).s_Advanced_Options),
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
                        S.of(context).clear_filter,
                        style: const TextStyle(height: 1, fontSize: 14),
                      ),
                      onPressed: () {
                        advanceSearchController.reset();
                      }),
                ),
              ],
            ),
          ),
      ];

      final List<Widget> _listFav = <Widget>[
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Search_Fav_Name,
          value: _advanceSearch.value.favSearchName,
          onChanged: (bool value) {
            _advanceSearch(_advanceSearch.value.copyWith(favSearchName: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Search_Fav_Tags,
          value: _advanceSearch.value.favSearchTags,
          onChanged: (bool value) {
            _advanceSearch(_advanceSearch.value.copyWith(favSearchTags: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Search_Fav_Note,
          value: _advanceSearch.value.favSearchNote,
          onChanged: (bool value) {
            _advanceSearch(_advanceSearch.value.copyWith(favSearchNote: value));
          },
        ),
      ];

      final List<Widget> _listAdv = <Widget>[
        Divider(
          height: 0.5,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, context),
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Search_Gallery_Name,
          value: _advanceSearch.value.searchGalleryName,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(searchGalleryName: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Search_Gallery_Tags,
          value: _advanceSearch.value.searchGalleryTags,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(searchGalleryTags: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Search_Gallery_Description,
          value: _advanceSearch.value.searchGalleryDesc,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(searchGalleryDesc: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Search_Torrent_Filenames,
          value: _advanceSearch.value.searchToreenFilenames,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(searchToreenFilenames: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Only_Show_Galleries_With_Torrents,
          value: _advanceSearch.value.onlyShowWhithTorrents,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(onlyShowWhithTorrents: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Search_Low_Power_Tags,
          value: _advanceSearch.value.searchLowPowerTags,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(searchLowPowerTags: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Search_Downvoted_Tags,
          value: _advanceSearch.value.searchDownvotedTags,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(searchDownvotedTags: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Show_Expunged_Galleries,
          value: _advanceSearch.value.searchExpunged,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(searchExpunged: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).s_Minimum_Rating,
          value: _advanceSearch.value.searchWithminRating,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(searchWithminRating: value));
          },
        ),
        AnimatedContainer(
          height: (_advanceSearch.value.searchWithminRating) ? 50 : 0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            children: [
              if (advanceSearchController
                  .advanceSearch.value.searchWithminRating)
                CupertinoSlidingSegmentedControl<int>(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: <int, Widget>{
                    2: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(S.of(context).s_stars('2')),
                    ),
                    3: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(S.of(context).s_stars('3')),
                    ),
                    4: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(S.of(context).s_stars('4')),
                    ),
                    5: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(S.of(context).s_stars('5')),
                    ),
                  },
                  groupValue: _advanceSearch.value.minRating,
                  onValueChanged: (int? value) {
                    _advanceSearch(
                        _advanceSearch.value.copyWith(minRating: value));
                  },
                ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            AdvanceSearchSwitchItem(
              title: S.of(context).s_pages,
              expand: false,
              value:
                  advanceSearchController.advanceSearch.value.searchBetweenpage,
              onChanged: (bool value) {
                _advanceSearch(
                    _advanceSearch.value.copyWith(searchBetweenpage: value));
              },
            ),
            const Spacer(),
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
                    .advanceSearch.value.searchBetweenpage,
                style: const TextStyle(
                  height: 1,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ),
            Text(S.of(context).s_and),
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
                    .advanceSearch.value.searchBetweenpage,
                style: const TextStyle(
                  height: 1,
                  textBaseline: TextBaseline.alphabetic,
                ),
              ),
            ),
          ],
        ),
        Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(S.of(context).s_Disable_default_filters)),
        AdvanceSearchSwitchItem(
          title: S.of(context).language,
          value: _advanceSearch.value.disableDFLanguage,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(disableDFLanguage: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).uploader,
          value: _advanceSearch.value.disableDFUploader,
          onChanged: (bool value) {
            _advanceSearch(
                _advanceSearch.value.copyWith(disableDFUploader: value));
          },
        ),
        AdvanceSearchSwitchItem(
          title: S.of(context).tags,
          value: _advanceSearch.value.disableDFTags,
          onChanged: (bool value) {
            _advanceSearch(_advanceSearch.value.copyWith(disableDFTags: value));
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

      return AnimatedContainer(
        height: advanceSearchController.enableAdvance &&
                _searchPageController?.searchType != SearchType.favorite
            ? kAdvanceHeight
            : kHeight,
        // height: context.height / 2,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        child: ListView.builder(
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
