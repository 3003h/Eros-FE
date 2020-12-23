import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';

final Logger logger = Logger(
  filter: EHLogFilter(),
  output: ExampleLogOutput(),
  printer: PrettyPrinter(
    // lineLength: 100,
    colors: false,
  ),
);

final Logger loggerNoStack = Logger(
  filter: EHLogFilter(),
  output: ExampleLogOutput(),
  printer: PrettyPrinter(
    // lineLength: 100,
    methodCount: 0,
    colors: false,
  ),
);

final Logger loggerNoStackTime = Logger(
  output: ExampleLogOutput(),
  printer: PrettyPrinter(
    methodCount: 0,
    colors: false,
    printTime: true,
  ),
);

class ExampleLogOutput extends ConsoleOutput {
  @override
  void output(OutputEvent event) {
    super.output(event);
    LogConsole.add(event);
  }
}

class EHLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (event.level.index >= level.index) {
      return true;
    }
    return false;
  }
}

final Logger loggerForGetx = Logger(
  printer: GetxPrinter(),
  filter: EHLogFilter(),
);

void loggerGetx(String text, {bool isError = false}) {
  if (isError) {
    loggerNoStack.e('[GETX] $text');
  } else if (Get.isLogEnable) {
    loggerForGetx.d('[GETX] $text');
  }
}

class GetxPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    return <String>[event.message];
  }
}
