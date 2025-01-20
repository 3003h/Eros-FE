import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:eros_fe/common/controller/log_controller.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class LogViewPage extends StatefulWidget {
  const LogViewPage({Key? key, required this.index, required this.title})
      : super(key: key);
  final int index;
  final String title;

  @override
  State<LogViewPage> createState() => _LogViewPageState();
}

class _LogViewPageState extends State<LogViewPage> {
  final LogService logService = Get.find();
  final ScrollController _scrollController = ScrollController();
  final _logContent = ValueNotifier<String>('');
  Timer? _watchTimer;
  bool _autoScroll = true;
  int _lastFileSize = 0;
  static const _initialReadSize = 50 * 1024; // 首次读取50KB
  static const _chunkSize = 100 * 1024; // 每次加载100KB
  bool _isLoadingMore = false;
  RandomAccessFile? _raf;

  @override
  void initState() {
    super.initState();
    _initLog();
    _startWatching();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
    _scrollController.dispose();
    _logContent.dispose();
    _raf?.close();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // 当滚动到顶部附近时加载更多
      if (_scrollController.position.pixels <= 500 && !_isLoadingMore) {
        _loadMoreContent();
      }
    });
  }

  Future<void> _initLog() async {
    final logFile = logService.logFiles[widget.index];
    if (!logFile.existsSync()) {
      Get.back();
      return;
    }

    try {
      _raf = await logFile.open(mode: FileMode.read);
      _lastFileSize = await _raf!.length();

      // 如果文件较小，直接全部读取
      if (_lastFileSize <= _initialReadSize) {
        final bytes = await _raf!.read(_lastFileSize);
        _logContent.value =
            const Utf8Decoder(allowMalformed: true).convert(bytes);
      } else {
        // 否则只读取末尾部分
        await _raf!.setPosition(_lastFileSize - _initialReadSize);
        final bytes = await _raf!.read(_initialReadSize);
        _logContent.value =
            const Utf8Decoder(allowMalformed: true).convert(bytes);
        showToast('Large log file, loaded latest content');
      }

      // 初始化时滚动到底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      logger.e('初始化日志失败: $e');
      showToast('Failed to read log file');
    }
  }

  Future<void> _loadMoreContent() async {
    if (_isLoadingMore || _raf == null) {
      return;
    }

    _isLoadingMore = true;
    try {
      final currentPosition = await _raf!.position();
      if (currentPosition <= 0) {
        return;
      }

      final readSize = min(_chunkSize, currentPosition);
      final newPosition = max(0, currentPosition - readSize);

      // 保存当前滚动位置和内容高度
      final currentScrollPosition = _scrollController.position.pixels;
      final currentContentHeight = _scrollController.position.maxScrollExtent;

      await _raf!.setPosition(newPosition);
      final bytes = await _raf!.read(readSize);
      final newContent = const Utf8Decoder(allowMalformed: true).convert(bytes);

      // 在开头添加新内容
      _logContent.value = newContent + _logContent.value;

      // 等待布局完成后调整滚动位置
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final newContentHeight = _scrollController.position.maxScrollExtent;
          final newScrollPosition =
              currentScrollPosition + (newContentHeight - currentContentHeight);
          _scrollController.jumpTo(newScrollPosition);
        }
      });
    } catch (e) {
      logger.e('加载更多内容失败: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  void _startWatching() {
    _watchTimer?.cancel();
    _watchTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    if (_raf == null) {
      return;
    }

    try {
      final logFile = logService.logFiles[widget.index];
      if (!logFile.existsSync()) {
        return;
      }

      final currentSize = await logFile.length();
      if (currentSize == _lastFileSize) {
        return;
      }

      if (currentSize < _lastFileSize) {
        // 文件被重置，重新初始化
        await _raf?.close();
        _raf = null;
        await _initLog();
        return;
      }

      // 只读取新增的部分
      await _raf!.setPosition(_lastFileSize);
      final newBytes = await _raf!.read(currentSize - _lastFileSize);
      final newContent =
          const Utf8Decoder(allowMalformed: true).convert(newBytes);

      // 更新内容
      _logContent.value += newContent;
      _lastFileSize = currentSize;

      // 如果开启了自动滚动且当前在底部附近，则滚动到底部
      if (_autoScroll && _isNearBottom()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      logger.e('检查日志更新失败: $e');
    }
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) {
      return true;
    }
    final position = _scrollController.position;
    return position.pixels >= position.maxScrollExtent - 50;
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final logFile = logService.logFiles[widget.index];

    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 0),
        middle: Text(widget.title),
        previousPageTitle: 'Log',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: () {
                setState(() {
                  _autoScroll = !_autoScroll;
                });
                if (_autoScroll) {
                  _scrollToBottom();
                }
              },
              child: Icon(
                _autoScroll
                    ? CupertinoIcons.arrow_down_circle_fill
                    : CupertinoIcons.arrow_down_circle,
                size: 26,
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.only(right: 12),
              child: const Icon(
                CupertinoIcons.share,
                size: 26,
              ),
              onPressed: () {
                Share.shareXFiles([XFile(logFile.path)]);
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<String>(
          valueListenable: _logContent,
          builder: (context, content, _) {
            if (content.isEmpty) {
              return const Center(
                child: CupertinoActivityIndicator(
                  radius: 14,
                ),
              );
            }

            Widget scrollView = Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        content,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.1,
                          fontFamilyFallback: EHConst.monoFontFamilyFallback,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isLoadingMore)
                  const Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
              ],
            );

            if (GetPlatform.isMobile) {
              scrollView = CupertinoScrollbar(
                controller: _scrollController,
                child: scrollView,
              );
            }

            return scrollView;
          },
        ),
      ),
    );
  }
}

Future<Uint8List> _readFileBytes(String path) async {
  final file = File(path);
  return await file.readAsBytes();
}
