import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

StorageUtil storageUtil = StorageUtil();

/// 本地存储
class StorageUtil {
  factory StorageUtil() => _instance;

  StorageUtil._();

  static final StorageUtil _instance = StorageUtil._();
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool>? setJSON(String key, dynamic jsonVal) {
    final String jsonString = jsonEncode(jsonVal);
    return _prefs?.setString(key, jsonString);
  }

  dynamic getJSON(String key) {
    final String? jsonString = _prefs?.getString(key);
    return jsonString;
  }

  Future<bool>? setString(String key, String val) {
    return _prefs?.setString(key, val);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<bool>? setBool(String key, bool val) {
    return _prefs?.setBool(key, val);
  }

  bool? getBool(String key) {
    final bool? val = _prefs?.getBool(key);
    return val;
  }

  Future<bool>? remove(String key) {
    return _prefs?.remove(key);
  }
}
