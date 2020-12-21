/*
import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/ehconfig_service.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/controller/history_controller.dart';
import 'package:fehviewer/common/controller/localfav_controller.dart';
import 'package:fehviewer/common/states/gallery_model.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/galleryItem.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_detail/gallery_detail_widget.dart';
import 'package:fehviewer/pages/item/controller/galleryitem_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/network/gallery_request.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:tuple/tuple.dart';

const double kHeaderHeight = 200.0 + 52;
const double kPadding = 12.0;
const double kHeaderPaddingTop = 12.0;

class GalleryDetailPage extends StatefulWidget {
  const GalleryDetailPage({Key key}) : super(key: key);

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  final ScrollController _controller = ScrollController();
  // GalleryModel _galleryModel;

  Future<GalleryItem> _futureBuilderFuture;

  final HistoryController _historyController = Get.find();
  final GalleryCacheController _galleryCacheController = Get.find();
  final EhConfigController _ehConfigController = Get.find();
  final GalleryItemController _galleryItemController = Get.find();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // final GalleryModel galleryModel =
    //     Provider.of<GalleryModel>(context, listen: false);
    // if (galleryModel != _galleryModel) {
    //   _galleryModel = galleryModel;
    //   _initData();
    // }

    _futureBuilderFuture = _loadData();
  }

  /// 异步请求数据
  Future<GalleryItem> _loadData({bool refresh = false}) async {
    try {
      GalleryItem _item = _galleryItemController.galleryItem;

      if (_item.gid != null) {
        Future<void>.delayed(const Duration(milliseconds: 0)).then((_) {
          _historyController.addHistory(_item);
        });
      }

      _galleryItemController.resetHideNavigationBtn();

      // 检查画廊是否包含在本地收藏中
      final bool _localFav =
          _isInLocalFav(_galleryItemController.galleryItem.gid);
      _item.localFav = _localFav;

      /// 画廊详情内容未获取完毕 或者 画廊缩略对象列表为空的情况
      /// 需要请求网络获取数据
      if (!_galleryItemController.detailLoadFinish ||
          _item.galleryPreview.isEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 200));

        if (_item.filecount == null || _item.filecount.isEmpty) {
          await Api.getMoreGalleryInfoOne(_item, refresh: refresh);
        }

        // final GalleryItem _galleryItemFromApi =
        _item = await Api.getGalleryDetail(
          inUrl: _item.url,
          inGalleryItem: _item,
          refresh: refresh,
        );

        _galleryItemController.currentPreviewPage = 0;
        _galleryItemController
            .setGalleryPreviewAfterRequest(_item.galleryPreview);
        _galleryItemController.setFavTitle(_item.favTitle,
            favcat: _item.favcat);

        _item.imgUrl = _item.imgUrl ?? _item.imgUrlL;
        */
