class MorseCode {
  MorseCode({this.di = '.', this.dah = '-'});

  final String di;
  final String dah;

  Map<String, String> get morseCodeMap => {
        'A': '$di$dah',
        'B': '$dah$di$di$di',
        'C': '$dah$di$dah$di',
        'D': '$dah$di$di',
        'E': '$di',
        'F': '$di$di$dah$di',
        'G': '$dah$dah$di',
        'H': '$di$di$di$di',
        'I': '$di$di',
        'J': '$di$dah$dah$dah',
        'K': '$dah$di$dah',
        'L': '$di$dah$di$di',
        'M': '$dah$dah',
        'N': '$dah$di',
        'O': '$dah$dah$dah',
        'P': '$di$dah$dah$di',
        'Q': '$dah$dah$di$dah',
        'R': '$di$dah$di',
        'S': '$di$di$di',
        'T': '$dah',
        'U': '$di$di$dah',
        'V': '$di$di$di$dah',
        'W': '$di$dah$dah',
        'X': '$dah$di$di$dah',
        'Y': '$dah$di$dah$dah',
        'Z': '$dah$dah$di$di',
        '1': '$di$dah$dah$dah$dah',
        '2': '$di$di$dah$dah$dah',
        '3': '$di$di$di$dah$dah',
        '4': '$di$di$di$di$dah',
        '5': '$di$di$di$di$di',
        '6': '$dah$di$di$di$di',
        '7': '$dah$dah$di$di$di',
        '8': '$dah$dah$dah$di$di',
        '9': '$dah$dah$dah$dah$di',
        '0': '$dah$dah$dah$dah$dah',
        ',': '$dah$dah$di$di$dah$dah',
        '.': '$di$dah$di$dah$di$dah',
        '?': '$di$di$dah$dah$di$di',
        '/': '$dah$di$di$dah$di',
        '-': '$dah$di$di$di$di$dah',
        '(': '$dah$di$dah$dah$di',
        ')': '$dah$di$dah$dah$di$dah',
        "'": '$di$dah$dah$dah$dah$di',
        '"': '$di$dah$di$di$dah$di'
      };

  String? value = '';
  String? value2 = '';
  // MorseCode([this.value, this.value2]);
  String enCode(String value) {
    var name = value.toUpperCase();
    var morseCode = '';
    var listString = name.split('');
    var indexList = morseCodeMap.keys.toList();
    // print(indexList.indexOf(" "));
    for (int i = 0; i < listString.length; i++) {
      if (listString[i] == ' ') {
        morseCode += '/ ';
      } else {
        morseCode +=
            morseCodeMap.values.elementAt(indexList.indexOf(listString[i])) +
                ' ';
      }
    }
    return morseCode;
  }

  String deCode(String value2) {
    var mName = value2.split(' ');
    int j = 0;
    String decodedMorse = '';
    for (j; j < mName.length; j++) {
      if (mName[j] == '/') {
        decodedMorse += ' ';
      } else {
        int indexofMorse = morseCodeMap.values.toList().indexOf(mName[j]);
        final correspondingAlphaValue =
            morseCodeMap.keys.toList()[indexofMorse];
        decodedMorse += correspondingAlphaValue;
      }
    }
    return decodedMorse;
  }
}

void main() {
  String encodingValue = '123456';
  String decodingValue =
      '.... .. / - .... . .-. . / .... --- .-- / .- .-. . / -.-- --- ..- ..--..';
  MorseCode meroMorseCode = MorseCode(di: '.', dah: '_');
  var en = meroMorseCode.enCode(encodingValue);
  // var de = meroMorseCode.deCode(decodingValue);
  print("The String '$encodingValue' is encoded to corresponding morse code:");
  print('$en\n');
  // print("The morse code '$decodingValue' is decoded to corresponding String:");
  // print(de);
}
