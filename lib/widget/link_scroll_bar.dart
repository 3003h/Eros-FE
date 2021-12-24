import 'dart:math';

import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const kDuration = Duration(milliseconds: 300);
const kLineHeight = 4.0;

final LinkScrollBarController _defaultLinkScrollBarController =
    LinkScrollBarController();

class LinkScrollBar extends StatefulWidget {
  LinkScrollBar({
    Key? key,
    LinkScrollBarController? controller,
    required this.titleList,
    required this.selectIndex,
    required this.width,
    this.lineHeight = kLineHeight,
    this.itemPadding = const EdgeInsets.only(left: 10, right: 10),
    this.onItemChange,
  })  : controller = controller ?? _defaultLinkScrollBarController,
        super(key: key);

  final List<String> titleList;
  final int selectIndex;
  final double width;
  final double lineHeight;
  final EdgeInsetsGeometry itemPadding;
  final LinkScrollBarController controller;
  final ValueChanged<int>? onItemChange;

  @override
  State<LinkScrollBar> createState() => _LinkScrollBarState();
}

class _LinkScrollBarState extends State<LinkScrollBar> {
  int selectIndex = 0;
  List<ChannelFrame> channelFrameList = [];
  double _maxScrollViewWidth = 0;
  double _linePositionedLeft = 0;
  double _lineWidth = 0.0;
  final ScrollController _scrollController = ScrollController();

  List<Widget> _getBarItems(BuildContext context) {
    channelFrameList.clear();
    List<Widget> _barItems = [];
    _maxScrollViewWidth = 0;

    for (int i = 0; i < widget.titleList.length; i++) {
      final genneralChannelItem = GenneralChannelItem(
        title: widget.titleList[i],
        selected: i == selectIndex,
        lineHeight: 0.0,
        padding: widget.itemPadding,
      );

      final barItem = NotificationListener<WSLGetWidgetWithNotification>(
        onNotification: (notification) {
          //这里接受item创建时发起的冒泡消息，目的是：此时，导航item的宽度已计算完毕，创建导航栏布局记录类，记录当前item距离左侧距离及宽度。
          ChannelFrame channelFrame = ChannelFrame(
              left: _maxScrollViewWidth, width: genneralChannelItem.width);
          //保存所有ChannelFrame值，以便当外部修改viewPage的index值时或者点击item时进行修改scrollview偏移量
          channelFrameList.add(channelFrame);
          _maxScrollViewWidth += genneralChannelItem.width;

          //返回 true 消息到此结束，不再继续往外传递
          return true;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: genneralChannelItem,
          onTap: () {
            widget.controller.disableScrollToItem();
            setState(() {
              selectIndex = i;
              // WSLCustomTabbarNotification(index: selectIndex).dispatch(context);
              // eventBus.fire(WSLChannelScrollViewNeedScrollEvent(selectIndex));
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

    _linePositionedLeft = channelFrame.left + widget.itemPadding.horizontal / 2;
    _lineWidth = channelFrame.width - widget.itemPadding.horizontal;

    //计算选中的导航item的中心点
    double centerX = channelFrame.left + channelFrame.width / 2.0;
    //设定需要滚动的偏移量
    double needScrollView = 0;
    //当选中的导航item在中心偏左时
    if (centerX - _scrollController.offset < widget.width / 2.0) {
      needScrollView = widget.width / 2.0 - centerX + _scrollController.offset;
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
      needScrollView = centerX - _scrollController.offset - widget.width / 2.0;
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

    selectIndex = widget.selectIndex;
    _linePositionedLeft = widget.itemPadding.horizontal / 2;
    // 初始计算
    SchedulerBinding.instance?.addPostFrameCallback(
        (_) => Future.delayed(const Duration(milliseconds: 100)).then((value) {
              scrollToItem(widget.selectIndex);
              setState(() {});
            }));
  }

  @override
  Widget build(BuildContext context) {
    final scrollViewWidth = _maxScrollViewWidth;

    final _lineIndicator = AnimatedContainer(
      height: widget.lineHeight,
      width: _lineWidth,
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.lineHeight * 3 / 4),
          topRight: Radius.circular(widget.lineHeight * 3 / 4),
        ),
      ),
      duration: kDuration,
      curve: Curves.ease,
    );

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Container(
        width: scrollViewWidth,
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _getBarItems(context),
              ),
            ),
            Stack(
              children: [
                SizedBox(height: widget.lineHeight, width: scrollViewWidth),
                AnimatedPositioned(
                  left: _linePositionedLeft,
                  child: _lineIndicator,
                  duration: kDuration,
                  curve: Curves.ease,
                ),
              ],
            ),
            Container(
              height: 8,
            )
          ],
        ),
      ),
    );
  }
}

//导航栏item组件封装
class GenneralChannelItem extends StatelessWidget {
  const GenneralChannelItem({
    required this.title,
    this.selected = false,
    this.lineHeight = 4.0,
    this.padding,
  });

  final String title;
  final EdgeInsetsGeometry? padding;
  final bool selected;
  final double lineHeight;

  double get width {
    return getTextSize(title, style).width + (padding?.horizontal ?? 0);
  }

  TextStyle get style => TextStyle(
        fontSize: selected ? 14.0 : 14.0,
        color: selected ? CupertinoColors.activeBlue : null,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      );

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
      fontSize: selected ? 14.0 : 14.0,
      color: selected ? CupertinoColors.activeBlue : null,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
    );

    WSLGetWidgetWithNotification(width: width).dispatch(context);

    return Container(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            title,
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
  WSLGetWidgetWithNotification({required this.width});

  final double width;
}

class ChannelFrame {
  ChannelFrame({this.left = 0, this.width = 0});

  double left; //距离左侧距离
  double width; //item宽度
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
