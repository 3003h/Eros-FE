import 'dart:convert';

import 'package:flutter/services.dart';

Future<String?> getSentryDsn() async {
  final String sentry = await rootBundle.loadString('assets/sentry.json');
  final jsonObj = json.decode(sentry);
  return jsonObj['dsn'] as String?;
}
