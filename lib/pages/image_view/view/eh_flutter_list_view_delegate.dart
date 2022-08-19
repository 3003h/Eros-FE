import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_list_view/flutter_list_view.dart';

class EhFlutterListViewDelegate extends FlutterListViewDelegate {
  EhFlutterListViewDelegate(
    NullableIndexedWidgetBuilder builder, {
    int? childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    SemanticIndexCallback semanticIndexCallback =
        _kDefaultSemanticIndexCallback,
    int semanticIndexOffset = 0,
    FlutterListViewDelegateOnItemKey? onItemKey,
    bool keepPosition = false,
    double keepPositionOffset = 0.0,
    FlutterListViewDelegateOnItemSticky? onItemSticky,
    bool stickyAtTailer = false,
    FlutterListViewDelegateOnItemHeight? onItemHeight,
    double preferItemHeight = 50.0,
    FirstItemAlign firstItemAlign = FirstItemAlign.start,
    int initIndex = 0,
    int? forceToExecuteInitIndex,
    double initOffset = 0.0,
    bool initOffsetBasedOnBottom = false,
    bool Function(String keyOrIndex)? onIsPermanent,
    bool isSupressElementGenerate = false,
  }) : super(
          builder,
          childCount: childCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: semanticIndexCallback,
          semanticIndexOffset: semanticIndexOffset,
          onItemKey: onItemKey,
          keepPosition: keepPosition,
          keepPositionOffset: keepPositionOffset,
          onItemSticky: onItemSticky,
          stickyAtTailer: stickyAtTailer,
          onItemHeight: onItemHeight,
          preferItemHeight: preferItemHeight,
          firstItemAlign: firstItemAlign,
          initIndex: initIndex,
          forceToExecuteInitIndex: forceToExecuteInitIndex,
          initOffset: initOffset,
          initOffsetBasedOnBottom: initOffsetBasedOnBottom,
          onIsPermanent: onIsPermanent,
          isSupressElementGenerate: isSupressElementGenerate,
        );
}

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;
