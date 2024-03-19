import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/pages/gallery/controller/rate_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class RateView extends StatelessWidget {
  const RateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RateController controller = Get.find(tag: pageCtrlTag);
    // logger.d('controller.rate ${controller.rate}  ');
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          return Container(
            child: RatingBar.builder(
              initialRating: ((controller.rate) * 2).round() / 2.0,
              minRating: 0.5,
              glow: false,
              direction: Axis.horizontal,
              allowHalfRating: true,
              unratedColor: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey3, context),
              itemCount: 5,
              // itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (__, _) => Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Row(
                  children: const <Widget>[
                    Icon(
                      FontAwesomeIcons.solidStar,
                      color: Color(0xffFF962E),
                    ),
                    SizedBox(width: 3),
                  ],
                ),
              ),
              onRatingUpdate: (double rating) {
                // logger.d(rating);
                controller.rate = rating;
              },
            ),
          );
        },
      ),
    );
  }
}

Future<void> showRateDialog(BuildContext context) {
  final RateController controller = Get.find(tag: pageCtrlTag);
  return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Rate'),
          content: Container(
            child: const RateView(),
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
                controller.rating();
                Get.back();
              },
            ),
          ],
        );
      });
}
