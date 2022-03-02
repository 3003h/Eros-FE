part of 'eh_mytags_page.dart';

Widget _buildSelectedTagsetItem(BuildContext context, {bool hideLine = false}) {
  return Obx(() {
    // logger.d('build _buildSelectedTagsetItem');

    final Map<String, String> actionMap = <String, String>{};
    for (final _tagset in _ehMyTagsController.ehMyTags.tagsets) {
      actionMap['${_tagset.value}'] = _tagset.name;
    }

    return SelectorItem<String>(
      key: ValueKey(_ehMyTagsController.currSelected),
      title: L10n.of(context).uc_selected,
      actionTitle: 'Select Tagset',
      hideDivider: hideLine,
      actionMap: actionMap,
      initVal: _ehMyTagsController.currSelected,
      onValueChanged: (val) {
        logger.d('val:$val    ${_ehMyTagsController.currSelected}');
        if (val != _ehMyTagsController.currSelected) {
          _ehMyTagsController.changeTagset(val);
        }
      },
    );
  });
}
