import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/extension.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/taginfo_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

const CupertinoDynamicColor _kClearButtonColor =
    CupertinoDynamicColor.withBrightness(
  color: Color(0xFF636366),
  darkColor: Color(0xFFAEAEB2),
);

class AddTagPage extends StatelessWidget {
  final TagInfoController controller = Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(L10n.of(context).add_tags),
          previousPageTitle: L10n.of(context).cancel,
          trailing: CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.only(left: 4),
            child: Text(L10n.of(context).done),
            onPressed: () {
              Get.back(result: controller.tags);
            },
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CupertinoTextField(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                maxLines: null,
                // keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                decoration: BoxDecoration(
                  color: ehTheme.textFieldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                controller: controller.tagsTextController,
                focusNode: controller.focusNode,
                placeholder: L10n.of(context).add_tag_placeholder,
                placeholderStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.placeholderText,
                  height: 1.25,
                ),
                // clearButtonMode: OverlayVisibilityMode.editing,
                suffix: GetBuilder<TagInfoController>(
                  id: GetIds.TAG_ADD_CLEAR_BTN,
                  tag: pageCtrlDepth,
                  builder: (TagInfoController controller) {
                    return controller.showClearButton
                        ? GestureDetector(
                            onTap: controller.clear,
                            child: Icon(
                              LineIcons.timesCircle,
                              size: 18.0,
                              color: CupertinoDynamicColor.resolve(
                                  _kClearButtonColor, context),
                            ).paddingSymmetric(horizontal: 9),
                          )
                        : const SizedBox();
                  },
                ),
                autofocus: true,
                style: const TextStyle(height: 1.25),
                // strutStyle:
                //     const StrutStyle(forceStrutHeight: true, height: 1.2),
                onEditingComplete: () {
                  Get.back(result: controller.tags);
                },
              ).paddingSymmetric(vertical: 8, horizontal: 10),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // 触摸收起键盘
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  onPanDown: (DragDownDetails details) {
                    // 滑动收起键盘
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: CustomScrollView(
                    slivers: [
                      QryTagSliverList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class QryTagSliverList extends StatelessWidget {
  final TagInfoController controller = Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    return Obx(() => SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.addQryTag(index);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.qryTags[index].fullTagText ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    if (controller.isTagTranslat)
                      Text(controller.qryTags[index].fullTagTranslate ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, Get.context!),
                          )),
                  ],
                ).paddingSymmetric(vertical: 4, horizontal: 20),
              );
            },
            childCount: controller.qryTags.length,
          ),
        ));
  }
}
