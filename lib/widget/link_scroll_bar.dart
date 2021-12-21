import 'dart:async';
import 'dart:math';

import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LinkScrollBar extends StatefulWidget {
  const LinkScrollBar({
    Key? key,
    required this.titleList,
    required this.selectIndex,
    required this.width,
  }) : super(key: key);

  final List<String> titleList;
  final int selectIndex;
  final double width;

  @override
  State<LinkScrollBar> createState() => _LinkScrollBarState();
}

class _LinkScrollBarState extends State<LinkScrollBar> {
  int selectIndex = 0;
  List<ChannelFrame> channelFrameList = [];
  double _maxScrollViewWidth = 0;
  final ScrollController _scrollController = ScrollController();

  List<Widget> _getBarItems(BuildContext context) {
    List<Widget> _barItems = [];
    for (int i = 0; i < widget.titleList.length; i++) {
      final genneralChannelItem = GenneralChannelItem(
        name: widget.titleList[i],
        index: i,
        currentSelectIndex: selectIndex,
      );

      final barItem = NotificationListener<WSLGetWidgetWithNotification>(
        onNotification: (notification) {
          //这里接受item创建时发起的冒泡消息，目的是：此时，导航item的宽度已计算完毕，创建导航栏布局记录类，记录当前item距离左侧距离及宽度。
          ChannelFrame channelFrame = ChannelFrame(
              left: _maxScrollViewWidth, width: genneralChannelItem.width);
          //保存所有ChannelFrame值，以便当外部修改viewPage的index值时或者点击item时进行修改scrollview偏移量
          channelFrameList.add(channelFrame);
          _maxScrollViewWidth += genneralChannelItem.width;
          //返回 false 消息到此结束，不再继续往外传递
          return false;
        },
        child: GestureDetector(
          child: genneralChannelItem,
          onTap: () {
            logger.d('tap $i');
            setState(() {
              selectIndex = i;
              // WSLCustomTabbarNotification(index: selectIndex).dispatch(context);
              eventBus.fire(WSLChannelScrollViewNeedScrollEvent(selectIndex));
            });
          },
        ),
      );

      _barItems.add(barItem);
    }
    return _barItems;
  }

  late StreamSubscription _needChangeScrollviewEvent;

  @override
  void initState() {
    super.initState();
    selectIndex = widget.selectIndex;

    _needChangeScrollviewEvent =
        eventBus.on<WSLChannelScrollViewNeedScrollEvent>().listen((event) {
      logger.d('index:${event.index}');
      ChannelFrame channelFrame = channelFrameList[event.index];
      //计算选中的导航item的中心点
      double centerX = channelFrame.left + channelFrame.width / 2.0;
      //设定需要滚动的偏移量
      double needScrollView = 0;
      //当选中的导航item在中心偏左时
      if (centerX - _scrollController.offset < widget.width / 2.0) {
        needScrollView =
            widget.width / 2.0 - centerX + _scrollController.offset;
        //存在滚动条件
        if (_scrollController.offset > 0) {
          //当无法满足滚动到正中心的位置，就直接回到偏移量原点
          if (_scrollController.offset < needScrollView) {
            needScrollView = _scrollController.offset;
          }
          //进行偏移量动画滚动
          _scrollController.animateTo(_scrollController.offset - needScrollView,
              duration: const Duration(milliseconds: 260), curve: Curves.ease);
        }
      } else {
        //当选中的导航item在中心偏右时
        needScrollView =
            centerX - _scrollController.offset - widget.width / 2.0;
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
              duration: const Duration(milliseconds: 260), curve: Curves.ease);
        }
      }
    });
  }

  @override
  void dispose() {
    _needChangeScrollviewEvent.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _getBarItems(context),
      ),
    );
  }
}

//导航栏item组件封装
class GenneralChannelItem extends StatelessWidget {
  GenneralChannelItem({
    required this.name,
    required this.index,
    required this.currentSelectIndex,
    this.left = 10,
    this.right = 10,
  });

  String name;
  int index;
  int currentSelectIndex;
  double left;
  double right;
  double width = 0; //记录宽度

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
      fontSize: index == currentSelectIndex ? 14.0 : 14.0,
      color: index == currentSelectIndex ? CupertinoColors.activeBlue : null,
      fontWeight:
          index == currentSelectIndex ? FontWeight.bold : FontWeight.normal,
    );
    //计算宽度
    width = getTextSize(name, style).width + left + right;

    WSLGetWidgetWithNotification(width: width).dispatch(context);

    return Container(
      padding: EdgeInsets.only(left: left, right: right),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            name,
            style: style,
          ),
          Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(2.0),
            child: Container(
              color: index == currentSelectIndex
                  ? CupertinoColors.activeBlue
                  : Colors.transparent,
              height: 4,
              width: max(10, width / 2),
            ),
          )
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
