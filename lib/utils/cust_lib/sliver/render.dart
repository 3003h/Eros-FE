import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'element.dart';

class RenderSliverFloatingPinnedPersistentHeader
    extends RenderSliverFloatingPersistentHeader {
  RenderSliverFloatingPinnedPersistentHeader({
    super.child,
    super.minProtoType,
    super.maxProtoType,
  });

  @override
  double updateGeometry() {
    final double minExtent = this.minExtent;
    final double minAllowedExtent = constraints.remainingPaintExtent > minExtent
        ? minExtent
        : constraints.remainingPaintExtent;
    final double maxExtent = this.maxExtent;
    final double paintExtent = maxExtent - _effectiveScrollOffset!;
    final double clampedPaintExtent = paintExtent.clamp(
      minAllowedExtent,
      constraints.remainingPaintExtent,
    );
    final double layoutExtent = maxExtent - constraints.scrollOffset;
    final double stretchOffset =
        stretchConfiguration != null ? constraints.overlap.abs() : 0.0;
    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: math.min(constraints.overlap, 0.0),
      paintExtent: clampedPaintExtent,
      layoutExtent: layoutExtent.clamp(0.0, clampedPaintExtent),
      maxPaintExtent: maxExtent + stretchOffset,
      maxScrollObstructionExtent: minExtent,
      hasVisualOverflow:
          true, // Conservatively say we do have overflow to avoid complexity.
    );
    return 0.0;
  }
}

class RenderSliverFloatingPersistentHeader extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox>, RenderSliverHelpers {
  RenderSliverFloatingPersistentHeader({
    RenderBox? child,
    RenderBox? minProtoType,
    RenderBox? maxProtoType,
  })  : _minProtoType = minProtoType,
        _maxProtoType = maxProtoType {
    this.child = child;
  }

  RenderBox? _minProtoType;

  RenderBox? get minProtoType => _minProtoType;

  set minProtoType(RenderBox? value) {
    if (_minProtoType != null) {
      dropChild(_minProtoType!);
    }
    _minProtoType = value;
    if (_minProtoType != null) {
      adoptChild(_minProtoType!);
    }
    markNeedsLayout();
  }

  RenderBox? _maxProtoType;

  RenderBox? get maxProtoType => _maxProtoType;

  set maxProtoType(RenderBox? value) {
    if (_maxProtoType != null) {
      dropChild(_maxProtoType!);
    }
    _maxProtoType = value;
    if (_maxProtoType != null) {
      adoptChild(_maxProtoType!);
    }
    markNeedsLayout();
  }

  late double _lastStretchOffset;

  double get minExtent => getChildExtend(minProtoType, constraints);

  double get maxExtent => getChildExtend(maxProtoType, constraints);

  /// The dimension of the child in the main axis.
  @protected
  double get childExtent {
    if (child == null) {
      return 0.0;
    }
    assert(child!.hasSize);
    switch (constraints.axis) {
      case Axis.vertical:
        return child!.size.height;
      case Axis.horizontal:
        return child!.size.width;
    }
  }

  bool _needsUpdateChild = true;
  double _lastShrinkOffset = 0.0;
  bool _lastOverlapsContent = false;

  OverScrollHeaderStretchConfiguration? stretchConfiguration;

  // @protected
  // void updateChild(double shrinkOffset, bool overlapsContent) {}
  void updateChild(double shrinkOffset, double? minExtent, double maxExtent,
      bool overlapsContent) {
    assert(element != null);
    element!.build(shrinkOffset, minExtent, maxExtent, overlapsContent);
  }

  @override
  void markNeedsLayout() {
    // This is automatically called whenever the child's intrinsic dimensions
    // change, at which point we should remeasure them during the next layout.
    _needsUpdateChild = true;
    super.markNeedsLayout();
  }

