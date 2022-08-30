import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'gallery_item.dart';

const double tagBoxHeight = 18;

class TagListViewBox extends StatelessWidget {
  const TagListViewBox({Key? key, this.simpleTags}) : super(key: key);

  final List<SimpleTag>? simpleTags;

  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();
    return simpleTags != null && simpleTags!.isNotEmpty
        ? Obx(() => SizedBox(
              height: tagBoxHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    List<Widget>.from(simpleTags!.map((SimpleTag _simpleTag) {
                  final String? _text = _ehConfigService.isTagTranslat
                      ? _simpleTag.translat
                      : _simpleTag.text;
                  return FrameSeparateWidget(
                    placeHolder: const TagItem(text: ''),
                    index: -1,
                    child: TagItem(
                      text: _text,
                      color: ColorsUtil.getTagColor(_simpleTag.color),
                      backgrondColor:
                          ColorsUtil.getTagColor(_simpleTag.backgrondColor),
                    ),
                  ).paddingOnly(right: 4.0);
                }).toList()), //要显示的子控件集合
              ),
            ))
        : Container();
  }
}

class TagWaterfallFlowViewBox extends StatelessWidget {
  const TagWaterfallFlowViewBox(
      {Key? key,
      this.simpleTags,
      this.crossAxisCount = 2,
      this.splitFrame = false})
      : super(key: key);

  final List<SimpleTag>? simpleTags;
  final int crossAxisCount;
  final bool splitFrame;

  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();
    final EhConfigService _ehConfigService = Get.find();

    return Obx(() {
      List<SimpleTag>? _simpleTags =
          getLimitSimpleTags(simpleTags, _ehConfigService.listViewTagLimit);

      if (_simpleTags == null || _simpleTags.isEmpty) {
        return const SizedBox.shrink();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: crossAxisCount * 22 - 4,
          child: WaterfallFlow.builder(
            shrinkWrap: true,
            controller: controller,
            primary: false,
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: _simpleTags.length,
            itemBuilder: (BuildContext context, int index) {
              return Obx(
                () {
                  final _simpleTag = _simpleTags[index];
                  final String? _text = _ehConfigService.isTagTranslat
                      ? _simpleTag.translat
                      : _simpleTag.text;
                  Widget _item = TagItem(
                    text: _text,
                    color: ColorsUtil.getTagColor(_simpleTag.color),
                    backgrondColor:
                        ColorsUtil.getTagColor(_simpleTag.backgrondColor),
                  );

                  if (splitFrame) {
                    _item = FrameSeparateWidget(
                      placeHolder: const TagItem(text: '..'),
                      index: -1,
                      child: _item,
                    );
                  }

                  return _item;
                },
              );
            },
          ),
        ),
      );
    });
  }
}

class PlaceHolderLine extends StatelessWidget {
  const PlaceHolderLine({Key? key, this.width}) : super(key: key);
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey5, context),
          height: 16,
        ),
      ).paddingSymmetric(vertical: 4, horizontal: 4),
    );
  }
}

List<SimpleTag>? getLimitSimpleTags(List<SimpleTag>? simpleTags, int limit) {
  if (limit > -1) {
    return simpleTags?.take(limit).toList();
  } else {
    return simpleTags;
  }
}

class PostTime extends StatelessWidget {
  const PostTime({
    Key? key,
    this.postTime,
    this.expunged = false,
    this.fontSize = 12,
  }) : super(key: key);
  final String? postTime;
  final bool? expunged;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      postTime ?? '',
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: fontSize,
        color: CupertinoColors.systemGrey,
        decoration: (expunged ?? false)
            ? TextDecoration.lineThrough
            : TextDecoration.none,
      ),
    );
  }
}
