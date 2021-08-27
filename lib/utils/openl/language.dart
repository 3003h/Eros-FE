/// Language object with name and code (ISO)
class Language {
  Language(this.code, this.name);

  final String name;
  final String code;

  @override
  String toString() => name;
}

/// Language list containing all languages supported by openl Translate API
class OpenLLanguageList {
  static final Map<String, String> _langs = {
    'auto': 'Automatic',
    'zh': 'Chinese',
    'en': 'English',
    'de': 'German',
    'fr': 'French',
    'it': 'Italian',
    'ja': 'Japanese',
    'es': 'Spanish',
    'nl': 'Dutch',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'ru': 'Russian',
  };

  Language operator [](String code) {
    code = code.toLowerCase();
    if (_langs.containsKey(code)) {
      return Language(code, _langs[code]!);
    }
    throw LanguageNotSupportedException('$code is not a supported language.');
  }

  static bool contains(String codeOrLang) {
    if (_langs.containsKey(codeOrLang) ||
        _langs.containsValue(codeOrLang.toCamelCase())) {
      return true;
    }
    return false;
  }
}

class LanguageNotSupportedException implements Exception {
  LanguageNotSupportedException(String lang)
      : msg = '$lang is not a supported language.';

  final String msg;
}

extension _CamelCase on String {
  String toCamelCase() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
