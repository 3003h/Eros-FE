import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import 'setting_items/single_input_item.dart';
import 'webview/web_mysetting_in.dart';

part 'eh_mysettings_items.dart';

class EhMySettingsPage extends StatelessWidget {
  const EhMySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
            middle: Text(L10n.of(context).ehentai_settings),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    LineIcons.globeWithAmericasShown,
                    size: 24,
                  ),
                  onPressed: () async {
                    Get.to(() => InWebMySetting());
                  },
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    LineIcons.checkCircle,
                    size: 24,
                  ),
                  onPressed: () async {
                    // 保存配置
                  },
                ),
              ],
            )),
        child: SafeArea(
          child: ListViewEhMySettings(),
          bottom: false,
        ));
  }
}

class ListViewEhMySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      GroupItem(
        title: 'Image Load Settings',
        child: _buildLoadTypeItem(context, hideLine: true),
      ),
      GroupItem(
        title: 'Image Size Settings',
        desc:
            'Normally, images are resampled to 1280 pixels of horizontal resolution for online viewing. You can alternatively select one of the following resample resolutions. To avoid murdering the staging servers, resolutions above 1280x are temporarily restricted to donators, people with any hath perk, and people with a UID below 3,000,000.',
        child: _buildImageSizeItem(context, hideLine: true),
      ),
      GroupItem(
        desc:
            'While the site will automatically scale down images to fit your screen width, you can also manually restrict the maximum display size of an image. Like the automatic scaling, this does not resample the image, as the resizing is done browser-side. (0 = no limit)',
        child: Column(
          children: [
            _buildSizeHorizontal(context),
            _buildSizeVertical(context),
          ],
        ),
      ),
      GroupItem(
        title: 'Gallery Name Display',
        desc:
            'Many galleries have both an English/Romanized title and a title in Japanese script. Which gallery name would you like as default?',
        child: _buildNameDisplayItem(context, hideLine: true),
      ),
      GroupItem(
        title: 'Archiver Settings',
        desc:
            'The default behavior for the Archiver is to confirm the cost and selection for original or resampled archive, then present a link that can be clicked or copied elsewhere. You can change this behavior here.',
        child: _buildArchiverSettingsItem(context, hideLine: true),
      ),
      GroupItem(
        title: 'Front Page Settings',
        child: _buildFrontPageSettingsItem(context, hideLine: true),
      ),
      GroupItem(
        title: 'Favorites',
        child: Column(
          children: [
            _buildFavoritesSortItem(context, hideLine: true),
          ],
        ),
        desc:
            'You can also select your default sort order for galleries on your favorites page. Note that favorites added prior to the March 2016 revamp did not store a timestamp, and will use the gallery posted time regardless of this setting.',
      ),
      GroupItem(
        title: 'Ratings',
        desc:
            '    By default, galleries that you have rated will appear with red stars for ratings of 2 stars and below, green for ratings between 2.5 and 4 stars, and blue for ratings of 4.5 or 5 stars. You can customize this by entering your desired color combination below.\n'
            '    Each letter represents one star. The default RRGGB means R(ed) for the first and second star, G(reen) for the third and fourth, and B(lue) for the fifth. You can also use (Y)ellow for the normal stars. Any five-letter R/G/B/Y combo works.',
        child: _buildRatingsItem(context, hideLine: true),
      ),
      GroupItem(
        title: 'Tag Namespaces',
        desc:
            'If you want to exclude certain namespaces from a default tag search, you can check those below. Note that this does not prevent galleries with tags in these namespaces from appearing, it just makes it so that when searching tags, it will forego those namespaces.',
      ),
      GroupItem(
        title: 'Tag Filtering Threshold',
        child: _buildTagFilteringThreshold(context),
        desc:
            'You can soft filter tags by adding them to My Tags with a negative weight. If a gallery has tags that add up to weight below this value, it is filtered from view. This threshold can be set between 0 and -9999.',
      ),
      GroupItem(
        title: 'Tag Watching Threshold',
        child: _buildTagWatchingThreshold(context),
        desc:
            'Recently uploaded galleries will be included on the watched screen if it has at least one watched tag with positive weight, and the sum of weights on its watched tags add up to this value or higher. This threshold can be set between 0 and 9999.',
      ),
      GroupItem(
        title: 'Excluded Languages',
        desc:
            'If you wish to hide galleries in certain languages from the gallery list and searches, select them from the list below.\n'
            'Note that matching galleries will never appear regardless of your search query.',
      ),
      GroupItem(
        title: 'Excluded Uploaders',
        child: _buildExcludedUploaders(context),
        desc:
            'If you wish to hide galleries from certain uploaders from the gallery list and searches, add them below. Put one username per line.\n'
            'Note that galleries from these uploaders will never appear regardless of your search query.',
      ),
      GroupItem(
        title: 'Search',
        desc:
            'How many results would you like per page for the index/search page and torrent search pages? (Hath Perk: Paging Enlargement Required)',
        child: _buildSearchResultCountItem(context, hideLine: true),
      ),
      GroupItem(
        title: 'Thumbnail Settings',
        child: Column(
          children: [
            _buildThumbMouseOverItem(context),
            _buildThumbSizeItem(context),
            _buildThumbRowItem(context, hideLine: true),
          ],
        ),
      ),
      GroupItem(
        title: 'Thumbnail Scaling',
        child: _buildThumbnailScaling(context),
        desc:
            'Thumbnails on the thumbnail and extended gallery list views can be scaled to a custom value between 75% and 150%.',
      ),
      GroupItem(
        title: 'Viewport Override',
        child: _buildViewportOverride(context),
        desc:
            'Allows you to override the virtual width of the site for mobile devices. This is normally determined automatically by your device based on its DPI. Sensible values at 100% thumbnail scale are between 640 and 1400.',
      ),
      GroupItem(
        title: 'Gallery Comments',
        child: Column(
          children: [
            _buildSortOrderComment(context),
            _buildShowCommentVotes(context, hideLine: true),
          ],
        ),
      ),
      GroupItem(
        title: 'Gallery Tags',
        child: _buildSortOrderTags(context, hideLine: true),
      ),
      GroupItem(
        title: 'Gallery Page Numbering',
        child: _buildShowPageNumbers(context, hideLine: true),
      ),
      GroupItem(
        title: 'Hentai@Home Local Network Host',
        child: _buildHatHLocalNetworkHost(context),
        desc:
            'This setting can be used if you have a H@H client running on your local network with the same public IP you browse the site with. Some routers are buggy and cannot route requests back to its own IP; this allows you to work around this problem.\n'
            'If you are running the client on the same PC you browse from, use the loopback address (127.0.0.1:port). If the client is running on another computer on your network, use its local network IP. Some browser configurations prevent external web sites from accessing URLs with local network IPs, the site must then be whitelisted for this to work.',
      ),
      GroupItem(
        title: 'Original Images',
        desc:
            'Use original images instead of the resampled versions where applicable?',
        child: _buildOriginalImages(context, hideLine: true),
      ),
      GroupItem(
        title: 'Multi-Page Viewer',
        child: Column(
          children: [
            _buildMPVAlwaysUse(context),
            _buildMPVDisplayStyle(context),
            _buildMPVThumbPane(context, hideLine: true),
          ],
        ),
      ),
    ];

    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }
}

class GroupItem extends StatelessWidget {
  const GroupItem({Key? key, this.title, this.child, this.desc})
      : super(key: key);
  final String? title;
  final Widget? child;
  final String? desc;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          // constraints: const BoxConstraints(minHeight: 38),
          padding: EdgeInsets.only(
            left: 20,
            bottom: 4,
            top: title != null ? 20 : 0,
          ),
          width: double.infinity,
          child: Text(
            title ?? '',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.start,
          ),
        ),
        child ?? const SizedBox.shrink(),
        if (desc != null)
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              top: 4,
              bottom: 10,
              right: 20,
            ),
            width: double.infinity,
            child: Text(
              desc!,
              style: TextStyle(
                fontSize: 12.5,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
              ),
              textAlign: TextAlign.start,
            ),
          ),
      ],
    );
  }
}
