import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/utils/logger/pretty_printer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import '../const/const.dart';

const kSuffix = '.log';

String? logDirectory;

String? logFileName;

final funcLog = () => Logger(
      filter: EHLogFilter(),
      // printer: SimplePrinter(),
      printer: EhPrettyPrinter(
        // lineLength: 100,
        colors: false,
        printTime: true,
      ),
      output: _outPut,
    );

final funcLogTime = () => Logger(
      filter: EHLogFilter(),
      // printer: SimplePrinter(),
      printer: EhPrettyPrinter(
        // lineLength: 100,
        colors: false,
        printTime: true,
      ),
      output: _outPut,
    );

final funcLog5 = () => Logger(
      filter: EHLogFilter(),
      printer: EhPrettyPrinter(
        // lineLength: 100,
        methodCount: 5,
        colors: false,
      ),
      output: _outPut,
    );

final funcLogNoStack = () => Logger(
      filter: EHLogFilter(),
      printer: EhPrettyPrinter(
        // lineLength: 100,
        methodCount: 0,
        colors: false,
      ),
      output: _outPut,
    );

final funcLogNoStackTime = () => Logger(
      filter: EHLogFilter(),
      printer: EhPrettyPrinter(
        // lineLength: 100,
        methodCount: 0,
        colors: false,
        printTime: true,
      ),
      output: _outPut,
    );

final funcLogSimple = () => Logger(
      filter: EHLogFilter(),
      printer: SimplePrinter(),
      output: _outPut,
    );

final funcLogSimpleOnlyFile = () => Logger(
      filter: EHLogFilter(),
      printer: SimplePrinter(),
      output: (logDirectory != null && logFileName != null)
          ? _FileOutput(
              file: File(
                path.join(logDirectory!, logFileName),
              ),
            )
          : null,
    );

Logger? _logger;
set logger(Logger logger) => _logger = logger;
Logger get logger => _logger ??= funcLog();

// late Logger loggerTime;
Logger? _loggerTime;
set loggerTime(Logger logger) => _loggerTime = logger;
Logger get loggerTime => _loggerTime ??= funcLogTime();

// late Logger logger5;
Logger? _logger5;
set logger5(Logger logger) => _logger5 = logger;
Logger get logger5 => _logger5 ??= funcLog5();

// late Logger loggerNoStack;
Logger? _loggerNoStack;
set loggerNoStack(Logger logger) => _loggerNoStack = logger;
Logger get loggerNoStack => _loggerNoStack ??= funcLogNoStack();

// late Logger loggerNoStackTime;
Logger? _loggerNoStackTime;
set loggerNoStackTime(Logger logger) => _loggerNoStackTime = logger;
Logger get loggerNoStackTime => _loggerNoStackTime ??= funcLogNoStackTime();

// late Logger loggerSimple;
Logger? _loggerSimple;
set loggerSimple(Logger logger) => _loggerSimple = logger;
Logger get loggerSimple => _loggerSimple ??= funcLogSimple();

// late Logger loggerSimpleOnlyFile;
Logger? _loggerSimpleOnlyFile;
set loggerSimpleOnlyFile(Logger logger) => _loggerSimpleOnlyFile = logger;
Logger get loggerSimpleOnlyFile =>
    _loggerSimpleOnlyFile ??= funcLogSimpleOnlyFile();

final LogOutput _outPut = MultiOutput([
  ConsoleOutput(),
  if (logDirectory != null && logFileName != null)
    _FileOutput(
      file: File(
        path.join(logDirectory!, logFileName),
      ),
    ),
]);

void _initFile({String? directory, String? fileName}) {
  logDirectory = directory ??
      path.join(GetPlatform.isAndroid ? Global.extStorePath : Global.appDocPath,
          'log');
  if (!Directory(logDirectory!).existsSync()) {
    Directory(logDirectory!).createSync(recursive: true);
  }

  final DateTime _now = DateTime.now();
  final DateFormat formatter = DateFormat(kFilenameFormat);
  final String _fileName = formatter.format(_now);
  logFileName = fileName ?? '$_fileName$kSuffix';
}

void initLogger({bool isolate = false, String? directory, String? fileName}) {
  if (!isolate) {
    _initFile(
      directory: directory,
      fileName: fileName,
    );
  }
  initLoggerValue();
}

void resetLogLevel() {
  initLoggerValue();
}

void initLoggerValue() {
  logger = funcLog();
  loggerTime = funcLogTime();
  logger5 = funcLog5();
  loggerNoStack = funcLogNoStack();
  loggerNoStackTime = funcLogNoStackTime();
  loggerSimple = funcLogSimple();
  loggerSimpleOnlyFile = funcLogSimpleOnlyFile();
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
    // loggerSimple.e('[GETX] ==> $text');
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
  Future<void> init() async {
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

    _sink?.writeAll(event.lines.map((e) => _dataMasking(e)), '\n');
    _sink?.write('\n');
  }

  String _dataMasking(String ori) {
    RegExp _reId = RegExp(r'(ipb_member_id=)(\d+)(;?)');
    RegExp _rePass = RegExp(r'(ipb_pass_hash=)([a-f0-9]+)(;?)');
    RegExp _reIgneous = RegExp(r'(igneous=)([a-f0-9]+)(;?)');
    return ori
        .replaceAllMapped(
            _reId,
            (match) =>
                '${match.group(1)}${match.group(2)?.substring(0, min(2, match.group(2)!.length))}****${match.group(3)}')
        .replaceAllMapped(
            _rePass,
            (match) =>
                '${match.group(1)}${match.group(2)?.substring(0, min(2, match.group(2)!.length))}****${match.group(3)}')
        .replaceAllMapped(
            _reIgneous,
            (match) =>
                '${match.group(1)}${match.group(2)?.substring(0, min(2, match.group(2)!.length))}****${match.group(3)}');
  }

  @override
  Future<void> destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
