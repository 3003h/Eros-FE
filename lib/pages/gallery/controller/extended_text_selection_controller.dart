import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const double _kHandleSize = 22.0;

// Padding between the toolbar and the anchor.
const double _kToolbarContentDistanceBelow = _kHandleSize - 2.0;
const double _kToolbarContentDistance = 8.0;

/// Android Material styled text selection controls.
class EHTextSelectionControls extends MaterialTextSelectionControls {
  EHTextSelectionControls({this.joinZeroWidthSpace = false});
  final bool joinZeroWidthSpace;

  @override
  void handleCopy(TextSelectionDelegate delegate,
      ClipboardStatusNotifier? clipboardStatus) {
    final TextEditingValue value = delegate.textEditingValue;

    String data = value.selection.textInside(value.text);
    // remove zeroWidthSpace
    if (joinZeroWidthSpace) {
      data = data.replaceAll(zeroWidthSpace, '');
    }
    Clipboard.setData(ClipboardData(
      text: value.selection.textInside(value.text),
    ));
    clipboardStatus?.update();
    delegate.userUpdateTextEditingValue(
        TextEditingValue(
          text: value.text,
          selection: TextSelection.collapsed(offset: value.selection.end),
        ),
        SelectionChangedCause.toolBar);
    delegate.bringIntoView(delegate.textEditingValue.selection.extent);
    delegate.hideToolbar();
  }

  /// Returns the size of the Material handle.
  @override
  Size getHandleSize(double textLineHeight) =>
      const Size(_kHandleSize, _kHandleSize);

  /// Builder for material-style copy/paste text selection toolbar.
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _TextSelectionControlsToolbar(
      globalEditableRegion: globalEditableRegion,
      textLineHeight: textLineHeight,
      selectionMidpoint: selectionMidpoint,
      endpoints: endpoints,
      delegate: delegate,
      clipboardStatus: clipboardStatus,
      handleCut: canCut(delegate) ? () => handleCut(delegate) : null,
      handleCopy: canCopy(delegate)
          ? () => handleCopy(delegate, clipboardStatus)
          : null,
      handlePaste: canPaste(delegate) ? () => handlePaste(delegate) : null,
      handleSelectAll:
          canSelectAll(delegate) ? () => handleSelectAll(delegate) : null,
      handleTranslate: () {
        launch(
            'mailto:honjow311@gmail.com?subject=extended_text_share&body=${delegate.textEditingValue.text}');
        delegate.hideToolbar();
        delegate.userUpdateTextEditingValue(
            delegate.textEditingValue
                .copyWith(selection: const TextSelection.collapsed(offset: 0)),
            SelectionChangedCause.toolBar);
      },
    );
  }

  /// Builder for material-style text selection handles.
  // @override
  // Widget buildHandle(
  //     BuildContext context, TextSelectionHandleType type, double textHeight) {
  //   final Widget handle = SizedBox(
  //     width: _kHandleSize,
  //     height: _kHandleSize,
  //     child: Image.asset(
  //       'assets/40.png',
  //     ),
  //   );
  //
  //   // [handle] is a circle, with a rectangle in the top left quadrant of that
  //   // circle (an onion pointing to 10:30). We rotate [handle] to point
  //   // straight up or up-right depending on the handle type.
  //   switch (type) {
  //     case TextSelectionHandleType.left: // points up-right
  //       return Transform.rotate(
  //         angle: -math.pi * 3 / 4.0,
  //         child: handle,
  //       );
  //     case TextSelectionHandleType.right: // points up-left
  //       return Transform.rotate(
  //         angle: math.pi * 3 / 4.0,
  //         child: handle,
  //       );
  //     case TextSelectionHandleType.collapsed: // points up
  //       return handle;
  //   }
  // }

  /// Gets anchor for material-style text selection handles.
  ///
  /// See [TextSelectionControls.getHandleAnchor].
  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    switch (type) {
      case TextSelectionHandleType.left:
        return const Offset(_kHandleSize, 0);
      case TextSelectionHandleType.right:
        return Offset.zero;
      default:
        return const Offset(_kHandleSize / 2, -4);
    }
  }

  @override
  bool canSelectAll(TextSelectionDelegate delegate) {
    // Android allows SelectAll when selection is not collapsed, unless
    // everything has already been selected.
    final TextEditingValue value = delegate.textEditingValue;
    return delegate.selectAllEnabled &&
        value.text.isNotEmpty &&
        !(value.selection.start == 0 &&
            value.selection.end == value.text.length);
  }
}