/*
        _item.tagGroup = _galleryItemFromApi.tagGroup;
        _item.galleryComment = _galleryItemFromApi.galleryComment;
        _item.showKey = _galleryItemFromApi.showKey;*/ /*


        _galleryItemController.detailLoadFinish = true;
      }
      return _item;
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE && e.response.statusCode == 404) {
        showToast('画廊已被删除');
        rethrow;
      }
      rethrow;
    } catch (e, stack) {
      showToast('解析数据异常');
      logger.e('解析数据异常\n' + e.toString() + '\n' + stack.toString());
      rethrow;
    }
  }

  bool _isInLocalFav(String gid) {
    // 检查是否包含在本地收藏中
    final int index = Get.find<LocalFavController>()
        .loacalFavs
        .indexWhere((GalleryItem element) {
      return element.gid == gid;
    });
    return index >= 0;
  }

  Future<void> _reloadData() async {
    logger.v('_reloadData');

    _galleryItemController.detailLoadFinish = false;
    _galleryItemController.isReloading = true;
    _galleryItemController.reset();
    final GalleryItem _reloadRult = await _loadData(refresh: true);
    setState(() {
      _futureBuilderFuture = Future<GalleryItem>.value(_reloadRult);
      _galleryItemController.isReloading = false;
    });
  }

  void _controllerLister() {
    if (_controller.offset < kHeaderHeight + kHeaderPaddingTop &&
        !_galleryItemController.hideNavigationBtn) {
      _galleryItemController.hideNavigationBtn = true;
    } else if (_controller.offset >= kHeaderHeight + kHeaderPaddingTop &&
        _galleryItemController.hideNavigationBtn) {
      _galleryItemController.hideNavigationBtn = false;
    }
  }

*/
/*  void _initData() {
    _controller.addListener(_controllerLister);

    _galleryItemController.resetHideNavigationBtn();
  }*/ /*


  @override
  Widget build(BuildContext context) {
    /// 因为 CupertinoNavigationBar的特殊 不能直接用Selector包裹控制build 所以在
    /// CupertinoPageScaffold 外层加了 Selector , hideNavigationBtn变化才会重绘
    /// 内容作为 child 缓存避免重绘
    ///
    /// 增加 oriGalleryPreview 变化时可重绘的控制
    final Widget cps = Builder(
      builder: (_) {
        final bool _hideNavigationBtn =
            _galleryItemController.hideNavigationBtn;
        final GalleryItem _item = _galleryItemController.galleryItem;
        // 主布局
        return CupertinoPageScaffold(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: Obx(() => Text(
                      _ehConfigController.isJpnTitle.value
                          ? _item.englishTitle ?? ''
                          : _item.japaneseTitle ?? '',
                      textAlign: TextAlign.left,
                      maxLines: 3,
                      style: const TextStyle(
                          fontSize: 12, color: CupertinoColors.systemGrey),
                    )),
                middle: _hideNavigationBtn
                    ? null
                    : _buildNavigationBarImage(context),
                trailing: _hideNavigationBtn
                    ? CupertinoButton(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                        minSize: 0,
                        child: const Icon(
                          FontAwesomeIcons.share,
                          size: 26,
                        ),
                        onPressed: () {
                          logger.v('tap shareBtn');
                          Share.share(' ${_item.url}');
                        },
                      )
                    : _buildNavigationBarReadButton(context),
              ),
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await _reloadData();
                },
              ),
              SliverSafeArea(
                top: false,
                bottom: false,
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      const GalleryHeader(),
                      Container(
                        height: 0.5,
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.systemGrey4, context),
                      ),
                      // 内容
                      _buildDetail(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    return cps;
  }

  Widget _buildDetail(BuildContext context) {
    return Builder(
      builder: (_) {
        final bool loadFinish = _galleryItemController.detailLoadFinish;
        final bool isReloading = _galleryItemController.isReloading;
        final GalleryItem galleryItem = _galleryItemController.galleryItem;

        return FutureBuilder<GalleryItem>(
            future: _futureBuilderFuture,
            initialData: galleryItem,
            builder:
                (BuildContext context, AsyncSnapshot<GalleryItem> snapshot) {
              if (loadFinish) {
                Future<void>.delayed(const Duration(milliseconds: 100))
                    .then((_) {
                  _historyController.addHistory(snapshot.data);
                });
                return GalleryDetailInfo();
              } else {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return _buildLoading(context, isReloading);
                  case ConnectionState.done:
                    // logger.v('done');
                    if (snapshot.hasError) {
                      // return Text('Error: ${snapshot.error}');
                      logger.v('${snapshot.error}');
                      return GalleryErrorPage(
                        onTap: _reloadData,
                      );
                    } else {
                      Future<void>.delayed(const Duration(milliseconds: 100))
                          .then((_) {
                        _historyController.addHistory(snapshot.data);
                      });
                      return GalleryDetailInfo();
                    }
                }
                return null;
              }
            });
      },
    );
  }

  Widget _buildLoading(context, bool isReloading) {
    // 加载中 显示一个菊花
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: !isReloading
          ? const CupertinoActivityIndicator(
              radius: 15.0,
            )
          : null,
    );
  }

  /// 独立出导航栏的阅读按钮
  Widget _buildNavigationBarReadButton(BuildContext context) {
    final bool _hasPreview =
        _galleryItemController.oriGalleryPreview.isNotEmpty;

    return CupertinoButton(
        child: Text(
          S.of(context).READ,
          style: const TextStyle(fontSize: 15),
        ),
        minSize: 20,
        padding: const EdgeInsets.fromLTRB(15, 2.5, 15, 2.5),
        borderRadius: BorderRadius.circular(50),
        color: CupertinoColors.activeBlue,
        onPressed: _hasPreview
            ? () async {
                final GalleryCache _galleryCache = _galleryCacheController
                    .getGalleryCache(_galleryItemController.galleryItem.gid);
                final int _index = _galleryCache?.lastIndex ?? 0;
                await showLoadingDialog(context, _index);
                NavigatorUtil.goGalleryViewPage(context, _index);
              }
            : null);
  }

  Widget _buildNavigationBarImage(BuildContext context) {
    final double _statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () {
        _controller.animateTo(0,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      },
      child: Container(
        child: CoveTinyImage(
          imgUrl: _galleryItemController.galleryItem.imgUrl,
          statusBarHeight: _statusBarHeight,
        ),
      ),
    );
  }
}
*/
