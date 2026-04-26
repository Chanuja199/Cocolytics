import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/active_plan_model.dart';
import '../models/treatment_model.dart';
import '../models/scan_model.dart';

class ActivePlanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Create a new plan from a scan result + treatment data
  Future<ActivePlanModel> createPlan({
    required String userId,
    required ScanModel scan,
    required TreatmentModel treatment,
  }) async {
    final id = _uuid.v4();

    // Convert treatment steps into trackable PlanSteps
    final List<PlanStep> steps = [];

    for (final step in treatment.shortTermSteps) {
      steps.add(
        PlanStep(
          id: _uuid.v4(),
          text: step,
          isDone: false,
          category: 'short_term',
        ),
      );
    }

    for (final chemical in treatment.chemicalTreatments) {
      steps.add(
        PlanStep(
          id: _uuid.v4(),
          text: '${chemical.name} — ${chemical.use}',
          isDone: false,
          category: 'chemical',
        ),
      );
    }

    for (final step in treatment.longTermSteps) {
      steps.add(
        PlanStep(
          id: _uuid.v4(),
          text: step,
          isDone: false,
          category: 'long_term',
        ),
      );
    }

    final plan = ActivePlanModel(
      id: id,
      userId: userId,
      diseaseId: scan.id,
      diseaseName: scan.diseaseName,
      scanImageUrl: scan.imageUrl,
      severity: scan.severity,
      steps: steps,
      createdAt: DateTime.now(),
    );

    // Save to Firestore under user's document
    await _db
        .collection('users')
        .doc(userId)
        .collection('active_plans')
        .doc(id)
        .set(plan.toMap());

    return plan;
  }

  // Get the user's current active plan (most recent)
  Future<ActivePlanModel?> getActivePlan(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('active_plans')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return ActivePlanModel.fromMap(snapshot.docs.first.data());
  }

  // Toggle a step as done/undone
  Future<ActivePlanModel> toggleStep({
    required String userId,
    required ActivePlanModel plan,
    required String stepId,
  }) async {
    final updatedSteps = plan.steps.map((step) {
      if (step.id == stepId) {
        return step.copyWith(isDone: !step.isDone);
      }
      return step;
    }).toList();

    final updatedPlan = plan.copyWith(
      steps: updatedSteps,
      completedAt: updatedSteps.every((s) => s.isDone) ? DateTime.now() : null,
    );

    await _db
        .collection('users')
        .doc(userId)
        .collection('active_plans')
        .doc(plan.id)
        .update({
          'steps': updatedSteps.map((s) => s.toMap()).toList(),
          'completedAt': updatedPlan.completedAt?.toIso8601String(),
        });

    return updatedPlan;
  }

  // Delete the current active plan
  Future<void> deletePlan({
    required String userId,
    required String planId,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('active_plans')
        .doc(planId)
        .delete();
  }

  // Get the most spreading disease in a district from all users' scans
  Future<Map<String, dynamic>?> getMostSpreadingDisease(String district) async {
    try {
      final snapshot = await _db.collection('districts').doc(district).get();

      if (!snapshot.exists) return null;

      final data = snapshot.data()!;
      if (data['totalCases'] == 0) return null;

      return {
        'diseaseName': data['mostCommonDisease'] ?? '',
        'totalCases': data['totalCases'] ?? 0,
        'district': district,
        'lastUpdated': data['lastUpdated'] ?? '',
      };
    } catch (e) {
      return null;
    }
  }
}
