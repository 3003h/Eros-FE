import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/const/theme_colors.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/pages/controller/favorite_sel_controller.dart';
import 'package:eros_fe/pages/tab/fetch_list.dart';
import 'package:eros_fe/pages/tab/view/gallery_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class FavoriteSelectorPage extends StatelessWidget {
  const FavoriteSelectorPage({super.key, this.favCatItemBean});

  final Favcat? favCatItemBean;

  FavoriteSelectorController get favoriteSelectorController => Get.find();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).favcat),
      ),
      child: CustomScrollView(slivers: [
        SliverSafeArea(
          sliver: favoriteSelectorController.obx(
              (List<Favcat>? state) {
                return ListViewFavorite(
                  favCatList: state ?? [],
                );
              },
              onLoading: const SliverFillRemaining(
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: 14.0,
                  ),
                ),
              ),
              onError: (err) {
                return SliverFillRemaining(
                  child: Center(
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
              }),
        ),
      ]),
    );
  }
}

class ListViewFavorite extends StatelessWidget {
  const ListViewFavorite({super.key, required this.favCatList});

  final List<Favcat> favCatList;

  @override
  Widget build(BuildContext context) {
    return SliverCupertinoListSection.insetGrouped(
      hasLeading: true,
      itemBuilder: (context, index) {
        final Favcat _favcat = favCatList[index];
        return EhCupertinoListTile(
          title: Text(_favcat.favTitle),
          leading: Icon(
            CupertinoIcons.heart_fill,
            color: ThemeColors.favColor[_favcat.favId],
          ),
          trailing: const CupertinoListTileChevron(),
          additionalInfo: Text(
            '${_favcat.totNum ?? 0}',
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          onTap: () {
            Get.back(
              result: _favcat,
              id: isLayoutLarge ? 1 : null,
            );
          },
        );
      },
      itemCount: favCatList.length,
    );
  }
}
