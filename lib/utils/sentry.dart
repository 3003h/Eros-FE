import '../config/config.dart';

Future<String?> getSentryDsn() async {
  // try {
  //   final String sentry = await rootBundle.loadString('assets/sentry.json');
  //   final jsonObj = json.decode(sentry);
  //   return jsonObj['dsn'] as String?;
  // } catch (_) {}
  return FeConfig.sentryDsn;
}
