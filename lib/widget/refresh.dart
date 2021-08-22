import 'package:flutter/cupertino.dart';

const double kDefaultRefreshTriggerPullDistance = 130.0;

class EhCupertinoSliverRefreshControl extends StatelessWidget {
  const EhCupertinoSliverRefreshControl({Key? key, this.onRefresh})
      : super(key: key);

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
