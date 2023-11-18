import 'package:flutter/cupertino.dart';

const double kNavBarBackButtonTapWidth = 50.0;
const double kNavBarLargeTitleHeightExtension = 52.0;


const double kTopTabbarHeight = kMinInteractiveDimensionCupertino;

const double kHeaderMaxHeight =
    kMinInteractiveDimensionCupertino + kTopTabbarHeight + 8;

const Color _kDefaultNavBarBorderColor = Color(0x4D000000);
const Border kDefaultNavBarBorder = Border(
  bottom: BorderSide(
    color: _kDefaultNavBarBorderColor,
    width: 0.0, // One physical pixel.
    style: BorderStyle.solid,
  ),
);
