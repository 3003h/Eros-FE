import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

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
        child: _buildLoadTypeItem(context),
      ),
      GroupItem(
        title: 'Image Size Settings',
        desc:
            'Normally, images are resampled to 1280 pixels of horizontal resolution for online viewing. You can alternatively select one of the following resample resolutions. To avoid murdering the staging servers, resolutions above 1280x are temporarily restricted to donators, people with any hath perk, and people with a UID below 3,000,000.',
        child: _buildImageSizeItem(context),
      ),
      GroupItem(
        title: 'Gallery Name Display',
        desc:
            'Many galleries have both an English/Romanized title and a title in Japanese script. Which gallery name would you like as default?',
        child: _buildNameDisplayItem(context),
      ),
      GroupItem(
        title: 'Archiver Settings',
        desc:
            'The default behavior for the Archiver is to confirm the cost and selection for original or resampled archive, then present a link that can be clicked or copied elsewhere. You can change this behavior here.',
        child: _buildArchiverSettingsItem(context),
      ),
      GroupItem(
        title: 'Front Page Settings',
        child: _buildFrontPageSettingsItem(context),
      ),
      GroupItem(
        title: 'Favorites',
        child: Column(
          children: [
            _buildFavoritesSortItem(context),
          ],
        ),
        desc:
            'You can also select your default sort order for galleries on your favorites page. Note that favorites added prior to the March 2016 revamp did not store a timestamp, and will use the gallery posted time regardless of this setting.',
      ),
      GroupItem(
        title: 'Ratings',
      ),
      GroupItem(
        title: 'Tag Namespaces',
      ),
      GroupItem(
        title: 'Tag Filtering Threshold',
      ),
      GroupItem(
        title: 'Tag Watching Threshold',
      ),
      GroupItem(
        title: 'Excluded Languages',
      ),
      GroupItem(
        title: 'Excluded Uploaders',
      ),
      GroupItem(
        title: 'Search',
        desc:
            'How many results would you like per page for the index/search page and torrent search pages? (Hath Perk: Paging Enlargement Required)',
        child: _buildSearchResultCountItem(context),
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
      ),
      GroupItem(
        title: 'Viewport Override',
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
      ),
      GroupItem(
        title: 'Original Images',
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
          padding: const EdgeInsets.only(
            left: 20,
            bottom: 4,
            top: 20,
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
              style: const TextStyle(
                fontSize: 12.5,
                color: CupertinoColors.secondaryLabel,
              ),
              textAlign: TextAlign.start,
            ),
          ),
      ],
    );
  }
}
