class BCDCode {
  BCDCode({this.code0 = '0', this.code1 = '1'});
  final String code0;
  final String code1;

  Map<String, String> get bcdCodeMap => {
        '0': '$code0$code0$code0$code0',
        '1': '$code0$code0$code0$code1',
        '2': '$code0$code0$code1$code0',
        '3': '$code0$code0$code1$code1',
        '4': '$code0$code1$code0$code0',
        '5': '$code0$code1$code0$code1',
        '6': '$code0$code1$code1$code0',
        '7': '$code0$code1$code1$code1',
        '8': '$code1$code0$code0$code0',
        '9': '$code1$code0$code0$code1',
      };

  String enCode(String value) {
    return value.split('').map((e) => bcdCodeMap[e] ?? e).join('');
  }

  String deCode(String value) {
    if (value.trim().length % 4 != 0) {
      return '';
    }

    String codes = '';
    for (int i = 0; i < value.trim().length / 4; i++) {
      final code = value.substring(i * 4, (i + 1) * 4);
      final key = bcdCodeMap.entries
          .map((e) => e)
          .where((element) => element.value == code)
          .first
          .key;
      codes += key;
    }
    return codes;
  }
}

void main() {
  String encodingValue = '1072345';
  String decodingValue = '···∙·····∙∙∙··∙···∙∙·∙···∙·∙';
  // code0 unicode:B7   code1 unicode:2219
  BCDCode bcdCode = BCDCode(code0: '·', code1: '∙');

  var en = bcdCode.enCode(encodingValue);
  print('$en\n');

  var de = bcdCode.deCode(decodingValue);
  print('$de\n');
}
