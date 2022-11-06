import 'package:flutter/cupertino.dart';

class AppCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const AppCupertinoLocalizations(this._cupertinoLocalizations);

  final CupertinoLocalizations _cupertinoLocalizations;

  @override
  String datePickerMonth(int monthIndex) {
    return '$monthIndex';
  }

  @override
  String datePickerYear(int yearIndex) {
    return '$yearIndex';
  }

  @override
  String datePickerDayOfMonth(int dayIndex) {
    return '$dayIndex';
  }
}
