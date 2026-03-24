import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static const String _boxName = 'api_cache';
  late Box _box;

  Future<void> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final directory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(directory.path);
    }
    _box = await Hive.openBox(_boxName);
  }

  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> setAccessToken(String token) async => await _box.put(_tokenKey, token);
  String? getAccessToken() => _box.get(_tokenKey);

  Future<void> setRefreshToken(String token) async => await _box.put(_refreshTokenKey, token);
  String? getRefreshToken() => _box.get(_refreshTokenKey);

  Future<void> deleteToken() async {
    await _box.delete(_tokenKey);
    await _box.delete(_refreshTokenKey);
  }

  Future<void> saveData(String key, dynamic data) async {
    await _box.put(key, jsonEncode(data));
  }

  dynamic getData(String key) {
    final data = _box.get(key);
    if (data != null) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    return null;
  }

  Future<void> clearCache() async {
    await _box.clear();
  }

  bool hasData(String key) {
    return _box.containsKey(key);
  }
}
