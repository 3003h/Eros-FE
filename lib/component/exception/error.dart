enum EhErrorType {
  banned,

  /// Default error type, Some other Error. In this case, you can
  /// use the DioError.error if it is not null.
  def,

  login,

  image509,

  imageHide,

  parse,
}

class EhError implements Exception {
  EhError({
    this.type = EhErrorType.def,
    this.error,
  });

  EhErrorType type;

  dynamic error;

  String get message => error?.toString() ?? '';

  @override
  String toString() {
    var msg = 'EhError [$type]: $message';
    if (error is Error) {
      msg += '\n${error.stackTrace}';
    }
    return msg;
  }
}
