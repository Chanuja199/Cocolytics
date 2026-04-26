import 'package:flutter/material.dart';
import '../models/district_model.dart';
import '../services/map_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_constants.dart';

enum MapState { idle, loading, success, error }

class MapProvider extends ChangeNotifier {
  final MapService _mapService = MapService();

  MapState _state = MapState.idle;
  List<DistrictModel> _districts = [];
  List<DistrictModel> _recentAlerts = [];
  String _errorMessage = '';
  DateTime? _lastFetched;

  MapState get state => _state;
  List<DistrictModel> get districts => _districts;
  List<DistrictModel> get recentAlerts => _recentAlerts;
  String get errorMessage => _errorMessage;
  DateTime? get lastFetched => _lastFetched;

  Future<void> loadDistrictData({required bool isOnline}) async {
    _state = MapState.loading;
    notifyListeners();

    try {
      if (isOnline) {
        // Fetch fresh data from Firebase
        _districts = await _mapService.getDistrictData();
        _recentAlerts = await _mapService.getRecentAlerts();
        _lastFetched = DateTime.now();

        // Cache it
        for (final d in _districts) {
          LocalStorageService.save(
            AppConstants.districtBox,
            d.district,
            d.toMap(),
          );
        }
      } else {
        // Load from cache
        _loadFromCache();
      }

      _state = MapState.success;
    } catch (e) {
      _loadFromCache();
      _errorMessage = 'Could not refresh. Showing cached data.';
      _state = MapState.success; // still show cached data
    }

    notifyListeners();
  }

  void _loadFromCache() {
    final raw = LocalStorageService.getAll(AppConstants.districtBox);
    _districts = raw.map((e) => DistrictModel.fromMap(e)).toList();
    _districts.sort((a, b) => b.totalCases.compareTo(a.totalCases));
  }
}
