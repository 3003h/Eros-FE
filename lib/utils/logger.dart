import 'dart:convert';
import 'dart:io';

import 'package:fehviewer/common/service/log_service.dart';
import 'package:fehviewer/utils/pretty_printer.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:logger/src/log_output.dart';
import 'package:logger/src/logger.dart';
import 'package:path/path.dart' as path;

String get _fileName => Get.find<LogService>().curFileName;
String get _filePath => Get.find<LogService>().logPath;

final LogOutput _outPut = MultiOutput([
  ConsoleOutput(),
  _FileOutput(
    file: File(
      path.join(_filePath, _fileName),
    ),
  ),
]);

Logger get logger => Logger(
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

Logger get logger5 => Logger(
      filter: EHLogFilter(),
      printer: PrettyPrinter(
        // lineLength: 100,
        methodCount: 5,
        colors: false,
      ),
      output: _outPut,
    );

Logger get loggerNoStack => Logger(
      filter: EHLogFilter(),
      printer: PrettyPrinter(
        // lineLength: 100,
        methodCount: 0,
        colors: false,
      ),
      output: _outPut,
    );

final Logger loggerNoStackTime = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    colors: false,
    printTime: true,
  ),
);

Logger get loggerSimple => Logger(
      printer: SimplePrinter(),
      output: _outPut,
    );

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
    // _sink = file.openWrite(
    //   mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
    //   encoding: encoding,
    // );
  }

  @override
  void output(OutputEvent event) {
    // _sink?.writeAll(event.lines.map((e) => e.trim()), '\n');
    file.writeAsString(
      event.lines.map((e) => e.trim()).join('\n'),
      mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
    );
  }

  @override
  void destroy() async {
    // _sink?.write('\n');
    // await _sink?.flush();
    // await _sink?.close();
  }
}
