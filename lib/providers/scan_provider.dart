import 'package:flutter/foundation.dart';
import '../models/scan_model.dart';
import '../services/ml_service.dart';
import '../services/db_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/map_service.dart';

enum ScanState { idle, loading, success, error }

class ScanProvider extends ChangeNotifier {
  final MLService _mlService = MLService();
  final DBHelper _dbHelper = DBHelper();

  ScanState _state = ScanState.idle;
  ScanModel? _currentScan;
  List<ScanModel> _scanHistory = [];
  String _errorMessage = '';

  ScanState get state => _state;
  ScanModel? get currentScan => _currentScan;
  List<ScanModel> get scanHistory => _scanHistory;
  String get errorMessage => _errorMessage;

  /// Processes a leaf image, saves results locally, and performs a background sync.
  Future<void> scanLeaf({
    required String imagePath,
    required String userId,
    required String district,
    double? latitude,
    double? longitude,
    required bool isOnline,
  }) async {
    _state = ScanState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final scan = await _mlService.classifyOffline(
        imagePath: imagePath,
        userId: userId,
        district: district,
        latitude: latitude,
        longitude: longitude,
        isOnline: isOnline,
      );

      _currentScan = scan;
      await _dbHelper.insertScan(scan);

      _scanHistory.insert(0, scan);
      _state = ScanState.success;
      notifyListeners();

      if (isOnline) {
        _syncToFirestore(scan, district);
      }

      return;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = ScanState.error;
    }

    notifyListeners();
  }

  /// Silently syncs local scan data to Firestore without blocking the UI.
  void _syncToFirestore(ScanModel scan, String district) {
    Future(() async {
      try {
        await FirebaseFirestore.instance
            .collection('scans')
            .doc(scan.id)
            .set(scan.copyWith(isSynced: true).toMap())
            .timeout(const Duration(seconds: 10));

        await MapService().updateDistrictCount(
          district: district,
          diseaseName: scan.diseaseName,
        ).timeout(const Duration(seconds: 10));

        debugPrint('Firestore sync complete for scan ${scan.id}');
      } catch (e) {
        debugPrint('Firestore sync failed (will retry later): $e');
      }
    });
  }

  /// Loads the user's scan history from the local SQLite database.
  Future<void> loadScanHistory(String userId) async {
    _scanHistory = await _dbHelper.getScans(userId);
    notifyListeners();
  }

  /// Deletes a scan record from the local SQLite database.
  Future<void> deleteScan(String id, String userId) async {
    await _dbHelper.deleteScan(id);
    await loadScanHistory(userId);
  }

  /// Clears the current scan state.
  void clearCurrentScan() {
    _currentScan = null;
    _state = ScanState.idle;
    notifyListeners();
  }

  /// Sets a specific scan as the currently active scan.
  void setCurrentScan(ScanModel scan) {
    _currentScan = scan;
    notifyListeners();
  }
}
