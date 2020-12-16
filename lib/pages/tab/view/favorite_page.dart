import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/entity/favorite.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/local_favorite_model.dart';
import 'package:FEhViewer/models/states/user_model.dart';
import 'package:FEhViewer/pages/tab/controller/favorite_controller.dart';
import 'package:FEhViewer/pages/tab/view/gallery_base.dart';
import 'package:FEhViewer/pages/tab/view/tab_base.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/widget/eh_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FavoriteTab extends GetView<FavoriteController> {
  const FavoriteTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final String tabIndex;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Selector<UserModel, bool>(
          selector: (BuildContext context, UserModel provider) =>
              provider.isLogin,
          builder: (BuildContext context, bool isLogin, Widget child) {
            if (isLogin) {
              if (controller.title.value == null ||
                  controller.title.value.isEmpty) {
                controller.title.value = 'all_Favorites'.tr;
              }
              return _buildNetworkFavView(context);
            } else {
              return _buildLocalFavView();
            }
          }),
    );
  }

  Widget _buildNetworkFavView(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 4),
          largeTitle: Obx(() => TabPageTitle(
                title: controller.title.value,
              )),
          trailing: Container(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                      color: CupertinoColors.activeBlue,
                      child: Obx(() => Text(
                            '${controller.curPage.value + 1}',
                            style:
                                const TextStyle(color: CupertinoColors.white),
                          )),
                    ),
                  ),
                  onPressed: () {
                    controller.jumtToPage(context);
                  },
                ),
                _buildFavcatButton(context),
              ],
            ),
          ),
        ),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await controller.reloadData();
          },
        ),
        SliverSafeArea(
          top: false,
          sliver: _getGalleryList(),
        ),
        SliverToBoxAdapter(
          child: Obx(() => Container(
                padding: const EdgeInsets.only(bottom: 150),
                child: controller.isLoadMore.value
                    ? const CupertinoActivityIndicator(
                        radius: 14,
                      )
                    : Container(),
              )),
        ),
      ],
    );
  }

  Widget _buildLocalFavView() {
    return CustomScrollView(slivers: <Widget>[
      const CupertinoSliverNavigationBar(
        largeTitle: TabPageTitle(title: '本地收藏'),
        transitionBetweenRoutes: false,
      ),
      CupertinoSliverRefreshControl(
        onRefresh: () async {
          await controller.reloadData();
        },
      ),
      Selector<LocalFavModel, int>(
          selector: (context, localFavModel) => localFavModel.loacalFavs.length,
          builder: (context, _, __) {
            return SliverSafeArea(
              top: false,
              sliver: _getGalleryList(),
            );
          }),
      SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.only(bottom: 150),
          child: controller.isLoadMore.value
              ? const CupertinoActivityIndicator(
                  radius: 14,
                )
              : Container(),
        ),
      ),
    ]);
  }

  Widget _getGalleryList() {
    return controller.obx(
        (List<GalleryItem> state) {
          return getGalleryList(
            state,
            tabIndex,
            maxPage: controller.maxPage,
            curPage: controller.curPage.value,
            loadMord: controller.loadDataMore,
          );
        },
        onLoading: SliverFillRemaining(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 50),
            child: const CupertinoActivityIndicator(
              radius: 14.0,
            ),
          ),
        ),
        onError: (err) {
          logger.e(' $err');
          return SliverFillRemaining(
            child: Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: GalleryErrorPage(
                onTap: controller.reLoadDataFirst,
              ),
            ),
          );
        });
  }

  /// 切换收藏夹
  Widget _buildFavcatButton(BuildContext context) {
    return CupertinoButton(
      minSize: 40,
      padding: const EdgeInsets.only(right: 8),
      child: const Icon(
        FontAwesomeIcons.star,
      ),
      onPressed: () async {
        // 跳转收藏夹选择页
        Get.toNamed(EHRoutes.selFavorie).then((result) async {
          if (result.runtimeType == FavcatItemBean) {
            final FavcatItemBean fav = result;
            if (controller.curFavcat != fav.favId) {
              loggerNoStack.v('set fav to ${fav.title}');
              controller.title(fav.title);
              controller.enableDelayedLoad = false;
              controller.curFavcat = fav.favId;
              Global.profile.ehConfig.lastShowFavcat = controller.curFavcat;
              Global.profile.ehConfig.lastShowFavTitle = fav.title;
              Global.saveProfile();
              controller.reLoadDataFirst();
            } else {
              loggerNoStack.v('未修改favcat');
            }
          }
        });
      },
    );
  }
}
