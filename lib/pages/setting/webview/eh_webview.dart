import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final InAppWebViewSettings inAppWebViewSettings = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    useHybridComposition: true,
    allowsInlineMediaPlayback: true);
