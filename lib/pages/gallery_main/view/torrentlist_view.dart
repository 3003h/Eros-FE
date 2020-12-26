import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/galleryItem.dart';
import 'package:fehviewer/models/galleryTorrent.dart';
import 'package:fehviewer/pages/gallery_main/controller/torrent_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TorrentView extends GetView<TorrentController> {
  const TorrentView({Key key, this.galleryItem}) : super(key: key);
  final GalleryItem galleryItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: controller.torrents.length * 40.0 + 30,
      child: controller.obx(
        (String state) {
          return ListView.builder(
            padding: const EdgeInsets.all(0),
            itemBuilder: (_, int index) {
              final GalleryTorrent torrent = controller.torrents[index];
              return CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  torrent.name,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 14, height: 1),
                ),
                onPressed: () async {
                  final String torrentUrl =
                      'https://ehtracker.org/get/$state/${torrent.hash}.torrent';
                  logger.d('${torrent.name}\n${torrent.hash}\ntorrentUrl');
                  if (await canLaunch(torrentUrl)) {
                    await launch(torrentUrl);
                  } else {
                    throw 'Could not launch $torrentUrl';
                  }
                },
              );
            },
            itemCount: controller.torrents.length,
          );
        },
        onLoading: Container(
          child: const CupertinoActivityIndicator(
            radius: 10,
          ),
        ),
      ),
    );
  }
}

Future<void> showTorrentDiaolog() {
  Get.put(TorrentController());
  return showCupertinoDialog<void>(
      context: Get.overlayContext,
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Text('Torrent'),
          content: Container(
            // height: 100,
            child: const TorrentView(),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(S.of(Get.overlayContext).cancel),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      });
}
