import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/pages/gallery/controller/taginfo_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

const CupertinoDynamicColor _kClearButtonColor =
    CupertinoDynamicColor.withBrightness(
  color: Color(0xFF636366),
  darkColor: Color(0xFFAEAEB2),
);

class AddTagPage extends StatefulWidget {
  const AddTagPage({super.key});

  @override
  State<AddTagPage> createState() => _AddTagPageState();
}

class _AddTagPageState extends State<AddTagPage> {
  final TagInfoController controller = Get.find(tag: pageCtrlTag);

  @override
  void dispose() {
    super.dispose();
    if (Get.isRegistered<TagInfoController>(tag: pageCtrlTag)) {
      Get.delete<TagInfoController>(tag: pageCtrlTag);
    }
  }

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
              Get.back(
                result: controller.tags,
                id: isLayoutLarge ? 2 : null,
              );
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
                  tag: pageCtrlTag,
                  builder: (TagInfoController controller) {
                    return controller.showClearButton
                        ? GestureDetector(
                            onTap: controller.clear,
                            child: Icon(
                              FontAwesomeIcons.circleXmark,
                              size: 16.0,
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
                  Get.back(
                    result: controller.tags,
                    id: isLayoutLarge ? 2 : null,
                  );
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
                  child: const CustomScrollView(
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
  const QryTagSliverList({super.key});

  TagInfoController get controller => Get.find(tag: pageCtrlTag);

  @override
  Widget build(BuildContext context) {
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

    return Obx(() => SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final input = controller.currQry;
              final text = controller.qryTags[index].fullTagText ?? '';
              final translate = controller.qryTags[index].fullTagTranslate;

              final textSpans = text
                  .split(input)
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
                onTap: () {
                  controller.addQryTag(index);
                },
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
                    if (translate != null)
                      RichText(
                        text: TextSpan(
                          children: translateTextSpans,
                        ),
                      ),
                  ],
                ).paddingSymmetric(vertical: 4, horizontal: 20),
              );
            },
            childCount: controller.qryTags.length,
          ),
        ));
  }
}