// The label and callback for the available default text selection menu buttons.
class _TextSelectionToolbarItemData {
  const _TextSelectionToolbarItemData({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;
}

// The highest level toolbar widget, built directly by buildToolbar.
class _TextSelectionControlsToolbar extends StatefulWidget {
  const _TextSelectionControlsToolbar({
    Key? key,
    required this.clipboardStatus,
    required this.delegate,
    required this.endpoints,
    required this.globalEditableRegion,
    required this.handleCut,
    required this.handleCopy,
    required this.handlePaste,
    required this.handleSelectAll,
    required this.selectionMidpoint,
    required this.textLineHeight,
    required this.handleTranslate,
  }) : super(key: key);

  final ClipboardStatusNotifier clipboardStatus;
  final TextSelectionDelegate delegate;
  final List<TextSelectionPoint> endpoints;
  final Rect globalEditableRegion;
  final VoidCallback? handleCut;
  final VoidCallback? handleCopy;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;
  final VoidCallback handleTranslate;
  final Offset selectionMidpoint;
  final double textLineHeight;

  @override
  _TextSelectionControlsToolbarState createState() =>
      _TextSelectionControlsToolbarState();
}

class _TextSelectionControlsToolbarState
    extends State<_TextSelectionControlsToolbar> with TickerProviderStateMixin {
  void _onChangedClipboardStatus() {
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
    });
  }

  @override
  void initState() {
    super.initState();
    widget.clipboardStatus.addListener(_onChangedClipboardStatus);
    widget.clipboardStatus.update();
  }

  @override
  void didUpdateWidget(_TextSelectionControlsToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clipboardStatus != oldWidget.clipboardStatus) {
      widget.clipboardStatus.addListener(_onChangedClipboardStatus);
      oldWidget.clipboardStatus.removeListener(_onChangedClipboardStatus);
    }
    widget.clipboardStatus.update();
  }

  @override
  void dispose() {
    super.dispose();
    // When used in an Overlay, it can happen that this is disposed after its
    // creator has already disposed _clipboardStatus.
    if (!widget.clipboardStatus.disposed) {
      widget.clipboardStatus.removeListener(_onChangedClipboardStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there are no buttons to be shown, don't render anything.
    if (widget.handleCut == null &&
        widget.handleCopy == null &&
        widget.handlePaste == null &&
        widget.handleSelectAll == null) {
      return const SizedBox.shrink();
    }
    // If the paste button is desired, don't render anything until the state of
    // the clipboard is known, since it's used to determine if paste is shown.
    if (widget.handlePaste != null &&
        widget.clipboardStatus.value == ClipboardStatus.unknown) {
      return const SizedBox.shrink();
    }

    // Calculate the positioning of the menu. It is placed above the selection
    // if there is enough room, or otherwise below.
    final TextSelectionPoint startTextSelectionPoint = widget.endpoints[0];
    final TextSelectionPoint endTextSelectionPoint =
        widget.endpoints.length > 1 ? widget.endpoints[1] : widget.endpoints[0];
    final Offset anchorAbove = Offset(
        widget.globalEditableRegion.left + widget.selectionMidpoint.dx,
        widget.globalEditableRegion.top +
            startTextSelectionPoint.point.dy -
            widget.textLineHeight -
            _kToolbarContentDistance);
    final Offset anchorBelow = Offset(
      widget.globalEditableRegion.left + widget.selectionMidpoint.dx,
      widget.globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          _kToolbarContentDistanceBelow,
    );

    // Determine which buttons will appear so that the order and total number is
    // known. A button's position in the menu can slightly affect its
    // appearance.
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final List<_TextSelectionToolbarItemData> itemDatas =
        <_TextSelectionToolbarItemData>[
      if (widget.handleCut != null)
        _TextSelectionToolbarItemData(
          label: localizations.cutButtonLabel,
          onPressed: widget.handleCut,
        ),
      if (widget.handleCopy != null)
        _TextSelectionToolbarItemData(
          label: localizations.copyButtonLabel,
          onPressed: widget.handleCopy,
        ),
      if (widget.handlePaste != null &&
          widget.clipboardStatus.value == ClipboardStatus.pasteable)
        _TextSelectionToolbarItemData(
          label: localizations.pasteButtonLabel,
          onPressed: widget.handlePaste,
        ),
      if (widget.handleSelectAll != null)
        _TextSelectionToolbarItemData(
          label: localizations.selectAllButtonLabel,
          onPressed: widget.handleSelectAll,
        ),
      _TextSelectionToolbarItemData(
        label: 'translate',
        onPressed: widget.handleTranslate,
      ),
    ];

    // If there is no option available, build an empty widget.
    if (itemDatas.isEmpty) {
      return const SizedBox(width: 0.0, height: 0.0);
    }

    return TextSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      children: itemDatas
          .asMap()
          .entries
          .map((MapEntry<int, _TextSelectionToolbarItemData> entry) {
        return TextSelectionToolbarTextButton(
          padding: TextSelectionToolbarTextButton.getPadding(
              entry.key, itemDatas.length),
          onPressed: entry.value.onPressed,
          child: entry.value.label == 'translate'
              ? const Icon(
                  Icons.translate,
                  size: 18,
                )
              : Text(entry.value.label),
        );
      }).toList(),
    );
  }
}
