import 'package:flutter/material.dart';
import '../models/treatment_model.dart';
import '../services/treatment_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_constants.dart';

class PlanProvider extends ChangeNotifier {
  final TreatmentService _treatmentService = TreatmentService();

  TreatmentModel? _currentTreatment;
  bool _isLoading = false;
  String _errorMessage = '';

  TreatmentModel? get currentTreatment => _currentTreatment;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadTreatment(String diseaseId) async {
    // Check cache first
    final cached = LocalStorageService.get(
      AppConstants.treatmentsBox,
      diseaseId,
    );

    if (cached != null) {
      _currentTreatment = TreatmentModel.fromMap(cached);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _currentTreatment = await _treatmentService.getTreatment(diseaseId);

      // Cache it
      if (_currentTreatment != null) {
        LocalStorageService.save(
          AppConstants.treatmentsBox,
          diseaseId,
          _currentTreatment!.toMap(),
        );
      }
    } catch (e) {
      _errorMessage = 'Could not load treatment: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearTreatment() {
    _currentTreatment = null;
    notifyListeners();
  }
}
