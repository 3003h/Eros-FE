import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Margin on top of the list section. This was eyeballed from iOS 14.4 Simulator
// and should be always present on top of the edge-to-edge variant.
const double _kMarginTop = 22.0;

// Standard header margin, determined from SwiftUI's Forms in iOS 14.2 SDK.
const EdgeInsetsDirectional _kDefaultHeaderMargin =
    EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 6.0);

// Header margin for inset grouped variant, determined from iOS 14.4 Simulator.
const EdgeInsetsDirectional _kInsetGroupedDefaultHeaderMargin =
    EdgeInsetsDirectional.fromSTEB(40.0, 16.0, 40.0, 6.0);

// Standard footer margin, determined from SwiftUI's Forms in iOS 14.2 SDK.
const EdgeInsetsDirectional _kDefaultFooterMargin =
    EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0);

// Footer margin for inset grouped variant, determined from iOS 14.4 Simulator.
const EdgeInsetsDirectional _kInsetGroupedDefaultFooterMargin =
    EdgeInsetsDirectional.fromSTEB(40.0, 0.0, 40.0, 10.0);

// Margin around children in edge-to-edge variant, determined from iOS 14.4
// Simulator.
const EdgeInsets _kDefaultRowsMargin = EdgeInsets.only(bottom: 8.0);

// Used for iOS "Inset Grouped" margin, determined from SwiftUI's Forms in
// iOS 14.2 SDK.
const EdgeInsetsDirectional _kDefaultInsetGroupedRowsMargin =
    EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 10.0);

// Used for iOS "Inset Grouped" margin, determined from SwiftUI's Forms in
// iOS 14.2 SDK.
const EdgeInsetsDirectional _kDefaultInsetGroupedRowsMarginWithHeader =
    EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 10.0);

// Used for iOS "Inset Grouped" border radius, estimated from SwiftUI's Forms in
// iOS 14.2 SDK.
// TODO(edrisian): This should be a rounded rectangle once that shape is added.
const BorderRadius _kDefaultInsetGroupedBorderRadius =
    BorderRadius.all(Radius.circular(10.0));

const BorderRadius _kDefaultTopInsetGroupedBorderRadius = BorderRadius.only(
  topLeft: Radius.circular(10.0),
  topRight: Radius.circular(10.0),
);

const BorderRadius _kDefaultBottomInsetGroupedBorderRadius = BorderRadius.only(
  bottomLeft: Radius.circular(10.0),
  bottomRight: Radius.circular(10.0),
);

// The margin of divider used in base list section. Estimated from iOS 14.4 SDK
// Settings app.
const double _kBaseDividerMargin = 20.0;

// Additional margin of divider used in base list section with list tiles with
// leading widgets. Estimated from iOS 14.4 SDK Settings app.
const double _kBaseAdditionalDividerMargin = 44.0;

// The margin of divider used in inset grouped version of list section.
// Estimated from iOS 14.4 SDK Reminders app.
const double _kInsetDividerMargin = 14.0;

// Additional margin of divider used in inset grouped version of list section.
// Estimated from iOS 14.4 SDK Reminders app.
const double _kInsetAdditionalDividerMargin = 42.0;

// Additional margin of divider used in inset grouped version of list section
// when there is no leading widgets. Estimated from iOS 14.4 SDK Notes app.
const double _kInsetAdditionalDividerMarginWithoutLeading = 6.0;

// Color of header and footer text in edge-to-edge variant.
const Color _kHeaderFooterColor = CupertinoDynamicColor(
  color: Color.fromRGBO(108, 108, 108, 1.0),
  darkColor: Color.fromRGBO(142, 142, 146, 1.0),
  highContrastColor: Color.fromRGBO(74, 74, 77, 1.0),
  darkHighContrastColor: Color.fromRGBO(176, 176, 183, 1.0),
  elevatedColor: Color.fromRGBO(108, 108, 108, 1.0),
  darkElevatedColor: Color.fromRGBO(142, 142, 146, 1.0),
  highContrastElevatedColor: Color.fromRGBO(108, 108, 108, 1.0),
  darkHighContrastElevatedColor: Color.fromRGBO(142, 142, 146, 1.0),
);

enum SliverCupertinoListSectionType {
  /// A basic form of [CupertinoListSection].
  base,

  /// An inset-grouped style of [CupertinoListSection].
  insetGrouped,
}

