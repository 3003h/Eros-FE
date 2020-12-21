import 'package:fehviewer/common/controller/advance_search_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/controller/gallery_filter_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'gallery_base.dart';

const double kHeight = 220.0;
const double kAdvanceHeight = 500.0;

/// 高级搜索
class GalleryFilterView extends StatelessWidget {
  GalleryFilterView({
    Key key,
    @required this.catNum,
    @required this.catNumChanged,
  })  : galleryFilterController = Get.put(GalleryFilterController()),
        super(key: key);

  final int catNum;
  final ValueChanged<int> catNumChanged;
  final GalleryFilterController galleryFilterController;
  final AdvanceSearchController advanceSearchController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
          height: advanceSearchController.enableAdvance.value
              ? kAdvanceHeight
              : kHeight,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  GalleryCatFilter(
                    // padding: const EdgeInsets.symmetric(vertical: 4.0),
                    value: catNum,
                    onChanged: catNumChanged,
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text(S.of(context).s_Advanced_Options),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            value: advanceSearchController.enableAdvance.value,
                            onChanged: (bool value) {
                              logger.d(' onChanged to $value');
                              advanceSearchController.enableAdvance.value =
                                  value;
                            },
                          ),
                        ),
                        const Spacer(),
                        Offstage(
                          offstage:
                              !advanceSearchController.enableAdvance.value,
                          child: CupertinoButton(
                              padding: const EdgeInsets.only(right: 8),
                              minSize: 20,
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
                  Divider(
                    height: 0.5,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey4, context),
                  ),
                  Offstage(
                    offstage: !advanceSearchController.enableAdvance.value,
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          AdvanceSearchSwitchItem(
                            title: S.of(context).s_Search_Gallery_Name,
                            value: advanceSearchController
                                    .advanceSearch.value.searchGalleryName ??
                                true,
                            onChanged: (bool value) {
                              advanceSearchController.advanceSearch
                                  .update((_advanceSearch) {
                                _advanceSearch.searchGalleryName = value;
                              });
                            },
                          ),
                          AdvanceSearchSwitchItem(
                            title: S.of(context).s_Search_Gallery_Tags,
                            value: advanceSearchController
                                    .advanceSearch.value.searchGalleryTags ??
                                true,
                            onChanged: (bool value) {
                              advanceSearchController.advanceSearch
                                  .update((_advanceSearch) {
                                _advanceSearch.searchGalleryTags = value;
                              });
                            },
                          ),
                          AdvanceSearchSwitchItem(
                            title: S.of(context).s_Search_Gallery_Description,
                            value: advanceSearchController
                                    .advanceSearch.value.searchGalleryDesc ??
                                false,
                            onChanged: (bool value) {
                              advanceSearchController.advanceSearch
                                  .update((_advanceSearch) {
                                _advanceSearch.searchGalleryDesc = value;
                              });
                            },
                          ),
                          AdvanceSearchSwitchItem(
                            title: S.of(context).s_Search_Low_Power_Tags,
                            value: advanceSearchController
                                    .advanceSearch.value.searchLowPowerTags ??
                                false,
                            onChanged: (bool value) {
                              advanceSearchController.advanceSearch
                                  .update((_advanceSearch) {
                                _advanceSearch.searchLowPowerTags = value;
                              });
                            },
                          ),
                          AdvanceSearchSwitchItem(
                            title: S.of(context).s_Search_Downvoted_Tags,
                            value: advanceSearchController
                                    .advanceSearch.value.searchDownvotedTags ??
                                false,
                            onChanged: (bool value) {
                              advanceSearchController.advanceSearch
                                  .update((_advanceSearch) {
                                _advanceSearch.searchDownvotedTags = value;
                              });
                            },
                          ),
                          AdvanceSearchSwitchItem(
                            title: S.of(context).s_Show_Expunged_Galleries,
                            value: advanceSearchController
                                    .advanceSearch.value.searchExpunged ??
                                false,
                            onChanged: (bool value) {
                              advanceSearchController.advanceSearch
                                  .update((_advanceSearch) {
                                _advanceSearch.searchExpunged = value;
                              });
                            },
                          ),
                          AdvanceSearchSwitchItem(
                            title: S.of(context).s_Minimum_Rating,
                            value: advanceSearchController
                                    .advanceSearch.value.searchWithminRating ??
                                false,
                            onChanged: (bool value) {
                              advanceSearchController.advanceSearch
                                  .update((_advanceSearch) {
                                _advanceSearch.searchWithminRating = value;
                              });
                            },
                          ),
                          CupertinoSlidingSegmentedControl<int>(
                              // ignore: prefer_const_literals_to_create_immutables
                              children: <int, Widget>{
                                2: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(S.of(context).s_stars('2')),
                                ),
                                3: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(S.of(context).s_stars('3')),
                                ),
                                4: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(S.of(context).s_stars('4')),
                                ),
                                5: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(S.of(context).s_stars('5')),
                                ),
                              },
                              groupValue: advanceSearchController
                                      .advanceSearch.value.minRating ??
                                  2,
                              onValueChanged: (int value) {
                                advanceSearchController.advanceSearch
                                    .update((_advanceSearch) {
                                  _advanceSearch.minRating = value;
                                });
                              }),
                          Row(
                            children: <Widget>[
                              AdvanceSearchSwitchItem(
                                title: S.of(context).s_pages,
                                expand: false,
                                value: advanceSearchController.advanceSearch
                                        .value.searchBetweenpage ??
                                    false,
                                onChanged: (bool value) {
                                  advanceSearchController.advanceSearch
                                      .update((_advanceSearch) {
                                    _advanceSearch.searchBetweenpage = value;
                                  });
                                },
                              ),
                              const Spacer(),
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 50,
                                height: 28,
                                child: CupertinoTextField(
                                  controller:
                                      galleryFilterController.statrPageCtrl,
                                  keyboardType: TextInputType.number,
                                  cursorHeight: 14,
                                  enabled: advanceSearchController.advanceSearch
                                          .value.searchBetweenpage ??
                                      false,
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
                                  controller:
                                      galleryFilterController.endPageCtrl,
                                  keyboardType: TextInputType.number,
                                  cursorHeight: 14,
                                  enabled: advanceSearchController.advanceSearch
                                          .value.searchBetweenpage ??
                                      false,
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
                              child: Text(
                                  S.of(context).s_Disable_default_filters)),
                          AdvanceSearchSwitchItem(
                            title: S.of(context).language,
                            value: advanceSearchController
                                    .advanceSearch.value.disableDFLanguage ??
                                false,
                            onChanged: (bool value) {
                              advanceSearchController.advanceSearch
                                  .update((_advanceSearch) {
                                _advanceSearch.disableDFLanguage = value;
                              });
                            },
                          ),
                          AdvanceSearchSwitchItem(
                            title: S.of(context).uploader,
                            value: advanceSearchController
                                    .advanceSearch.value.disableDFUploader ??
                                false,
                            onChanged: (bool value) {
                              advanceSearchController.advanceSearch
                                  .update((_advanceSearch) {
                                _advanceSearch.disableDFUploader = value;
                              });
                            },
                          ),
                          AdvanceSearchSwitchItem(
                            title: S.of(context).tags,
                            value: advanceSearchController
                                    .advanceSearch.value.disableDFTags ??
                                false,
                            onChanged: (bool value) {
                              advanceSearchController.advanceSearch
                                  .update((_advanceSearch) {
                                _advanceSearch.disableDFTags = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
