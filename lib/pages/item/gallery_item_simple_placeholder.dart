import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'gallery_item_simple.dart';
import 'item_base.dart';

class GalleryItemSimplePlaceHolder extends StatelessWidget {
  const GalleryItemSimplePlaceHolder({Key? key, this.showTag = true})
      : super(key: key);
  final bool showTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: showTag ? kItemHeight + 10 : kItemHeight,
      padding: const EdgeInsets.fromLTRB(kPaddingLeft, 6, 6, 6),
      child: Row(
        children: [
          Container(
            width: kCoverImageWidth,
            height: kItemHeight,
            child: ClipRRect(
              // 圆角
              borderRadius: BorderRadius.circular(6),
              child: SizedBox.expand(
                child: Container(
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey5, context)),
              ),
            ),
          ),
          Container(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const PlaceHolderLine(),
                const PlaceHolderLine(),
                const Spacer(),
                Container(width: 80, child: const PlaceHolderLine()),
                // 评分行
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // 评分
                    Container(width: 50, child: const PlaceHolderLine()),
                    // 占位
                    const Spacer(),
                    Container(width: 50, child: const PlaceHolderLine()),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                // 类型和时间
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Spacer(),
                  ],
                ),
                Divider(
                  height: 0.5,
                  indent: kPaddingLeft,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
