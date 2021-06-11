import 'package:flutter/widgets.dart';

import 'element.dart';
import 'render.dart';

/// Delegate for configuring a [SliverFloatingPinnedPersistentHeader].
abstract class SliverFloatingPinnedPersistentHeaderDelegate {
  SliverFloatingPinnedPersistentHeaderDelegate({
    required this.minExtentProtoType,
    required this.maxExtentProtoType,
  });

  /// The poroto type widget of min extent
  final Widget minExtentProtoType;

  /// The poroto type widget of max extent
  final Widget maxExtentProtoType;

  /// The widget to place inside the [SliverPinnedPersistentHeader].
  ///
  /// The `context` is the [BuildContext] of the sliver.
  ///
  /// The `shrinkOffset` is a distance from [maxExtent] towards [minExtent]
  /// representing the current amount by which the sliver has been shrunk. When
  /// the `shrinkOffset` is zero, the contents will be rendered with a dimension
  /// of [maxExtent] in the main axis. When `shrinkOffset` equals the difference
  /// between [maxExtent] and [minExtent] (a positive number), the contents will
  /// be rendered with a dimension of [minExtent] in the main axis. The
  /// `shrinkOffset` will always be a positive number in that range.
  ///
  /// The `overlapsContent` argument is true if subsequent slivers (if any) will
  /// be rendered beneath this one, and false if the sliver will not have any
  /// contents below it. Typically this is used to decide whether to draw a
  /// shadow to simulate the sliver being above the contents below it. Typically
  /// this is true when `shrinkOffset` is at its greatest value and false
  /// otherwise, but that is not guaranteed. See [NestedScrollView] for an
  /// example of a case where `overlapsContent`'s value can be unrelated to
  /// `shrinkOffset`.
  ///
  /// The 'minExtent'is the smallest size to allow the header to reach, when it shrinks at the
  /// start of the viewport.
  ///
  /// This must return a value equal to or less than [maxExtent].
  ///
  /// This value should not change over the lifetime of the delegate. It should
  /// be based entirely on the constructor arguments passed to the delegate. See
  /// [shouldRebuild], which must return true if a new delegate would return a
  /// different value.
  ///
  ///
  /// The `maxExtent` argument is the size of the header when it is not shrinking at the top of the
  /// viewport.
  ///
  /// This must return a value equal to or greater than [minExtent].
  ///
  /// This value should not change over the lifetime of the delegate. It should
  /// be based entirely on the constructor arguments passed to the delegate. See
  /// [shouldRebuild], which must return true if a new delegate would return a
  /// different value.
  Widget build(BuildContext context, double shrinkOffset, double? minExtent,
      double maxExtent, bool overlapsContent);

  /// Whether this delegate is meaningfully different from the old delegate.
  ///
  /// If this returns false, then the header might not be rebuilt, even though
  /// the instance of the delegate changed.
  ///
  /// This must return true if `oldDelegate` and this object would return
  /// different values for [minExtent], [maxExtent], [snapConfiguration], or
  /// would return a meaningfully different widget tree from [build] for the
  /// same arguments.
  bool shouldRebuild(
      covariant SliverFloatingPinnedPersistentHeaderDelegate oldDelegate);
}

class SliverFloatingPinnedPersistentHeader extends StatelessWidget {
  const SliverFloatingPinnedPersistentHeader({required this.delegate});

  final SliverFloatingPinnedPersistentHeaderDelegate delegate;

  @override
  Widget build(BuildContext context) {
    return SliverFloatingPinnedPersistentHeaderRenderObjectWidget(delegate);
  }
}

class SliverFloatingPersistentHeaderRenderObjectWidget
    extends RenderObjectWidget {
  const SliverFloatingPersistentHeaderRenderObjectWidget(this.delegate);

  final SliverFloatingPinnedPersistentHeaderDelegate delegate;

  @override
  RenderObjectElement createElement() {
    return SliverFloatingPersistentHeaderElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverFloatingPersistentHeader();
  }
}

class SliverFloatingPinnedPersistentHeaderRenderObjectWidget
    extends SliverFloatingPersistentHeaderRenderObjectWidget {
  const SliverFloatingPinnedPersistentHeaderRenderObjectWidget(
      SliverFloatingPinnedPersistentHeaderDelegate delegate)
      : super(delegate);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverFloatingPinnedPersistentHeader();
  }
}
