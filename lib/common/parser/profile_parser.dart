import 'package:fehviewer/models/base/eh_models.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

Uconfig parseUconfig(String html) {
  final profileSet = <EhProfile>[];

  final Document document = parse(html);

  final Element? profileSetElm =
      document.querySelector('#profile_form > select');
  late String selectedName = '';
  if (profileSetElm != null) {
    final profiles = profileSetElm.children;
    for (final pf in profiles) {
      final value = pf.attributes['value'];
      if (value == null) {
        continue;
      }
      final selected = pf.attributes['selected'] == 'selected';

      final name = pf.text.split(RegExp(r'\s')).first;
      if (selected) {
        selectedName = name;
      }

      profileSet.add(
          EhProfile(name: name, selected: selected, value: int.parse(value)));
    }
  }

  return Uconfig(profilelist: profileSet, profileSelected: selectedName);
}
