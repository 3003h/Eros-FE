import 'dart:math';

import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

const kDuration = Duration(milliseconds: 300);
const double kDefIndicatorHeight = 4;

final LinkScrollBarController _defaultLinkScrollBarController =
    LinkScrollBarController();

class LinkTabItem {
  LinkTabItem({
    required this.title,
    this.icon,
    this.iconColor,
    this.actinos,
  });

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final List<LinkTabItemAction>? actinos;
}

class LinkTabItemAction {
  LinkTabItemAction({
    required this.actinoText,
    this.icon,
    this.onTap,
    this.color,
  });
  final String actinoText;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;
}

class LinkScrollBar extends StatefulWidget {
  LinkScrollBar({
    super.key,
    LinkScrollBarController? controller,
    this.pageController,
    required this.items,
    required this.initIndex,
    this.indicatorHeight = kDefIndicatorHeight,
    this.itemPadding = const EdgeInsets.only(left: 10, right: 10),
    this.onItemChange,
  }) : controller = controller ?? _defaultLinkScrollBarController;

  final List<LinkTabItem> items;
  final int initIndex;
  final double indicatorHeight;
  final EdgeInsetsGeometry itemPadding;
  final LinkScrollBarController controller;
  final ValueChanged<int>? onItemChange;
  final PageController? pageController;

  @override
  State<LinkScrollBar> createState() => _LinkScrollBarState();
}

class _LinkScrollBarState extends State<LinkScrollBar> {
  int selectIndex = 0;
  List<ItemFrame> channelFrameList = [];
  double _maxScrollViewWidth = 10;
  double _indicatorPositionedLeft = 0;
  double _indicatorWidth = 0.0;
  final ScrollController _scrollController = ScrollController();

  double boxWidth = 0.0;

  List<Widget> _getBarItems(BuildContext context, double boxWidth) {
    this.boxWidth = boxWidth;
    channelFrameList.clear();
    List<Widget> barItems = [];
    _maxScrollViewWidth = 0;

    for (int i = 0; i < widget.items.length; i++) {
      final barItem = NotificationListener<WSLGetWidgetWithNotification>(
        onNotification: (notification) {
          // logger.d('${notification.index}  ${notification.width}');
          if (channelFrameList.length == widget.items.length) {
            return true;
          }

          //这里接受item创建时发起的冒泡消息，目的是：此时，导航item的宽度已计算完毕，创建导航栏布局记录类，记录当前item距离左侧距离及宽度。
          ItemFrame itemFrame = ItemFrame(
            left: _maxScrollViewWidth,
            width: notification.width,
            index: notification.index,
          );

          //保存所有ChannelFrame值，以便当外部修改viewPage的index值时或者点击item时进行修改scrollview偏移量
          channelFrameList.add(itemFrame);

          _maxScrollViewWidth += notification.width;

          //返回 true 消息到此结束，不再继续往外传递
          return true;
        },
        child: Builder(builder: (context) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: InnerLinkTabItem(
              title: widget.items[i].title,
              icon: widget.items[i].icon,
              selected: i == selectIndex,
              padding: widget.itemPadding,
              index: i,
            ),
            onTap: () {
              widget.controller.disableScrollToItem();
              setState(() {
                selectIndex = i;
                // WSLCustomTabbarNotification(index: selectIndex).dispatch(context);
                scrollToItem(selectIndex);
                widget.onItemChange?.call(selectIndex);
              });
            },
            onLongPress: () async {
              if (widget.items[i].actinos == null) {
                return;
              }
              vibrateUtil.medium();
              logger.d('onLongPress $i');
              await showItemAttach(
                  margin: const EdgeInsets.only(
                      left: 10, right: 10, top: 10, bottom: 40),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items[i].actinos!
                          .map((e) => GestureDetector(
                                onTap: () {
                                  SmartDialog.dismiss();
                                  e.onTap?.call();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (e.icon != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12.0),
                                          child: Icon(
                                            e.icon,
                                            size: 16,
                                            color: e.color ??
                                                CupertinoDynamicColor.resolve(
                                                    CupertinoColors.label,
                                                    context),
                                          ),
                                        ),
                                      Text(
                                        e.actinoText,
                                        style: TextStyle(
                                            fontSize: 16, color: e.color),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  targetContext: context);
            },
          );
        }),
      );

      barItems.add(barItem);
    }
    return barItems;
  }

  void scrollToItem(int index) {
    ItemFrame channelFrame = channelFrameList[
        min(max(index, 0), max(channelFrameList.length - 1, 0))];

    _indicatorPositionedLeft =
        channelFrame.left + widget.itemPadding.horizontal / 2;
    _indicatorWidth = channelFrame.width - widget.itemPadding.horizontal;

    //计算选中的导航item的中心点
    double centerX = channelFrame.left + channelFrame.width / 2.0;
    //设定需要滚动的偏移量
    double needScrollView = 0;
    //当选中的导航item在中心偏左时
    if (centerX - _scrollController.offset < boxWidth / 2.0) {
      needScrollView = boxWidth / 2.0 - centerX + _scrollController.offset;
      //存在滚动条件
      if (_scrollController.offset > 0) {
        //当无法满足滚动到正中心的位置，就直接回到偏移量原点
        if (_scrollController.offset < needScrollView) {
          needScrollView = _scrollController.offset;
        }
        //进行偏移量动画滚动
        _scrollController.animateTo(_scrollController.offset - needScrollView,
            duration: kDuration, curve: Curves.ease);
      }
    } else {
      //当选中的导航item在中心偏右时
      needScrollView = centerX - _scrollController.offset - boxWidth / 2.0;
      if (_scrollController.position.maxScrollExtent -
              _scrollController.offset >
          0) {
        //不满足回滚到中间位置，设置为滚到最大位置
        if (_scrollController.position.maxScrollExtent -
                _scrollController.offset <
            needScrollView) {
          needScrollView = _scrollController.position.maxScrollExtent -
              _scrollController.offset;
        }
        _scrollController.animateTo(_scrollController.offset + needScrollView,
            duration: kDuration, curve: Curves.ease);
      }
    }
  }

  void bindController() {
    widget.controller.scrollToItemCall = (index) {
      setState(() {
        selectIndex = index;
      });
      scrollToItem(index);
    };
  }

  @override
  void initState() {
    super.initState();

    bindController();
    logger.t('_LinkScrollBarState initState selectIndex:${widget.initIndex}');

    selectIndex = widget.initIndex;
    // _indicatorPositionedLeft = widget.itemPadding.horizontal / 2;

    // 初始计算
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 0)).then((value) {
        setState(() {});
      });