class SliverCupertinoListSection extends StatelessWidget {
  const SliverCupertinoListSection({
    super.key,
    required this.delegate,
    required this.itemCount,
    this.header,
    this.footer,
    this.margin = _kDefaultRowsMargin,
    this.backgroundColor = CupertinoColors.systemGroupedBackground,
    this.decoration,
    this.clipBehavior = Clip.none,
    this.dividerMargin = _kBaseDividerMargin,
    double? additionalDividerMargin,
    this.topMargin = _kMarginTop,
    bool hasLeading = true,
    this.separatorColor,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  })  : type = SliverCupertinoListSectionType.base,
        children = null,
        itemBuilder = null,
        additionalDividerMargin = additionalDividerMargin ??
            (hasLeading ? _kBaseAdditionalDividerMargin : 0.0);

  const SliverCupertinoListSection.base({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.header,
    this.footer,
    this.margin = _kDefaultRowsMargin,
    this.backgroundColor = CupertinoColors.systemGroupedBackground,
    this.decoration,
    this.clipBehavior = Clip.hardEdge,
    this.dividerMargin = _kInsetDividerMargin,
    double? additionalDividerMargin,
    this.topMargin,
    bool hasLeading = true,
    this.separatorColor,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  })  : type = SliverCupertinoListSectionType.base,
        children = null,
        delegate = null,
        additionalDividerMargin = additionalDividerMargin ??
            (hasLeading
                ? _kInsetAdditionalDividerMargin
                : _kInsetAdditionalDividerMarginWithoutLeading);

  const SliverCupertinoListSection.insetGrouped({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.header,
    this.footer,
    EdgeInsetsGeometry? margin,
    this.backgroundColor = CupertinoColors.systemGroupedBackground,
    this.decoration,
    this.clipBehavior = Clip.hardEdge,
    this.dividerMargin = _kInsetDividerMargin,
    double? additionalDividerMargin,
    this.topMargin,
    bool hasLeading = false,
    this.separatorColor,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  })  : type = SliverCupertinoListSectionType.insetGrouped,
        children = null,
        delegate = null,
        additionalDividerMargin = additionalDividerMargin ??
            (hasLeading
                ? _kInsetAdditionalDividerMargin
                : _kInsetAdditionalDividerMarginWithoutLeading),
        margin = margin ??
            (header == null
                ? _kDefaultInsetGroupedRowsMargin
                : _kDefaultInsetGroupedRowsMarginWithHeader);

  const SliverCupertinoListSection.listInsetGrouped({
    super.key,
    required List<Widget> this.children,
    this.header,
    this.footer,
    EdgeInsetsGeometry? margin,
    this.backgroundColor = CupertinoColors.systemGroupedBackground,
    this.decoration,
    this.clipBehavior = Clip.hardEdge,
    this.dividerMargin = _kInsetDividerMargin,
    double? additionalDividerMargin,
    this.topMargin,
    this.separatorColor,
    bool hasLeading = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  })  : type = SliverCupertinoListSectionType.insetGrouped,
        itemBuilder = null,
        itemCount = children.length,
        delegate = null,
        additionalDividerMargin = additionalDividerMargin ??
            (hasLeading
                ? _kInsetAdditionalDividerMargin
                : _kInsetAdditionalDividerMarginWithoutLeading),
        margin = margin ??
            (header == null
                ? _kDefaultInsetGroupedRowsMargin
                : _kDefaultInsetGroupedRowsMarginWithHeader);

  final SliverChildDelegate? delegate;

  /// {@macro flutter.widgets.SliverChildBuilderDelegate.addAutomaticKeepAlives}
  final bool addAutomaticKeepAlives;

  /// {@macro flutter.widgets.SliverChildBuilderDelegate.addRepaintBoundaries}
  final bool addRepaintBoundaries;

  /// {@macro flutter.widgets.SliverChildBuilderDelegate.addSemanticIndexes}
  final bool addSemanticIndexes;

  /// The type of list section, either base or inset grouped.
  ///
  /// This member is public for testing purposes only and cannot be set
  /// manually. Instead, use a corresponding constructors.
  @visibleForTesting
  final SliverCupertinoListSectionType type;

  /// Sets the form section header. The section header lies above the [children]
  /// rows. Usually a [Text] widget.
  final Widget? header;

  /// Sets the form section footer. The section footer lies below the [children]
  /// rows. Usually a [Text] widget.
  final Widget? footer;

