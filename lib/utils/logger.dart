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

class ExampleLogOutput extends ConsoleOutput {
  @override
  void output(OutputEvent event) {
    super.output(event);
    LogConsole.add(event);
  }
}
