import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/tab/controller/group/profile_edit_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ProfileSearchTextDialog extends StatelessWidget {
  const ProfileSearchTextDialog({super.key});

  ProfileEditController get profileEditController => Get.find();

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16,
      color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
    );

    final translateStyle = TextStyle(
      fontSize: 14,
      color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondaryLabel, context),
    );

    final highLightTextStyle = TextStyle(
      fontSize: 16,
      color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context),
    );

    final highLightTranslateStyle = TextStyle(
      fontSize: 14,
      color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context),
    );

    return Column(
      children: [
        CupertinoTextField(
          controller: profileEditController.textController,
          placeholder: L10n.of(context).newText,
          placeholderStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            color: CupertinoColors.placeholderText,
            height: 1.25,
          ),
          style: const TextStyle(height: 1.2),
          autofocus: true,
          onChanged: (value) {
            profileEditController.searchText = value.trim();
          },
        ),
        Obx(() {
          final _resultList = profileEditController.resultList;
          return Container(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemBuilder: (context, index) {
                final _trans = _resultList[index];

                final input = profileEditController.searchText;
                final text = _trans.fullTagText;
                final translate = _trans.fullTagTranslate;

                final textSpans = text
                    ?.split(input)
                    .map((e) => TextSpan(
                          text: e,
                          style: textStyle,
                        ))
                    .separat(
                        separator: TextSpan(
                      text: input,
                      style: highLightTextStyle,
                    ));

                final translateTextSpans = translate
                    ?.split(input)
                    .map((e) => TextSpan(
                          text: e,
                          style: translateStyle,
                        ))
                    .separat(
                        separator: TextSpan(
                      text: input,
                      style: highLightTranslateStyle,
                    ));

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => profileEditController.selectItem(
                    index,
                    searchTextController: profileEditController.textController,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: textSpans,
                        ),
                      ),
                      if (translate != null) const SizedBox(height: 6),
                      if (translate != null &&
                          profileEditController.isTagTranslate)
                        RichText(
                          text: TextSpan(
                            children: translateTextSpans,
                          ),
                        ),
                    ],
                  ).paddingSymmetric(vertical: 8),
                );
              },
              itemCount: _resultList.length,
            ),
          );
        }),
      ],
    );
  }
}

Future<String?> showSearchTextDialog(BuildContext context) {
  final ProfileEditController profileEditController = Get.find();
  profileEditController.searchText = '';
  profileEditController.textController.text = '';
  return showCupertinoDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return CupertinoAlertDialog(
          // title: Text(L10n.of(Get.context!).p_Archiver),
          content: Container(
            child: const ProfileSearchTextDialog(),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(L10n.of(context).cancel),
              onPressed: () {
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text(L10n.of(context).ok),
              onPressed: () {
                Get.back(result: profileEditController.textController.text);
              },
            ),
          ],
        );
      });
}
