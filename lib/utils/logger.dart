import 'dart:convert';
import 'dart:io';

import 'package:fehviewer/common/service/log_service.dart';
import 'package:fehviewer/utils/logger/pretty_printer.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

String get _fileName => Get.find<LogService>().curFileName;
String get _filePath => Get.find<LogService>().logPath;

late Logger logger;

late Logger logger5;

late Logger loggerNoStack;

late Logger loggerNoStackTime;

late Logger loggerSimple;

final LogOutput _outPut = MultiOutput([
  ConsoleOutput(),
  _FileOutput(
    file: File(
      path.join(_filePath, _fileName),
    ),
  ),
]);

void resetLogLevel() {
  initLogger();
}

void initLogger() {
  logger = Logger(
    // level: _logLevel,
    filter: EHLogFilter(),
    // printer: SimplePrinter(),
    printer: EhPrettyPrinter(
      // lineLength: 100,
      colors: false,
      // printTime: true,
    ),
    output: _outPut,
  );

  logger5 = Logger(
    filter: EHLogFilter(),
    printer: EhPrettyPrinter(
      // lineLength: 100,
      methodCount: 5,
      colors: false,
    ),
    output: _outPut,
  );

  loggerNoStack = Logger(
    filter: EHLogFilter(),
    printer: EhPrettyPrinter(
      // lineLength: 100,
      methodCount: 0,
      colors: false,
    ),
    output: _outPut,
  );

  loggerNoStackTime = Logger(
    printer: EhPrettyPrinter(
      methodCount: 0,
      colors: false,
      printTime: true,
    ),
  );

  loggerSimple = Logger(
    filter: EHLogFilter(),
    printer: SimplePrinter(),
    output: _outPut,
  );
}

class EHLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (event.level.index >= level!.index) {
      return true;
    }
    return false;
  }
}

final Logger loggerForGetx = Logger(
  printer: SimplePrinter(),
  filter: EHLogFilter(),
);

void loggerGetx(String text, {bool isError = false}) {
  if (isError) {
    loggerNoStack.e('[GETX] ==> $text');
  } else if (Get.isLogEnable) {
    loggerForGetx.d('[GETX] ==> $text');
  }
}

/// Writes the log output to a file.
class _FileOutput extends LogOutput {
  _FileOutput({
    required this.file,
    this.overrideExisting = false,
    this.encoding = utf8,
  });

  final File file;
  final bool overrideExisting;
  final Encoding encoding;
  IOSink? _sink;

  @override
  void init() {
    _sink = file.openWrite(
      mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
      encoding: encoding,
    );
  }

  @override
  void output(OutputEvent event) {
    // file.writeAsString(
    //   '${event.lines.map((e) => e.trim()).join('\n')}\n',
    //   mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
    //   encoding: encoding,
    //   flush: true,
    // );

    _sink?.writeAll(event.lines, '\n');
    _sink?.write('\n');
  }

  @override
  void destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
