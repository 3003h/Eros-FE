import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

class GalleryFavParser {
  static List<Favcat> parserAddFavPage(String? response) {
    // 解析响应信息dom
    final Document document = parse(response);

    logger.v('frome parserAddFavPage');

    final List<Favcat> favList = <Favcat>[];

    final List<Element> favcats =
        document.querySelectorAll('#galpop > div > div.nosel > div');
    for (final Element fav in favcats) {
      final List<Element> divs = fav.querySelectorAll('div');
      final String favId =
          divs[0].querySelector('input')?.attributes['value']?.trim() ?? '';
      final String favTitle = divs[2].text.trim();
      favList.add(Favcat(favId: favId, favTitle: favTitle));
    }

    return favList.sublist(0, 10);
  }
}