      Future.delayed(const Duration(milliseconds: 100)).then((value) {
        scrollToItem(widget.initIndex);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final scrollViewWidth = _maxScrollViewWidth;

    final indicator = AnimatedContainer(
      height: widget.indicatorHeight,
      width: _indicatorWidth,
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.indicatorHeight * 3 / 4),
          topRight: Radius.circular(widget.indicatorHeight * 3 / 4),
        ),
      ),
      duration: kDuration,
      curve: Curves.ease,
    );

    return LayoutBuilder(builder: (context, c) {
      return SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _maxScrollViewWidth,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _getBarItems(context, c.maxWidth),
                ),
              ),
              if (widget.pageController == null)
                Stack(
                  children: [
                    SizedBox(
                        height: widget.indicatorHeight, width: scrollViewWidth),
                    AnimatedPositioned(
                      left: _indicatorPositionedLeft,
                      duration: kDuration,
                      curve: Curves.ease,
                      child: indicator,
                    ),
                  ],
                ),
              if (widget.pageController != null)
                TitleIndicator(
                  height: widget.indicatorHeight,
                  pageController: widget.pageController,
                  channelFrameList: channelFrameList,
                  maxWidth: scrollViewWidth,
                  width: c.maxWidth,
                  index: selectIndex,
                  itemPadding: widget.itemPadding,
                ),
            ],
          ),
        ),
      );
    });
  }
}

class TitleIndicator extends StatefulWidget {
  const TitleIndicator({
    super.key,
    this.maxWidth,
    this.pageController,
    required this.channelFrameList,
    required this.width,
    required this.index,
    this.itemPadding,
    this.height = 0.0,
  });
  final double? maxWidth;
  final PageController? pageController;
  final List<ItemFrame> channelFrameList;
  final double width;
  final double height;
  final int index;
  final EdgeInsetsGeometry? itemPadding;

  @override
  State<TitleIndicator> createState() => _TitleIndicatorState();
}

class _TitleIndicatorState extends State<TitleIndicator> {
  double positionedLeft = 0.0;
  double _indicatorWidth = 0.0;
  @override
  void initState() {
    super.initState();
    logger.t('_TitleIndicatorState initState index:${widget.index}');

    positionedLeft = widget
            .channelFrameList[min(max(widget.index, 0),
                max(widget.channelFrameList.length - 1, 0))]
            .left +
        (widget.itemPadding?.horizontal ?? 0) / 2;
    _indicatorWidth = widget
            .channelFrameList[min(max(widget.index, 0),
                max(widget.channelFrameList.length - 1, 0))]
            .width -
        (widget.itemPadding?.horizontal ?? 0);

    // pageController监听
    // widget.pageController?.addListener(_listen);
  }

