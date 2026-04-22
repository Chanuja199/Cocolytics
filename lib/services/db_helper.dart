import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scan_model.dart';
import 'dart:convert';

class DBHelper {
  static const String _dbName = 'cocolytics.db';
  static const int _dbVersion = 1;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_history (
        id TEXT PRIMARY KEY,
        userId TEXT,
        imageUrl TEXT,
        diseaseName TEXT,
        botanicalName TEXT,
        scientificName TEXT,
        confidence REAL,
        severity TEXT,
        description TEXT,
        symptoms TEXT,
        district TEXT,
        latitude REAL,
        longitude REAL,
        timestamp TEXT,
        isSynced INTEGER
      )
    ''');
  }

  Future<void> insertScan(ScanModel scan) async {
    final db = await database;
    final map = scan.toMap();
    map['symptoms'] = jsonEncode(scan.symptoms);
    map['isSynced'] = scan.isSynced ? 1 : 0;
    
    await db.insert('scan_history', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ScanModel>> getScans(String userId) async {
    final db = await database;
    final maps = await db.query(
      'scan_history',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['symptoms'] = jsonDecode(map['symptoms'] as String);
      map['isSynced'] = map['isSynced'] == 1;
      return ScanModel.fromMap(map);
    });
  }

  Future<void> deleteScan(String id) async {
    final db = await database;
    await db.delete(
      'scan_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
