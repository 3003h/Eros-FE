import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

class EhFlutterListViewDelegate extends FlutterListViewDelegate {
  EhFlutterListViewDelegate(
    super.builder, {
    super.childCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.semanticIndexCallback = _kDefaultSemanticIndexCallback,
    super.semanticIndexOffset,
    super.onItemKey,
    super.keepPosition,
    super.keepPositionOffset,
    super.onItemSticky,
    super.stickyAtTailer,
    super.onItemHeight,
    super.preferItemHeight,
    super.firstItemAlign,
    super.initIndex,
    super.forceToExecuteInitIndex,
    super.initOffset,
    super.initOffsetBasedOnBottom,
    super.onIsPermanent,
    super.isSupressElementGenerate,
  });
}

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;