  /// Lays out the [child].
  ///
  /// This is called by [performLayout]. It applies the given `scrollOffset`
  /// (which need not match the offset given by the [constraints]) and the
  /// `maxExtent` (which need not match the value returned by the [maxExtent]
  /// getter).
  ///
  /// The `overlapsContent` argument is passed to [updateChild].
  @protected
  void layoutChild(double scrollOffset, double maxExtent,
      {bool overlapsContent = false}) {
    final double shrinkOffset = math.min(scrollOffset, maxExtent);
    if (_needsUpdateChild ||
        _lastShrinkOffset != shrinkOffset ||
        _lastOverlapsContent != overlapsContent) {
      invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
        assert(constraints == this.constraints);
        // updateChild(shrinkOffset, overlapsContent);
        updateChild(shrinkOffset, minExtent, maxExtent, overlapsContent);
      });
      _lastShrinkOffset = shrinkOffset;
      _lastOverlapsContent = overlapsContent;
      _needsUpdateChild = false;
    }
    assert(() {
      if (minExtent <= maxExtent) return true;
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
            'The maxExtent for this $runtimeType is less than its minExtent.'),
        DoubleProperty('The specified maxExtent was', maxExtent),
        DoubleProperty('The specified minExtent was', minExtent),
      ]);
    }());
    double stretchOffset = 0.0;
    if (stretchConfiguration != null && constraints.scrollOffset == 0.0) {
      stretchOffset += constraints.overlap.abs();
    }

    child?.layout(
      constraints.asBoxConstraints(
        maxExtent:
            math.max(minExtent, maxExtent - shrinkOffset) + stretchOffset,
      ),
      parentUsesSize: true,
    );

    if (stretchConfiguration != null &&
        stretchConfiguration!.onStretchTrigger != null &&
        stretchOffset >= stretchConfiguration!.stretchTriggerOffset &&
        _lastStretchOffset <= stretchConfiguration!.stretchTriggerOffset) {
      stretchConfiguration!.onStretchTrigger!();
    }
    _lastStretchOffset = stretchOffset;
  }

  AnimationController? _controller;
  late Animation<double> _animation;
  double? _lastActualScrollOffset;
  double? _effectiveScrollOffset;

  double? _childPosition;

  /// A [TickerProvider] to use when animating the scroll position.
  TickerProvider? get vsync => _vsync;
  TickerProvider? _vsync;

  set vsync(TickerProvider? value) {
    if (value == _vsync) return;
    _vsync = value;
    if (value == null) {
      _controller?.dispose();
      _controller = null;
    } else {
      _controller?.resync(value);
    }
  }

  /// Defines the parameters used to snap (animate) the floating header in and
  /// out of view.
  ///
  /// If [snapConfiguration] is null then the floating header does not snap.
  ///
  /// See also:
  ///
  ///  * [RenderSliverFloatingPersistentHeader.maybeStartSnapAnimation] and
  ///    [RenderSliverFloatingPersistentHeader.maybeStopSnapAnimation], which
  ///    start or stop the floating header's animation.
  ///  * [SliverAppBar], which creates a header that can be pinned, floating,
  ///    and snapped into view via the corresponding parameters.
  FloatingHeaderSnapConfiguration? snapConfiguration;

  /// {@macro flutter.rendering.PersistentHeaderShowOnScreenConfiguration}
  ///
  /// If set to null, the persistent header will delegate the `showOnScreen` call
  /// to it's parent [RenderObject].
  PersistentHeaderShowOnScreenConfiguration? showOnScreenConfiguration;

  /// Updates [geometry], and returns the new value for [childMainAxisPosition].
  ///
  /// This is used by [performLayout].
  @protected
  double updateGeometry() {
    double stretchOffset = 0.0;
    if (stretchConfiguration != null && _childPosition == 0.0) {
      stretchOffset += constraints.overlap.abs();
    }
    final double maxExtent = this.maxExtent;
    final double paintExtent = maxExtent - _effectiveScrollOffset!;
    final double layoutExtent = maxExtent - constraints.scrollOffset;
    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: math.min(constraints.overlap, 0.0),
      paintExtent: paintExtent.clamp(0.0, constraints.remainingPaintExtent),
      layoutExtent: layoutExtent.clamp(0.0, constraints.remainingPaintExtent),
      maxPaintExtent: maxExtent + stretchOffset,
      hasVisualOverflow:
          true, // Conservatively say we do have overflow to avoid complexity.
    );
    return stretchOffset > 0 ? 0.0 : math.min(0.0, paintExtent - childExtent);
  }

  void _updateAnimation(Duration duration, double endValue, Curve curve) {
    assert(
      vsync != null,
      'vsync must not be null if the floating header changes size animatedly.',
    );

    final AnimationController effectiveController =
        _controller ??= AnimationController(vsync: vsync!, duration: duration)
          ..addListener(() {
            if (_effectiveScrollOffset == _animation.value) return;
            _effectiveScrollOffset = _animation.value;
            markNeedsLayout();
          });

    _animation = effectiveController.drive(
      Tween<double>(
        begin: _effectiveScrollOffset,
        end: endValue,
      ).chain(CurveTween(curve: curve)),
    );
  }

  /// If the header isn't already fully exposed, then scroll it into view.
  void maybeStartSnapAnimation(ScrollDirection direction) {
    final FloatingHeaderSnapConfiguration? snap = snapConfiguration;
    if (snap == null) return;
    if (direction == ScrollDirection.forward && _effectiveScrollOffset! <= 0.0)
      return;
    if (direction == ScrollDirection.reverse &&
        _effectiveScrollOffset! >= maxExtent) return;

    _updateAnimation(
      snap.duration,
      direction == ScrollDirection.forward ? 0.0 : maxExtent,
      snap.curve,
    );
    _controller?.forward(from: 0.0);
  }

  /// If a header snap animation or a [showOnScreen] expand animation is underway
  /// then stop it.
  void maybeStopSnapAnimation(ScrollDirection direction) {
    _controller?.stop();
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    minProtoType!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    maxProtoType!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double maxExtent = this.maxExtent;
    if (_lastActualScrollOffset !=
            null && // We've laid out at least once to get an initial position, and either
        ((constraints.scrollOffset <
                _lastActualScrollOffset!) || // we are scrolling back, so should reveal, or
            (_effectiveScrollOffset! < maxExtent))) {
      // some part of it is visible, so should shrink or reveal as appropriate.
      double delta = _lastActualScrollOffset! - constraints.scrollOffset;

      final bool allowFloatingExpansion =
          constraints.userScrollDirection == ScrollDirection.forward;
      if (allowFloatingExpansion) {
        if (_effectiveScrollOffset! >
            maxExtent) // We're scrolled off-screen, but should reveal, so
          _effectiveScrollOffset =
              maxExtent; // pretend we're just at the limit.
      } else {
        if (delta >
            0.0) // If we are trying to expand when allowFloatingExpansion is false,
          delta =
              0.0; // disallow the expansion. (But allow shrinking, i.e. delta < 0.0 is fine.)
      }
      _effectiveScrollOffset = (_effectiveScrollOffset! - delta)
          .clamp(0.0, constraints.scrollOffset);
    } else {
      _effectiveScrollOffset = constraints.scrollOffset;
    }
    final bool overlapsContent =
        _effectiveScrollOffset! < constraints.scrollOffset;

    layoutChild(
      _effectiveScrollOffset!,
      maxExtent,
      overlapsContent: overlapsContent,
    );
    _childPosition = updateGeometry();
    _lastActualScrollOffset = constraints.scrollOffset;
  }

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    final PersistentHeaderShowOnScreenConfiguration? showOnScreen =
        showOnScreenConfiguration;
    if (showOnScreen == null) {
      return super.showOnScreen(
          descendant: descendant, rect: rect, duration: duration, curve: curve);
    }

    assert(child != null || descendant == null);
    // We prefer the child's coordinate space (instead of the sliver's) because
    // it's easier for us to convert the target rect into target extents: when
    // the sliver is sitting above the leading edge (not possible with pinned
    // headers), the leading edge of the sliver and the leading edge of the child
    // will not be aligned. The only exception is when child is null (and thus
    // descendant == null).
    final Rect? childBounds = descendant != null
        ? MatrixUtils.transformRect(
            descendant.getTransformTo(child), rect ?? descendant.paintBounds)
        : rect;

    double targetExtent;
    Rect? targetRect;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        targetExtent = childExtent - (childBounds?.top ?? 0);
        targetRect = _trim(childBounds, bottom: childExtent);
        break;
      case AxisDirection.right:
        targetExtent = childBounds?.right ?? childExtent;
        targetRect = _trim(childBounds, left: 0);
        break;
      case AxisDirection.down:
        targetExtent = childBounds?.bottom ?? childExtent;
        targetRect = _trim(childBounds, top: 0);
        break;
      case AxisDirection.left:
        targetExtent = childExtent - (childBounds?.left ?? 0);
        targetRect = _trim(childBounds, right: childExtent);
        break;
    }

    // A stretch header can have a bigger childExtent than maxExtent.
    final double effectiveMaxExtent = math.max(childExtent, maxExtent);

    targetExtent = targetExtent
        .clamp(
          showOnScreen.minShowOnScreenExtent,
          showOnScreen.maxShowOnScreenExtent,
        )
        // Clamp the value back to the valid range after applying additional
        // constriants. Contracting is not allowed.
        .clamp(childExtent, effectiveMaxExtent);

    // Expands the header if needed, with animation.
    if (targetExtent > childExtent) {
      final double targetScrollOffset = maxExtent - targetExtent;
      assert(
        vsync != null,
        'vsync must not be null if the floating header changes size animatedly.',
      );
      _updateAnimation(duration, targetScrollOffset, curve);
      _controller?.forward(from: 0.0);
    }

    super.showOnScreen(
      descendant: descendant == null ? this : child,
      rect: targetRect,
      duration: duration,
      curve: curve,
    );
  }

  @override
  double childMainAxisPosition(covariant RenderObject? child) {
    assert(child == this.child);
    return _childPosition ?? 0.0;
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    assert(geometry!.hitTestExtent > 0.0);
    if (child != null) {
      return hitTestBoxChild(BoxHitTestResult.wrap(result), child!,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition);
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    if (child != minProtoType && child != maxProtoType) {
      applyPaintTransformForBoxChild(child as RenderBox, transform);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      switch (applyGrowthDirectionToAxisDirection(
          constraints.axisDirection, constraints.growthDirection)) {
        case AxisDirection.up:
          offset += Offset(
              0.0,
              geometry!.paintExtent -
                  childMainAxisPosition(child) -
                  childExtent);
          break;
        case AxisDirection.down:
          offset += Offset(0.0, childMainAxisPosition(child));
          break;
        case AxisDirection.left:
          offset += Offset(
              geometry!.paintExtent -
                  childMainAxisPosition(child) -
                  childExtent,
              0.0);
          break;
        case AxisDirection.right:
          offset += Offset(childMainAxisPosition(child), 0.0);
          break;
      }
      context.paintChild(child!, offset);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DoubleProperty('effective scroll offset', _effectiveScrollOffset));
  }

  SliverFloatingPersistentHeaderElement? element;

  void triggerRebuild() {
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_minProtoType != null) {
      _minProtoType!.attach(owner);
    }
    if (_maxProtoType != null) {
      _maxProtoType!.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();
    if (_minProtoType != null) {
      _minProtoType!.detach();
    }
    if (_maxProtoType != null) {
      _maxProtoType!.detach();
    }
  }

  @override
  void redepthChildren() {
    if (_minProtoType != null) {
      redepthChild(_minProtoType!);
    }
    if (_maxProtoType != null) {
      redepthChild(_maxProtoType!);
    }
    super.redepthChildren();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    if (_minProtoType != null) {
      visitor(_minProtoType!);
    }
    if (_maxProtoType != null) {
      visitor(_maxProtoType!);
    }
  }
}

