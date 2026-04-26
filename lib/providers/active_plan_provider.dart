import 'package:flutter/material.dart';
import '../models/active_plan_model.dart';
import '../models/treatment_model.dart';
import '../models/scan_model.dart';
import '../services/active_plan_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_constants.dart';

enum ActivePlanState { idle, loading, loaded, error }

class ActivePlanProvider extends ChangeNotifier {
  final ActivePlanService _service = ActivePlanService();

  ActivePlanState _state = ActivePlanState.idle;
  ActivePlanModel? _activePlan;
  Map<String, dynamic>? _districtAlert;
  String _errorMessage = '';

  ActivePlanState get state => _state;
  ActivePlanModel? get activePlan => _activePlan;
  Map<String, dynamic>? get districtAlert => _districtAlert;
  String get errorMessage => _errorMessage;
  bool get hasPlan => _activePlan != null;

  String _planCacheKey(String userId) => 'active_plan_$userId';

  Future<void> loadActivePlan(String userId) async {
    if (userId.trim().isEmpty || userId == 'temp_user_id') {
      _activePlan = null;
      _state = ActivePlanState.loaded;
      notifyListeners();
      return;
    }

    _state = ActivePlanState.loading;
    notifyListeners();

    try {
      _activePlan = await _service.getActivePlan(userId);

      if (_activePlan == null) {
        final cached = LocalStorageService.get(
          AppConstants.userBox,
          _planCacheKey(userId),
        );
        if (cached != null) {
          _activePlan = ActivePlanModel.fromMap(cached);
        }
      }

      _state = ActivePlanState.loaded;
    } catch (e) {
      final cached = LocalStorageService.get(
        AppConstants.userBox,
        _planCacheKey(userId),
      );
      if (cached != null) {
        _activePlan = ActivePlanModel.fromMap(cached);
      }
      _state = ActivePlanState.loaded;
    }

    notifyListeners();
  }

  Future<void> loadDistrictAlert(String district) async {
    try {
      _districtAlert = await _service.getMostSpreadingDisease(district);
      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> createPlan({
    required String userId,
    required ScanModel scan,
    required TreatmentModel treatment,
  }) async {
    _state = ActivePlanState.loading;
    notifyListeners();

    try {
      _activePlan = await _service.createPlan(
        userId: userId,
        scan: scan,
        treatment: treatment,
      );

      _cacheLocally(userId);

      _state = ActivePlanState.loaded;
    } catch (e) {
      _errorMessage = 'Could not save plan: ${e.toString()}';
      _state = ActivePlanState.error;
    }

    notifyListeners();
  }

  Future<void> toggleStep({
    required String userId,
    required String stepId,
  }) async {
    if (_activePlan == null) return;

    try {
      _activePlan = await _service.toggleStep(
        userId: userId,
        plan: _activePlan!,
        stepId: stepId,
      );
      _cacheLocally(userId);
      notifyListeners();
    } catch (e) {
      final updatedSteps = _activePlan!.steps.map((step) {
        if (step.id == stepId) {
          return step.copyWith(isDone: !step.isDone);
        }
        return step;
      }).toList();
      _activePlan = _activePlan!.copyWith(steps: updatedSteps);
      _cacheLocally(userId);
      notifyListeners();
    }
  }

  Future<void> deletePlan(String userId) async {
    if (_activePlan == null) return;

    _state = ActivePlanState.loading;
    notifyListeners();

    try {
      await _service.deletePlan(userId: userId, planId: _activePlan!.id);
    } catch (e) {
    }

    _activePlan = null;
    LocalStorageService.delete(AppConstants.userBox, _planCacheKey(userId));
    LocalStorageService.delete(AppConstants.userBox, 'active_plan');
    notifyListeners();
  }

  void _cacheLocally(String userId) {
    if (_activePlan != null) {
      LocalStorageService.save(
        AppConstants.userBox,
        _planCacheKey(userId),
        _activePlan!.toMap(),
      );
    }
  }
}