  /// Margin around the content area of the section encapsulating [children].
  ///
  /// Defaults to zero padding if constructed with standard
  /// [CupertinoListSection] constructor. Defaults to the standard notched-style
  /// iOS margin when constructing with [CupertinoListSection.insetGrouped].
  final EdgeInsetsGeometry margin;

  /// The list of rows in the section. Usually a list of [CupertinoListTile]s.
  ///
  /// This takes a list, as opposed to a more efficient builder function that
  /// lazy builds, because such lists are intended to be short in row count.
  /// It is recommended that only [CupertinoListTile] widget be included in the
  /// [children] list in order to retain the iOS look.

  // final List<Widget>? children;

  /// Sets the decoration around [children].
  ///
  /// If null, background color defaults to
  /// [CupertinoColors.secondarySystemGroupedBackground].
  ///
  /// If null, border radius defaults to 10.0 circular radius when constructing
  /// with [SliverCupertinoListSection.insetGrouped]. Defaults to zero radius for the
  /// standard [CupertinoListSection] constructor.
  final BoxDecoration? decoration;

  /// Sets the background color behind the section.
  ///
  /// Defaults to [CupertinoColors.systemGroupedBackground].
  final Color backgroundColor;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// The starting offset of a margin between two list tiles.
  final double dividerMargin;

  /// Additional starting inset of the divider used between rows. This is used
  /// when adding a leading icon to children and a divider should start at the
  /// text inset instead of the icon.
  final double additionalDividerMargin;

  /// Margin above the list section. Only used in edge-to-edge variant and it
  /// matches iOS style by default.
  final double? topMargin;

  /// Sets the color for the dividers between rows, and borders on top and
  /// bottom of the rows.
  ///
  /// If null, defaults to [CupertinoColors.separator].
  final Color? separatorColor;

  final List<Widget>? children;

  final NullableIndexedWidgetBuilder? itemBuilder;

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final Color dividerColor =
        separatorColor ?? CupertinoColors.separator.resolveFrom(context);
    final double dividerHeight = 1.0 / MediaQuery.devicePixelRatioOf(context);

    SliverChildDelegate? _delegate = delegate;

    // Long divider is used for wrapping the top and bottom of rows.
    // Only used in SliverCupertinoListSectionType.base mode.
    final Widget longDivider = Container(
      color: dividerColor,
      height: dividerHeight,
    );

    // Short divider is used between rows.
    final Widget shortDivider = Container(
      margin: EdgeInsetsDirectional.only(
          start: dividerMargin + additionalDividerMargin),
      color: dividerColor,
      height: dividerHeight,
    );

