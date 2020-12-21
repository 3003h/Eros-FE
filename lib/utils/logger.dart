import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';

final Logger logger = Logger(
  output: ExampleLogOutput(),
  printer: PrettyPrinter(
    // lineLength: 100,
    colors: false,
  ),
);

final Logger loggerNoStack = Logger(
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

void loggerGetx(String text, {bool isError = false}) {
  // print('** $text [$isError]');
  if (isError) {
    loggerNoStack.e('[GETX] $text');
  } else if (Get.isLogEnable) {
    // loggerNoStack.d('[GETX] $text');
    print('[GETX] $text');
  }
}
