import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/controller/favorite_sel_controller.dart';
import 'package:fehviewer/pages/tab/view/gallery_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../fetch_list.dart';

/// 收藏夹选择页面 列表
class FavoriteSelectorPage extends StatelessWidget {
  FavoriteSelectorPage({this.favcatItemBean});

  final Favcat? favcatItemBean;

  final FavoriteSelectorController favoriteSelectorController = Get.find();

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).favcat;
    final CupertinoPageScaffold sca = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_title),
          transitionBetweenRoutes: false,
        ),
        child: SafeArea(
          child: _buildFavoriteSelectorListView(),
        ));

    return sca;
  }

  Widget _buildFavoriteSelectorListView() {
    return favoriteSelectorController.obx(
        (List<Favcat>? state) {
          return ListViewFavorite(state ?? []);
        },
        onLoading: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 50),
          child: const CupertinoActivityIndicator(
            radius: 14.0,
          ),
        ),
        onError: (err) {
          return Center(
            child: Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: GalleryErrorPage(
                onTap: () async {
                  await getGallery(
                    favcat: 'a',
                    refresh: true,
                    galleryListType: GalleryListType.favorite,
                  );
                },
              ),
            ),
          );
        });
  }
}

class ListViewFavorite extends StatelessWidget {
  const ListViewFavorite(this.favItemBeans);

  final List<Favcat> favItemBeans;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: favItemBeans.length,

      //列表项构造器
      itemBuilder: (BuildContext context, int index) {
        return _FavSelItemWidget(
          favcatItemBean: favItemBeans[index],
          index: index,
        );
      },
    );
  }
}

/// 收藏夹选择单项
class _FavSelItemWidget extends StatelessWidget {
  const _FavSelItemWidget({required this.index, required this.favcatItemBean});

  final int index;
  final Favcat favcatItemBean;

  @override
  Widget build(BuildContext context) {
    // 每个Item单独的依赖
    final FavSelectorItemController favoriteSelectorItemController =
        Get.put(FavSelectorItemController(), tag: '$index')!;

    final Widget container = Obx(() => Container(
          color: favoriteSelectorItemController.colorTap.value,
          padding: const EdgeInsets.fromLTRB(24, 8, 12, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                // 图标
                Icon(
                  FontAwesomeIcons.solidHeart,
                  color: ThemeColors.favColor[favcatItemBean.favId],
                ),
                Container(
                  width: 8,
                ), // 占位 宽度8
                Text(
                  favcatItemBean.favTitle,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  '${favcatItemBean.totNum ?? 0}',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const Icon(
                  CupertinoIcons.forward,
                  size: 24.0,
                  color: CupertinoColors.systemGrey,
                ),
              ]),
            ],
          ),
        ));

    return GestureDetector(
      child: Column(
        children: <Widget>[
          container,
          _settingItemDivider(),
        ],
      ),
      // 不可见区域点击有效
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 返回 并带上参数
        Get.back(
          result: favcatItemBean,
          id: isLayoutLarge ? 1 : null,
        );
      },
      onTapDown: (_) => favoriteSelectorItemController.updatePressedColor(),
      onTapUp: (_) {
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          favoriteSelectorItemController.updateNormalColor();
        });
      },
      onTapCancel: () => favoriteSelectorItemController.updateNormalColor(),
    );
  }

  /// 设置项分隔线
  Widget _settingItemDivider() {
    return Divider(
      height: 1.0,
      indent: 48,
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGrey4, Get.context!),
    );
  }
}
