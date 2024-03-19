import 'package:eros_fe/utils/cust_lib/sliver/sliver_persistent_header.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';

class PersistentHeaderBuilder extends SliverPersistentHeaderDelegate {
  PersistentHeaderBuilder({
    this.max = 120,
    this.min = 80,
    required this.builder,
  }) : assert(max >= min);
  final double max;
  final double min;
  final Widget Function(BuildContext context, double offset) builder;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return builder(context, shrinkOffset);
  }

  @override
  double get maxExtent => max;

  @override
  double get minExtent => min;

  @override
  bool shouldRebuild(covariant PersistentHeaderBuilder oldDelegate) =>
      max != oldDelegate.max ||
      min != oldDelegate.min ||
      builder != oldDelegate.builder;
}

class SliverPinnedPersistentHeaderBuilder
    extends SliverPinnedPersistentHeaderDelegate {
  SliverPinnedPersistentHeaderBuilder({
    required Widget minExtentProtoType,
    required Widget maxExtentProtoType,
    required this.builder,
  }) : super(
            minExtentProtoType: minExtentProtoType,
            maxExtentProtoType: maxExtentProtoType);

  final Widget Function(BuildContext context, double offset, double? maxExtent)
      builder;

  @override
  Widget build(BuildContext context, double shrinkOffset, double? minExtent,
      double maxExtent, bool overlapsContent) {
    return builder(context, shrinkOffset, maxExtent);
  }

  @override
  bool shouldRebuild(
      covariant SliverPinnedPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class SliverFloatingPinnedPersistentHeaderBuilder
    extends SliverFloatingPinnedPersistentHeaderDelegate {
  SliverFloatingPinnedPersistentHeaderBuilder({
    required Widget minExtentProtoType,
    required Widget maxExtentProtoType,
    required this.builder,
  }) : super(
            minExtentProtoType: minExtentProtoType,
            maxExtentProtoType: maxExtentProtoType);

  final Widget Function(BuildContext context, double offset, double maxExtent)
      builder;

  @override
  Widget build(BuildContext context, double shrinkOffset, double? minExtent,
      double maxExtent, bool overlapsContent) {
    return builder(context, shrinkOffset, maxExtent);
  }

  @override
  bool shouldRebuild(
      covariant SliverFloatingPinnedPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
