part of 'eh_mytags_page.dart';

Widget _buildSelectedTagsetItem(BuildContext context, {bool hideLine = false}) {
  return Obx(() {
    final Map<String, String> actionMap = <String, String>{};
    for (final _tagset in _ehMyTagsController.ehMyTags.tagsets) {
      actionMap['${_tagset.value}'] = _tagset.name;
    }
    return SelectorItem<String>(
      key: UniqueKey(),
      title: L10n.of(context).uc_selected,
      actionTitle: 'Select Tagset',
      hideDivider: hideLine,
      actionMap: actionMap,
      initVal: _ehMyTagsController.ehMyTags.tagsets.first.value ?? '',
      onValueChanged: (val) {
        // if (val != _ehMyTagsController.ehSetting.profileSelected) {
        //   _ehMyTagsController.changeProfile(val);
        // }
      },
    );
  });
}
