import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';

class SingleInputPage extends StatelessWidget {
  const SingleInputPage({
    Key? key,
    this.title,
    this.previousPageTitle,
    this.onValueChanged,
    this.initValue,
    this.suffixText,
    this.placeholder,
    this.maxLines,
  }) : super(key: key);
  final String? title;
  final String? previousPageTitle;
  final String? initValue;
  final ValueChanged<String>? onValueChanged;
  final String? suffixText;
  final String? placeholder;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController =
        TextEditingController(text: initValue);
    textController.addListener(() {
      onValueChanged?.call(textController.text);
    });

    logger.d('ehTheme.isDarkMode ${ehTheme.isDarkMode}');

    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      navigationBar: CupertinoNavigationBar(
        middle: Text(title ?? ''),
        // previousPageTitle: previousPageTitle,
      ),
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CupertinoTextField(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 8.0),
                  maxLines: maxLines,
                  // minLines: 1,
                  suffix: suffixText != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(suffixText!),
                        )
                      : null,
                  // textInputAction: TextInputAction.done,
                  decoration: BoxDecoration(
                    color: ehTheme.textFieldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  controller: textController,
                  placeholderStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: CupertinoColors.placeholderText,
                    height: 1.25,
                  ),
                  placeholder: placeholder,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  autofocus: true,
                  style: const TextStyle(height: 1.25),
                  // onEditingComplete: () {
                  //   FocusScope.of(context).requestFocus(FocusNode());
                  // },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
