import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_constants.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.scansBox);
    await Hive.openBox(AppConstants.treatmentsBox);
    await Hive.openBox(AppConstants.districtBox);
    await Hive.openBox(AppConstants.userBox);
  }

  static Future<void> save(
    String boxName,
    String key,
    Map<String, dynamic> data,
  ) async {
    final box = Hive.box(boxName);
    await box.put(key, data);
  }

  static Map<String, dynamic>? get(String boxName, String key) {
    final box = Hive.box(boxName);
    final data = box.get(key);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  static List<Map<String, dynamic>> getAll(String boxName) {
    final box = Hive.box(boxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> delete(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  static Future<void> saveString(
    String boxName,
    String key,
    String value,
  ) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  static String? getString(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key) as String?;
  }
}
