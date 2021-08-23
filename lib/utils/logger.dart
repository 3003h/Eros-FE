import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/utils/logger/pretty_printer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

const kFilenameFormat = 'yyyy-MM-dd HH:mm:ss';
const kSuffix = '.log';

String? logDirectory;

String? logFileName;

late Logger logger;

late Logger loggerTime;

late Logger logger5;

late Logger loggerNoStack;

late Logger loggerNoStackTime;

late Logger loggerSimple;

late Logger loggerSimpleOnlyFile;

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
  logger = Logger(
    filter: EHLogFilter(),
    // printer: SimplePrinter(),
    printer: EhPrettyPrinter(
      // lineLength: 100,
      colors: false,
      // printTime: true,
    ),
    output: _outPut,
  );

  loggerTime = Logger(
    filter: EHLogFilter(),
    // printer: SimplePrinter(),
    printer: EhPrettyPrinter(
      // lineLength: 100,
      colors: false,
      printTime: true,
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

  loggerSimpleOnlyFile = Logger(
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
  void destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