  void _listen() {
    final page = widget.pageController?.page ?? 0.0;
    final index = page ~/ 1;
    if (index < widget.channelFrameList.length - 1) {
      final offset = widget.channelFrameList[index].left +
          page %
              1 *
              (widget.channelFrameList[index + 1].left -
                  widget.channelFrameList[index].left);
      _indicatorWidth = widget.channelFrameList[index].width +
          page %
              1 *
              (widget.channelFrameList[index + 1].width -
                  widget.channelFrameList[index].width);
      _indicatorWidth = _indicatorWidth - (widget.itemPadding?.horizontal ?? 0);

      if (mounted) {
        setState(() {
          positionedLeft = offset + ((widget.itemPadding?.horizontal ?? 0) / 2);
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.pageController?.hasListeners ?? false) {
      widget.pageController?.removeListener(_listen);
    }
    widget.pageController?.addListener(_listen);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned(
            left: positionedLeft,
            child: Container(
              width: _indicatorWidth,
              height: widget.height,
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.height * 3 / 4),
                  topRight: Radius.circular(widget.height * 3 / 4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//导航栏item组件封装
class InnerLinkTabItem extends StatefulWidget {
  const InnerLinkTabItem({
    super.key,
    required this.title,
    this.selected = false,
    this.padding,
    required this.index,
    this.icon,
    double? iconSize,
  }) : iconSize = icon == null ? 0 : (iconSize ?? 16);

  final String title;
  final EdgeInsetsGeometry? padding;
  final bool selected;
  final int index;
  final IconData? icon;
  final double iconSize;

  @override
  State<InnerLinkTabItem> createState() => _InnerLinkTabItemState();
}

class _InnerLinkTabItemState extends State<InnerLinkTabItem> {
  final GlobalKey _key = GlobalKey();

  double get width {
    return getTextSize(widget.title, style).width +
        (widget.padding?.horizontal ?? 0);
  }

  TextStyle get style => TextStyle(
        fontSize: widget.selected ? 14.0 : 14.0,
        color: CupertinoDynamicColor.resolve(
            widget.selected
                ? CupertinoColors.activeBlue
                : CupertinoColors.label,
            context),
        // fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      );

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   logger.d('${context.size?.width} $width');
    //   // WSLGetWidgetWithNotification(
    //   //         width: context.size?.width ?? 0.0, index: widget.index)
    //   //     .dispatch(context);
    //   // WSLGetWidgetWithNotification(width: width, index: widget.index)
    //   //     .dispatch(context);
    // });
  }

  @override
  Widget build(BuildContext context) {
    WSLGetWidgetWithNotification(
            width: width + widget.iconSize + 4, index: widget.index)
        .dispatch(context);

    return Container(
      key: _key,
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Row(
            children: [
              if (widget.icon != null)
                Icon(
                  widget.icon,
                  size: widget.iconSize,
                ),
              if (widget.icon != null) const SizedBox(width: 4),
              Text(
                widget.title,
                style: style,
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class WSLChannelScrollViewNeedScrollEvent {
  WSLChannelScrollViewNeedScrollEvent(this.index);

  int index = 0;
}

class WSLCustomTabbarNotification extends Notification {
  WSLCustomTabbarNotification({required this.index});

  final int index;
}

class WSLGetWidgetWithNotification extends Notification {
  WSLGetWidgetWithNotification({required this.width, required this.index});

  final double width;
  final int index;
}

class ItemFrame {
  ItemFrame({
    this.left = 0,
    this.width = 0,
    this.index = 0,
  });

  double left; //距离左侧距离
  double width; //item宽度
  int index;
}

class FooSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  FooSliverPersistentHeaderDelegate({
    required this.builder,
    required this.maxHeight,
    required this.minHeight,
  });

  final double minHeight;
  final double maxHeight;

  final Widget Function(
      BuildContext context, double shrinkOffset, bool overlapsContent) builder;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      builder(context, shrinkOffset, overlapsContent);

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return minHeight != oldDelegate.minExtent ||
        maxHeight != oldDelegate.maxExtent;
  }
}

Future showItemAttach({
  required BuildContext targetContext,
  required Widget child,
  String? tag,
  VoidCallback? onDismiss,
  double? width,
  EdgeInsetsGeometry? margin,
  AlignmentGeometry? alignmentTemp,
}) async {
  await SmartDialog.showAttach(
    highlightBuilder: (Offset targetOffset, Size targetSize) {
      return Positioned(
        left: targetOffset.dx,
        top: targetOffset.dy + 2,
        child: Container(
          height: targetSize.height - 4,
          width: targetSize.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
      );
    },
    tag: tag,
    keepSingle: true,
    targetContext: targetContext,
    onDismiss: onDismiss,
    builder: (BuildContext context) {
      return SafeArea(
        top: false,
        bottom: false,
        child: Container(
          width: width,
          margin: margin,
          // constraints: const BoxConstraints(maxHeight: 300, minHeight: 50),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(16),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withOpacity(0.2),
          //       offset: const Offset(0, 0),
          //       blurRadius: 10, //阴影模糊程度
          //       spreadRadius: 1, //阴影扩散程度
          //     ),
          //   ],
          // ),
          // color: CupertinoColors.systemGrey5,
          child: CupertinoPopupSurface(
            child: child,
          ),
        ),
      );
    },
  );
}
