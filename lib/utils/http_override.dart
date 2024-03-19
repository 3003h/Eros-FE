import 'dart:io';

class DFHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };
    return client;
  }
}

class EhHttpOverrides extends HttpOverrides {
  EhHttpOverrides({
    // this.maxConnectionsPerHost = EHConst.exMaxConnectionsPerHost,
    this.skipCertificateCheck,
  });

  int? maxConnectionsPerHost;
  bool? skipCertificateCheck;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient client = super.createHttpClient(context);
    client
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      }
      ..maxConnectionsPerHost = maxConnectionsPerHost;
    return client;
  }
}
