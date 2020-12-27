enum EhErrorType {
  BANNED,

  /// Default error type, Some other Error. In this case, you can
  /// use the DioError.error if it is not null.
  DEFAULT,
}

class EhError implements Exception {
  EhError({
    this.type = EhErrorType.DEFAULT,
    this.error,
  });

  EhErrorType type;

  dynamic error;

  String get message => error?.toString() ?? '';

  @override
  String toString() {
    var msg = 'DioError [$type]: $message';
    if (error is Error) {
      msg += '\n${error.stackTrace}';
    }
    return msg;
  }
}