    Widget? headerWidget;
    if (header != null) {
      // headerWidget = DefaultTextStyle(
      //   style: CupertinoTheme.of(context).textTheme.textStyle.merge(
      //         type == SliverCupertinoListSectionType.base
      //             ? TextStyle(
      //                 fontSize: 13.0,
      //                 color: CupertinoDynamicColor.resolve(
      //                     _kHeaderFooterColor, context))
      //             : const TextStyle(
      //                 fontSize: 20.0, fontWeight: FontWeight.bold),
      //       ),
      //   child: header!,
      // );
      headerWidget = DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle.merge(
              TextStyle(
                  fontSize: 13.0,
                  color: CupertinoDynamicColor.resolve(
                      _kHeaderFooterColor, context)),
            ),
        child: header!,
      );
    }

    Widget? footerWidget;
    if (footer != null) {
      // footerWidget = DefaultTextStyle(
      //   style: type == SliverCupertinoListSectionType.base
      //       ? CupertinoTheme.of(context).textTheme.textStyle.merge(TextStyle(
      //             fontSize: 13.0,
      //             color: CupertinoDynamicColor.resolve(
      //                 _kHeaderFooterColor, context),
      //           ))
      //       : CupertinoTheme.of(context).textTheme.textStyle,
      //   child: footer!,
      // );
      footerWidget = DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle.merge(TextStyle(
              fontSize: 13.0,
              color:
                  CupertinoDynamicColor.resolve(_kHeaderFooterColor, context),
            )),
        child: footer!,
      );
    }

    if (type == SliverCupertinoListSectionType.insetGrouped &&
        children != null &&
        children!.isNotEmpty) {
      final List<Widget> childrenWithDividers = <Widget>[];

      for (int i = 0; i < children!.length; i++) {
        final BorderRadius childrenGroupBorderRadius = () {
          if (children!.length == 1) {
            return _kDefaultInsetGroupedBorderRadius;
          } else if (i == 0) {
            return _kDefaultTopInsetGroupedBorderRadius;
          } else if (i == children!.length - 1) {
            return _kDefaultBottomInsetGroupedBorderRadius;
          } else {
            return BorderRadius.zero;
          }
        }();

        childrenWithDividers.add(ClipRRect(
          borderRadius: childrenGroupBorderRadius,
          child: children![i],
        ));
        if (i != children!.length - 1) {
          childrenWithDividers.add(shortDivider);
        }
      }

      _delegate = SliverChildListDelegate(
        childrenWithDividers,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
      );
    }

    if ((type == SliverCupertinoListSectionType.base ||
            type == SliverCupertinoListSectionType.insetGrouped) &&
        itemBuilder != null) {
      _delegate = SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final int itemIndex = index ~/ 2;
          final Widget? widget;
          if (index.isEven) {
            if (type == SliverCupertinoListSectionType.insetGrouped) {
              final BorderRadius childrenGroupBorderRadius = () {
                if (itemCount == 1) {
                  return _kDefaultInsetGroupedBorderRadius;
                } else if (index == 0) {
                  return _kDefaultTopInsetGroupedBorderRadius;
                } else if (index == itemCount * 2 - 2) {
                  return _kDefaultBottomInsetGroupedBorderRadius;
                } else {
                  return BorderRadius.zero;
                }
              }();

              widget = ClipRRect(
                borderRadius: childrenGroupBorderRadius,
                child: itemBuilder!(context, itemIndex),
              );
            } else {
              widget = itemBuilder!(context, itemIndex);
            }
          } else {
            widget = shortDivider;
            assert(() {
              if (widget == null) {
                throw FlutterError('separatorBuilder cannot return null.');
              }
              return true;
            }());
          }
          return widget;
        },
        childCount: math.max(0, itemCount * 2 - 1),
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        semanticIndexCallback: (Widget _, int index) {
          return index.isEven ? index ~/ 2 : null;
        },
      );
    }

    Widget? sliverDecoratedChildrenGroup;
    if (_delegate != null) {
      sliverDecoratedChildrenGroup = SliverList(
        delegate: _delegate,
      );

      final BorderRadius childrenGroupBorderRadius = switch (type) {
        SliverCupertinoListSectionType.insetGrouped =>
          _kDefaultInsetGroupedBorderRadius,
        SliverCupertinoListSectionType.base => BorderRadius.zero,
      };

      sliverDecoratedChildrenGroup = DecoratedSliver(
        decoration: decoration ??
            BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                  decoration?.color ??
                      CupertinoColors.secondarySystemGroupedBackground,
                  context),
              borderRadius: childrenGroupBorderRadius,
            ),
        sliver: MultiSliver(
          children: [
            if (type == SliverCupertinoListSectionType.base) longDivider,
            sliverDecoratedChildrenGroup,
            if (type == SliverCupertinoListSectionType.base) longDivider,
          ],
        ),
      );

      sliverDecoratedChildrenGroup = SliverPadding(
        padding: margin,
        sliver: clipBehavior == Clip.none
            ? sliverDecoratedChildrenGroup
            : DecoratedSliver(
                sliver: sliverDecoratedChildrenGroup,
                decoration: BoxDecoration(
                  borderRadius: childrenGroupBorderRadius,
                ),
              ),
      );
    }

    return DecoratedSliver(
      decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(backgroundColor, context)),
      sliver: MultiSliver(
        children: <Widget>[
          if (type == SliverCupertinoListSectionType.base)
            SizedBox(height: topMargin),
          if (headerWidget != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: type == SliverCupertinoListSectionType.base
                    ? _kDefaultHeaderMargin
                    : _kInsetGroupedDefaultHeaderMargin,
                child: headerWidget,
              ),
            ),
          if (sliverDecoratedChildrenGroup != null)
            sliverDecoratedChildrenGroup,
          if (footerWidget != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: type == SliverCupertinoListSectionType.base
                    ? _kDefaultFooterMargin
                    : _kInsetGroupedDefaultFooterMargin,
                child: footerWidget,
              ),
            ),
        ],
      ),
    );
  }
}
