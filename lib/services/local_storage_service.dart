import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_constants.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    // Open all boxes we need
    await Hive.openBox(AppConstants.scansBox);
    await Hive.openBox(AppConstants.treatmentsBox);
    await Hive.openBox(AppConstants.districtBox);
    await Hive.openBox(AppConstants.userBox);
  }

  // Save any map to a box
  static Future<void> save(
    String boxName,
    String key,
    Map<String, dynamic> data,
  ) async {
    final box = Hive.box(boxName);
    await box.put(key, data);
  }

  // Get one item
  static Map<String, dynamic>? get(String boxName, String key) {
    final box = Hive.box(boxName);
    final data = box.get(key);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // Get all items in a box
  static List<Map<String, dynamic>> getAll(String boxName) {
    final box = Hive.box(boxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Delete one item
  static Future<void> delete(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  // Save a simple string value
  static Future<void> saveString(
    String boxName,
    String key,
    String value,
  ) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  // Get a simple string value
  static String? getString(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key) as String?;
  }
}