/// A pinned [RenderSliver] that contains a single [RenderBox].
class RenderSliverPinnedToBoxAdapter extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliver] that wraps a [RenderBox].
  RenderSliverPinnedToBoxAdapter({
    super.child,
  });

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    assert(childExtent != null);
    final double effectiveRemainingPaintExtent =
        math.max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent = (childExtent! - constraints.scrollOffset)
        .clamp(0.0, effectiveRemainingPaintExtent);

    geometry = SliverGeometry(
      scrollExtent: childExtent!,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent!, effectiveRemainingPaintExtent),
      layoutExtent: layoutExtent,
      maxPaintExtent: childExtent!,
      maxScrollObstructionExtent: childExtent!,
      cacheExtent: layoutExtent > 0.0
          ? -constraints.cacheOrigin + layoutExtent
          : layoutExtent,
      hasVisualOverflow:
          true, // Conservatively say we do have overflow to avoid complexity.
    );
    setChildParentData(child!, constraints, geometry);
  }

  @override
  void setChildParentData(RenderObject child, SliverConstraints constraints,
      SliverGeometry? geometry) {
    final SliverPhysicalParentData? childParentData =
        child.parentData as SliverPhysicalParentData?;
    Offset offset = Offset.zero;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        offset += Offset(
            0.0,
            geometry!.paintExtent -
                childMainAxisPosition(child as RenderBox) -
                childExtent!);
        break;
      case AxisDirection.down:
        offset += Offset(0.0, childMainAxisPosition(child as RenderBox));
        break;
      case AxisDirection.left:
        offset += Offset(
            geometry!.paintExtent -
                childMainAxisPosition(child as RenderBox) -
                childExtent!,
            0.0);
        break;
      case AxisDirection.right:
        offset += Offset(childMainAxisPosition(child as RenderBox), 0.0);
        break;
    }
    childParentData!.paintOffset = offset;
  }

  @override
  double childMainAxisPosition(RenderBox child) => 0.0;

  double? get childExtent {
    return getChildExtend(child, constraints);
  }
}

double getChildExtend(RenderBox? child, SliverConstraints constraints) {
  if (child == null) {
    return 0.0;
  }
  assert(child.hasSize);
  switch (constraints.axis) {
    case Axis.vertical:
      return child.size.height;
    case Axis.horizontal:
      return child.size.width;
  }
}

Rect? _trim(
  Rect? original, {
  double top = -double.infinity,
  double right = double.infinity,
  double bottom = double.infinity,
  double left = -double.infinity,
}) =>
    original?.intersect(Rect.fromLTRB(left, top, right, bottom));
