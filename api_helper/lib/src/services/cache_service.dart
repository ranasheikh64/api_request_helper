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

  Future<void> saveData(String key, dynamic data) async {
    await _box.put(key, jsonEncode(data));
  }

  dynamic getData(String key) {
    final data = _box.get(key);
    if (data != null) {
      return jsonDecode(data);
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
