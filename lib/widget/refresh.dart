import 'package:flutter/cupertino.dart';

const double kDefaultRefreshTriggerPullDistance = 100.0;

class EhCupertinoSliverRefreshControl extends StatelessWidget {
  const EhCupertinoSliverRefreshControl({super.key, this.onRefresh});

  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
      refreshTriggerPullDistance: kDefaultRefreshTriggerPullDistance,
      // refreshIndicatorExtent: 100,
    );
  }
}
