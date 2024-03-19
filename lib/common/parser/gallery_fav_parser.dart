import 'package:eros_fe/models/base/eh_models.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

FavAdd parserAddFavPage(String? response) {
  // 解析响应信息dom
  final Document document = parse(response);

  final List<Favcat> favList = <Favcat>[];

  late String? select;
  final List<Element> favcats =
      document.querySelectorAll('#galpop > div > div.nosel > div');
  for (final Element fav in favcats) {
    final List<Element> divs = fav.querySelectorAll('div');
    final String favId =
        divs[0].querySelector('input')?.attributes['value']?.trim() ?? '';
    final String checked =
        divs[0].querySelector('input')?.attributes['checked']?.trim() ?? '';
    if (checked.isNotEmpty) {
      select = favId;
    }
    final String favTitle = divs[2].text.trim();
    favList.add(Favcat(favId: favId, favTitle: favTitle));
  }

  // note  #galpop > div > div:nth-child(2) > textarea
  final textareaElm = document.querySelector('textarea');
  final note = textareaElm?.text.trim();
  // print(note);

  return FavAdd(
    favcats: favList.sublist(0, 10),
    usedNoteSlots: '1',
    maxNoteSlots: '100',
    favNote: note,
    selectFavcat: select,
  );
}
