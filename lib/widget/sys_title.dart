import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// todo: Windows 标题
// 没有找到好的方案 暂时搁置

class DesktopTitle {
  DesktopTitle(
    this.title, {
    this.titleVisible = true,
    this.buttonVisible = true,
  });
  final String title;
  final bool titleVisible;
  final bool buttonVisible;
}

class SysTitle extends StatefulWidget {
  SysTitle(
      {required this.title,
      required this.child,
      this.desktopTitleVisible = true,
      this.desktopButtonVisible = true,
      this.color,
      super.key});

  final bool desktopTitleVisible;
  final bool desktopButtonVisible;

  static DesktopTitle? current;
  static final StreamController<DesktopTitle> _currentController =
      StreamController.broadcast();
  static Stream<DesktopTitle> get currentStream => _currentController.stream;

  /// A one-line description of this app for use in the window manager.
  /// Must not be null.
  final String title;

  /// A color that the window manager should use to identify this app. Must be
  /// an opaque color (i.e. color.alpha must be 255 (0xFF)), and must not be
  /// null.
  final Color? color;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  State<SysTitle> createState() => _SysTitleState();
}

class _SysTitleState extends State<SysTitle> {
  @override
  Widget build(BuildContext context) {
    final desktopTitle = DesktopTitle(widget.title,
        titleVisible: widget.desktopTitleVisible,
        buttonVisible: widget.desktopButtonVisible);
    SysTitle.current = desktopTitle;
    SysTitle._currentController.sink.add(desktopTitle);
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: widget.title,
        primaryColor: widget.color?.value,
      ),
    );
    return widget.child;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', widget.title, defaultValue: ''));
    properties.add(ColorProperty('color', widget.color, defaultValue: null));
  }
}
