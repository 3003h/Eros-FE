import 'dart:math';

import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const kDuration = Duration(milliseconds: 300);
const double kDefIndicatorHeight = 4;

final LinkScrollBarController _defaultLinkScrollBarController =
    LinkScrollBarController();

class LinkScrollBar extends StatefulWidget {
  LinkScrollBar({
    Key? key,
    LinkScrollBarController? controller,
    this.pageController,
    required this.titleList,
    required this.initIndex,
    this.indicatorHeight = kDefIndicatorHeight,
    this.itemPadding = const EdgeInsets.only(left: 10, right: 10),
    this.onItemChange,
  })  : controller = controller ?? _defaultLinkScrollBarController,
        super(key: key);

  final List<String> titleList;
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
  List<ChannelFrame> channelFrameList = [];
  double _maxScrollViewWidth = 10;
  double _indicatorPositionedLeft = 0;
  double _indicatorWidth = 0.0;
  final ScrollController _scrollController = ScrollController();

  double boxWidth = 0.0;

  List<Widget> _getBarItems(BuildContext context, double boxWidth) {
    this.boxWidth = boxWidth;
    channelFrameList.clear();
    List<Widget> _barItems = [];
    _maxScrollViewWidth = 0;

    for (int i = 0; i < widget.titleList.length; i++) {
      // final genneralChannelItem = GenneralChannelItem(
      //   title: widget.titleList[i],
      //   selected: i == selectIndex,
      //   padding: widget.itemPadding,
      //   index: i,
      // );

      final barItem = NotificationListener<WSLGetWidgetWithNotification>(
        onNotification: (notification) {
          // logger.d('${notification.index}  ${notification.width}');
          if (channelFrameList.length == widget.titleList.length) {
            return true;
          }

          //这里接受item创建时发起的冒泡消息，目的是：此时，导航item的宽度已计算完毕，创建导航栏布局记录类，记录当前item距离左侧距离及宽度。
          ChannelFrame channelFrame = ChannelFrame(
            left: _maxScrollViewWidth,
            width: notification.width,
            index: notification.index,
          );

          //保存所有ChannelFrame值，以便当外部修改viewPage的index值时或者点击item时进行修改scrollview偏移量
          channelFrameList.add(channelFrame);

          _maxScrollViewWidth += notification.width;

          //返回 true 消息到此结束，不再继续往外传递
          return true;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: GenneralChannelItem(
            title: widget.titleList[i],
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
        ),
      );

      _barItems.add(barItem);
    }
    return _barItems;
  }

  void scrollToItem(int index) {
    ChannelFrame channelFrame = channelFrameList[index];

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
    logger.d('initState');

    bindController();

    selectIndex = widget.initIndex;
    _indicatorPositionedLeft = widget.itemPadding.horizontal / 2;

    // 初始计算
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        setState(() {});
      }).then((value) => scrollToItem(widget.initIndex));
    });

    // channelFrameList
    // SchedulerBinding.instance?.addPostFrameCallback((_) {
    //   Future.delayed(Duration(milliseconds: 500)).then((value) {
    //     logger.d('${channelFrameList.length}');
    //   });
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final scrollViewWidth = _maxScrollViewWidth;

    final _indicator = AnimatedContainer(
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
        child: Container(
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
                      child: _indicator,
                      duration: kDuration,
                      curve: Curves.ease,
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
    Key? key,
    this.maxWidth,
    this.pageController,
    required this.channelFrameList,
    required this.width,
    required this.index,
    this.itemPadding,
    this.height = 0.0,
  }) : super(key: key);
  final double? maxWidth;
  final PageController? pageController;
  final List<ChannelFrame> channelFrameList;
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
    positionedLeft = (widget.itemPadding?.horizontal ?? 0) / 2;
    _indicatorWidth = widget.channelFrameList[widget.index].width -
        (widget.itemPadding?.horizontal ?? 0);

    // pageController监听
    widget.pageController?.addListener(() {
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
        _indicatorWidth =
            _indicatorWidth - (widget.itemPadding?.horizontal ?? 0);

        setState(() {
          positionedLeft = offset + ((widget.itemPadding?.horizontal ?? 0) / 2);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
class GenneralChannelItem extends StatefulWidget {
  const GenneralChannelItem({
    required this.title,
    this.selected = false,
    this.padding,
    required this.index,
  });

  final String title;
  final EdgeInsetsGeometry? padding;
  final bool selected;
  final int index;

  @override
  State<GenneralChannelItem> createState() => _GenneralChannelItemState();
}

class _GenneralChannelItemState extends State<GenneralChannelItem> {
  final GlobalKey _key = GlobalKey();

  double get width {
    return getTextSize(widget.title, style).width +
        (widget.padding?.horizontal ?? 0);
  }

  TextStyle get style => TextStyle(
        fontSize: widget.selected ? 14.0 : 14.0,
        color: widget.selected ? CupertinoColors.activeBlue : null,
        // fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      logger.d('${context.size?.width} $width');
      // WSLGetWidgetWithNotification(
      //         width: context.size?.width ?? 0.0, index: widget.index)
      //     .dispatch(context);
      // WSLGetWidgetWithNotification(width: width, index: widget.index)
      //     .dispatch(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    WSLGetWidgetWithNotification(width: width, index: widget.index)
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
          Text(
            widget.title,
            style: style,
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

class ChannelFrame {
  ChannelFrame({
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
